import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

typedef NotificationInitializer = Future<void> Function();
typedef NotificationPermissionRequester = Future<bool> Function();
typedef ExactAlarmPermissionChecker = Future<bool> Function();
typedef NotificationTapHandler = void Function(String payload);
typedef NotificationLaunchPayloadReader = Future<String?> Function();
typedef NotificationScheduler = Future<void> Function({
  required int id,
  required String title,
  required String body,
  required DateTime scheduledDate,
});
typedef NotificationCanceller = Future<void> Function(int id);
typedef NotificationAllCanceller = Future<void> Function();

class NotificationService {
  NotificationService._({
    NotificationInitializer? initialize,
    NotificationPermissionRequester? requestPermission,
    ExactAlarmPermissionChecker? canScheduleExactAlarms,
    NotificationPermissionRequester? requestExactAlarmsPermission,
    NotificationLaunchPayloadReader? readLaunchPayload,
    NotificationScheduler? schedule,
    NotificationCanceller? cancel,
    NotificationAllCanceller? cancelAll,
  }) : _initializeOverride = initialize,
       _requestPermissionOverride = requestPermission,
       _canScheduleExactAlarmsOverride = canScheduleExactAlarms,
       _requestExactAlarmsPermissionOverride = requestExactAlarmsPermission,
       _readLaunchPayloadOverride = readLaunchPayload,
       _scheduleOverride = schedule,
       _cancelOverride = cancel,
       _cancelAllOverride = cancelAll;

  static final NotificationService _instance = NotificationService._();

  factory NotificationService({
    NotificationInitializer? initialize,
    NotificationPermissionRequester? requestPermission,
    ExactAlarmPermissionChecker? canScheduleExactAlarms,
    NotificationPermissionRequester? requestExactAlarmsPermission,
    NotificationLaunchPayloadReader? readLaunchPayload,
    NotificationScheduler? schedule,
    NotificationCanceller? cancel,
    NotificationAllCanceller? cancelAll,
  }) {
    if (initialize == null &&
        requestPermission == null &&
        canScheduleExactAlarms == null &&
        requestExactAlarmsPermission == null &&
        readLaunchPayload == null &&
        schedule == null &&
        cancel == null &&
        cancelAll == null) {
      return _instance;
    }
    return NotificationService._(
      initialize: initialize,
      requestPermission: requestPermission,
      canScheduleExactAlarms: canScheduleExactAlarms,
      requestExactAlarmsPermission: requestExactAlarmsPermission,
      readLaunchPayload: readLaunchPayload,
      schedule: schedule,
      cancel: cancel,
      cancelAll: cancelAll,
    );
  }

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final NotificationInitializer? _initializeOverride;
  final NotificationPermissionRequester? _requestPermissionOverride;
  final ExactAlarmPermissionChecker? _canScheduleExactAlarmsOverride;
  final NotificationPermissionRequester? _requestExactAlarmsPermissionOverride;
  final NotificationLaunchPayloadReader? _readLaunchPayloadOverride;
  final NotificationScheduler? _scheduleOverride;
  final NotificationCanceller? _cancelOverride;
  final NotificationAllCanceller? _cancelAllOverride;

  bool _isInitialized = false;
  NotificationTapHandler? _notificationTapHandler;
  String? _initialNotificationPayload;

  static int notificationIdForVaccine(String vaccineId) {
    var hash = 0x811c9dc5;
    for (final byte in utf8.encode(vaccineId)) {
      hash = ((hash ^ byte) * 0x01000193) & 0xffffffff;
    }
    final id = hash & 0x7fffffff;
    return id == 0 ? 1 : id;
  }

  void setNotificationTapHandler(NotificationTapHandler handler) {
    _notificationTapHandler = handler;
  }

  Future<void> handleInitialNotificationTap() async {
    final payload = _initialNotificationPayload;
    _initialNotificationPayload = null;
    handleNotificationTap(payload);
  }

  void handleNotificationTap(String? payload) {
    if (payload == null ||
        !payload.startsWith('vaccine_reminder:') ||
        payload.length == 'vaccine_reminder:'.length) {
      return;
    }
    _notificationTapHandler?.call(payload);
  }

  /// Initialise le service de notifications
  Future<void> initialize() async {
    if (_isInitialized) return;

    if (_initializeOverride != null) {
      await _initializeOverride();
      _initialNotificationPayload = await _readLaunchPayloadOverride?.call();
      _isInitialized = true;
      return;
    }

    tz_data.initializeTimeZones();
    if (!kIsWeb &&
        defaultTargetPlatform != TargetPlatform.linux &&
        defaultTargetPlatform != TargetPlatform.windows) {
      final timeZoneInfo = await FlutterTimezone.getLocalTimezone();
      final identifier = timeZoneInfo.identifier == 'GMT'
          ? 'Etc/GMT'
          : timeZoneInfo.identifier;
      tz.setLocalLocation(tz.getLocation(identifier));
    }

    // Configuration Android
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // Configuration iOS
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    // Configuration combinée
    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await _notificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );
    if (_readLaunchPayloadOverride != null) {
      _initialNotificationPayload = await _readLaunchPayloadOverride();
    } else {
      final launchDetails = await _notificationsPlugin
          .getNotificationAppLaunchDetails();
      if (launchDetails?.didNotificationLaunchApp ?? false) {
        _initialNotificationPayload =
            launchDetails?.notificationResponse?.payload;
      }
    }

    _isInitialized = true;
  }

  /// Planifie un rappel de vaccination
  Future<void> scheduleVaccineReminder({
    required String vaccineId,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    if (scheduledDate.isBefore(DateTime.now())) {
      throw ArgumentError.value(
        scheduledDate,
        'scheduledDate',
        'La date du rappel doit être dans le futur.',
      );
    }

    if (!_isInitialized) {
      await initialize();
    }

    final granted =
        await (_requestPermissionOverride?.call() ??
            _requestNotificationPermission());
    if (!granted) {
      throw const NotificationPermissionDeniedException();
    }

    if (defaultTargetPlatform == TargetPlatform.android ||
        _canScheduleExactAlarmsOverride != null ||
        _requestExactAlarmsPermissionOverride != null) {
      await _ensureExactAlarmPermission();
    }

    final id = notificationIdForVaccine(vaccineId);
    final scheduleOverride = _scheduleOverride;
    if (scheduleOverride != null) {
      await scheduleOverride(
        id: id,
        title: title,
        body: body,
        scheduledDate: scheduledDate,
      );
      return;
    }

    await _scheduleWithPlugin(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
      payload: payload,
    );
  }

  Future<void> _ensureExactAlarmPermission() async {
    final canScheduleOverride = _canScheduleExactAlarmsOverride;
    final requestPermissionOverride = _requestExactAlarmsPermissionOverride;

    Future<bool> canSchedule() async {
      if (canScheduleOverride != null) return canScheduleOverride();
      final androidPlugin = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      return await androidPlugin?.canScheduleExactNotifications() ?? false;
    }

    if (await canSchedule()) return;

    final granted = requestPermissionOverride != null
        ? await requestPermissionOverride()
        : await _notificationsPlugin
                  .resolvePlatformSpecificImplementation<
                    AndroidFlutterLocalNotificationsPlugin
                  >()
                  ?.requestExactAlarmsPermission() ??
              false;
    if (!granted || !await canSchedule()) {
      throw const ExactAlarmPermissionDeniedException();
    }
  }

  Future<void> _scheduleWithPlugin({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'vaccine_reminders',
          'Rappels de vaccination',
          channelDescription: 'Notifications pour les rappels de vaccination',
          importance: Importance.high,
          priority: Priority.high,
          showWhen: true,
          icon: '@mipmap/ic_launcher',
        );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _notificationsPlugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: tz.TZDateTime.from(scheduledDate, tz.local),
      notificationDetails: platformChannelSpecifics,
      payload: payload,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  /// Annule un rappel par son ID
  Future<void> cancelReminder(int id) async {
    final cancelOverride = _cancelOverride;
    if (cancelOverride != null) {
      await cancelOverride(id);
      return;
    }
    await _notificationsPlugin.cancel(id: id);
  }

  /// Alias métier pour annuler un rappel de vaccination précis.
  Future<void> cancelVaccineReminder({required String vaccineId}) =>
      cancelReminder(notificationIdForVaccine(vaccineId));

  /// Annule tous les rappels
  Future<void> cancelAllReminders() async {
    final cancelAllOverride = _cancelAllOverride;
    if (cancelAllOverride != null) {
      await cancelAllOverride();
      return;
    }
    await _notificationsPlugin.cancelAll();
  }

  /// Affiche une notification immédiate (pour tests)
  Future<void> showImmediateNotification({
    required String title,
    required String body,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'vaccine_reminders',
          'Rappels de vaccination',
          channelDescription: 'Notifications pour les rappels de vaccination',
          importance: Importance.high,
          priority: Priority.high,
        );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await _notificationsPlugin.show(
      id: 0,
      title: title,
      body: body,
      notificationDetails: platformChannelSpecifics,
    );
  }

  /// Callback quand l'utilisateur tap sur une notification
  void _onNotificationTap(NotificationResponse response) {
    handleNotificationTap(response.payload);
  }

  Future<bool> _requestNotificationPermission() async {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return await _notificationsPlugin
                .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin
                >()
                ?.requestNotificationsPermission() ??
            false;
      case TargetPlatform.iOS:
        return await _notificationsPlugin
                .resolvePlatformSpecificImplementation<
                  IOSFlutterLocalNotificationsPlugin
                >()
                ?.requestPermissions(alert: true, badge: true, sound: true) ??
            false;
      case TargetPlatform.macOS:
        return await _notificationsPlugin
                .resolvePlatformSpecificImplementation<
                  MacOSFlutterLocalNotificationsPlugin
                >()
                ?.requestPermissions(alert: true, badge: true, sound: true) ??
            false;
      default:
        return true;
    }
  }
}

class NotificationPermissionDeniedException implements Exception {
  const NotificationPermissionDeniedException();

  @override
  String toString() =>
      'La permission d’afficher des notifications est refusée.';
}

class ExactAlarmPermissionDeniedException implements Exception {
  const ExactAlarmPermissionDeniedException();

  @override
  String toString() =>
      'L’accès aux alarmes exactes est nécessaire pour programmer ce rappel.';
}
