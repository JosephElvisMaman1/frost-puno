import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/api/api_client.dart';
import 'core/api/frost_api_service.dart';
import 'core/i18n/app_language.dart';
import 'core/settings/user_settings.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_mode_scope.dart';
import 'features/shell/app_shell.dart';

class FrostPunoApp extends StatefulWidget {
  const FrostPunoApp({super.key});

  @override
  State<FrostPunoApp> createState() => _FrostPunoAppState();
}

class _FrostPunoAppState extends State<FrostPunoApp> {
  late final ApiClient _apiClient = ApiClient();
  late final FrostApiService _apiService = FrostApiService(_apiClient);
  ThemeMode _themeMode = ThemeMode.system;

  @override
  Widget build(BuildContext context) {
    // Reconstruye toda la app al cambiar idioma/preferencias del usuario.
    return AnimatedBuilder(
      animation: UserSettings.instance,
      builder: (context, _) {
        return ThemeModeScope(
          themeMode: _themeMode,
          onThemeModeChanged: (mode) => setState(() => _themeMode = mode),
          child: MaterialApp(
            title: 'FrostPuno',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: _themeMode,
            locale: Locale(UserSettings.instance.language.code),
            supportedLocales: const [Locale('es'), Locale('en')],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: AppShell(apiService: _apiService),
          ),
        );
      },
    );
  }
}
