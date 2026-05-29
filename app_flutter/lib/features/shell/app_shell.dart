import 'package:flutter/material.dart';

import '../../core/api/frost_api_service.dart';
import '../data_sources/screens/data_sources_screen.dart';
import '../history/screens/history_screen.dart';
import '../home/screens/home_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({required this.apiService, super.key});

  final FrostApiService apiService;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final screens = [
      HomeScreen(apiService: widget.apiService),
      HistoryScreen(apiService: widget.apiService, showAppBar: false),
      const DataSourcesScreen(showAppBar: false),
    ];

    return Scaffold(
      body: screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) =>
            setState(() => _selectedIndex = index),
        backgroundColor: colorScheme.surface.withValues(alpha: 0.96),
        indicatorColor: colorScheme.primary,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontFamily: 'monospace',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: states.contains(WidgetState.selected)
                ? colorScheme.onPrimary
                : colorScheme.onSurface.withValues(alpha: 0.68),
          ),
        ),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          NavigationDestination(icon: Icon(Icons.history), label: 'Historial'),
          NavigationDestination(
            icon: Icon(Icons.storage_outlined),
            selectedIcon: Icon(Icons.storage),
            label: 'Fuentes',
          ),
        ],
      ),
    );
  }
}
