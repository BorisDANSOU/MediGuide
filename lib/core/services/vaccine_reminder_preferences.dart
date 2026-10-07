import 'package:shared_preferences/shared_preferences.dart';

class VaccineReminderPreferences {
  const VaccineReminderPreferences(this._preferences);

  static const String enabledKey = 'vaccine_reminders_enabled';

  final SharedPreferences _preferences;

  bool get isEnabled => _preferences.getBool(enabledKey) ?? true;

  Future<bool> setEnabled(bool enabled) =>
      _preferences.setBool(enabledKey, enabled);
}
