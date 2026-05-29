import 'package:flutter/material.dart';

class ThemeModeScope extends InheritedWidget {
  const ThemeModeScope({
    required this.themeMode,
    required this.onThemeModeChanged,
    required super.child,
    super.key,
  });

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  static ThemeModeScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ThemeModeScope>();
  }

  static ThemeModeScope of(BuildContext context) {
    final scope = maybeOf(context);
    assert(scope != null, 'ThemeModeScope not found in context');
    return scope!;
  }

  @override
  bool updateShouldNotify(ThemeModeScope oldWidget) {
    return themeMode != oldWidget.themeMode ||
        onThemeModeChanged != oldWidget.onThemeModeChanged;
  }
}
