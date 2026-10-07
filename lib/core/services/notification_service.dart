import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

typedef NotificationInitializer = Future<void> Function();
typedef NotificationPermissionRequester = Future<bool> Function();
typedef NotificationScheduler =
    Future<void> Function({
      required int id,
      required String title,
      required String body,
      required DateTime scheduledDate,
    });
typedef NotificationCanceller = Future<void> Function(int id);

class NotificationService {
  NotificationService._({
    NotificationInitializer? initialize,
    NotificationPermissionRequester? requestPermission,
    NotificationScheduler? schedule,
    NotificationCanceller? cancel,
  }) : _initializeOverride = initialize,
       _requestPermissionOverride = requestPermission,
       _scheduleOverride = schedule,
       _cancelOverride = cancel;

  static final NotificationService _instance = NotificationService._();

  factory NotificationService({
    NotificationInitializer? initialize,
    NotificationPermissionRequester? requestPermission,
    NotificationScheduler? schedule,
    NotificationCanceller? cancel,
  }) {
    if (initialize == null &&
        requestPermission == null &&
        schedule == null &&
        cancel == null) {
      return _instance;
    }
    return NotificationService._(
      initialize: initialize,
      requestPermission: requestPermission,
      schedule: schedule,
      cancel: cancel,
    );
  }

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final NotificationInitializer? _initializeOverride;
  final NotificationPermissionRequester? _requestPermissionOverride;
  final NotificationScheduler? _scheduleOverride;
  final NotificationCanceller? _cancelOverride;

  bool _isInitialized = false;
  bool _hasNotificationPermission = false;

  /// Initialise le service de notifications
  Future<void> initialize() async {
    if (_isInitialized) return;

    if (_initializeOverride != null) {
      await _initializeOverride();
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

    _isInitialized = true;
  }

  /// Planifie un rappel de vaccination
  Future<void> scheduleVaccineReminder({
    int? notificationId,
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

    if (!_hasNotificationPermission) {
      final granted = await (_requestPermissionOverride?.call() ??
          _requestNotificationPermission());
      if (!granted) {
        throw const NotificationPermissionDeniedException();
      }
      _hasNotificationPermission = true;
    }

    final id = notificationId ?? DateTime.now().millisecondsSinceEpoch ~/ 1000;
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
  Future<void> cancelVaccineReminder({required int notificationId}) =>
      cancelReminder(notificationId);

  /// Annule tous les rappels
  Future<void> cancelAllReminders() async {
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
    debugPrint('Notification tapée: ${response.payload}');
    // TODO: Naviguer vers la page appropriée
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
  String toString() => 'La permission d’afficher des notifications est refusée.';
}
