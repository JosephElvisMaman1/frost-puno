import 'package:flutter/material.dart';

import 'core/api/api_client.dart';
import 'core/api/frost_api_service.dart';
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
    return ThemeModeScope(
      themeMode: _themeMode,
      onThemeModeChanged: (mode) => setState(() => _themeMode = mode),
      child: MaterialApp(
        title: 'FrostPuno',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: _themeMode,
        home: AppShell(apiService: _apiService),
      ),
    );
  }
}
