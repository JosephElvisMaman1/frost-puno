import 'package:flutter/material.dart';

import 'core/api/api_client.dart';
import 'core/api/frost_api_service.dart';
import 'core/theme/app_theme.dart';
import 'features/shell/app_shell.dart';

class FrostPunoApp extends StatelessWidget {
  const FrostPunoApp({super.key});

  @override
  Widget build(BuildContext context) {
    final apiClient = ApiClient();
    final apiService = FrostApiService(apiClient);

    return MaterialApp(
      title: 'Frost Puno',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: AppShell(apiService: apiService),
    );
  }
}
