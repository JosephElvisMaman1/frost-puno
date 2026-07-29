import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../i18n/app_language.dart';

/// Perfil del usuario: filtra qué alertas se priorizan en Inicio.
enum UserProfile { general, agricultor, ganadero, chunero }

extension UserProfileLabel on UserProfile {
  String get label => switch (this) {
    UserProfile.general => 'General',
    UserProfile.agricultor => 'Agricultor',
    UserProfile.ganadero => 'Ganadero',
    UserProfile.chunero => 'Chuñero',
  };
}

/// Preferencias del usuario persistidas con shared_preferences.
/// Singleton observable (ChangeNotifier) para reaccionar en la UI.
class UserSettings extends ChangeNotifier {
  UserSettings._();
  static final UserSettings instance = UserSettings._();

  static const _kAlertsEnabled = 'alerts_enabled';
  static const _kThreshold = 'alert_threshold';
  static const _kProfile = 'user_profile';
  static const _kLanguage = 'app_language';

  bool alertsEnabled = true;
  double alertThreshold = -4;
  UserProfile profile = UserProfile.general;
  AppLanguage language = AppLanguage.es;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    alertsEnabled = prefs.getBool(_kAlertsEnabled) ?? true;
    alertThreshold = prefs.getDouble(_kThreshold) ?? -4;
    final profileIndex = prefs.getInt(_kProfile) ?? 0;
    profile = UserProfile.values[profileIndex.clamp(0, UserProfile.values.length - 1)];
    final langIndex = prefs.getInt(_kLanguage) ?? 0;
    language = AppLanguage.values[langIndex.clamp(0, AppLanguage.values.length - 1)];
    notifyListeners();
  }

  Future<void> setLanguage(AppLanguage value) async {
    language = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kLanguage, value.index);
  }

  Future<void> setAlertsEnabled(bool value) async {
    alertsEnabled = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kAlertsEnabled, value);
  }

  Future<void> setThreshold(double value) async {
    alertThreshold = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_kThreshold, value);
  }

  Future<void> setProfile(UserProfile value) async {
    profile = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kProfile, value.index);
  }
}
