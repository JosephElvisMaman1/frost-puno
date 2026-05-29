import 'package:flutter/material.dart';

import '../../core/theme/theme_mode_scope.dart';

class FrostAppBar extends StatelessWidget implements PreferredSizeWidget {
  const FrostAppBar({super.key, this.canPop = false});

  final bool canPop;

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final themeScope = ThemeModeScope.maybeOf(context);
    final mode = themeScope?.themeMode ?? ThemeMode.system;
    return AppBar(
      leading: canPop
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).maybePop(),
            )
          : null,
      title: const Text('FrostPuno'),
      actions: [
        IconButton(
          tooltip: _nextThemeLabel(mode),
          icon: Icon(_themeIcon(mode)),
          onPressed: themeScope == null
              ? null
              : () => themeScope.onThemeModeChanged(_nextThemeMode(mode)),
        ),
      ],
    );
  }

  static ThemeMode _nextThemeMode(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.system => ThemeMode.light,
      ThemeMode.light => ThemeMode.dark,
      ThemeMode.dark => ThemeMode.system,
    };
  }

  static IconData _themeIcon(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.system => Icons.brightness_auto_outlined,
      ThemeMode.light => Icons.light_mode_outlined,
      ThemeMode.dark => Icons.dark_mode_outlined,
    };
  }

  static String _nextThemeLabel(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.system => 'Usar modo claro',
      ThemeMode.light => 'Usar modo oscuro',
      ThemeMode.dark => 'Usar modo del sistema',
    };
  }
}
