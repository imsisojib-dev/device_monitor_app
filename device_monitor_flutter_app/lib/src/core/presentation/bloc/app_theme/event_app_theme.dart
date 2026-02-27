part of 'bloc_app_theme.dart';

abstract class EventAppTheme {}

class EventAppThemeInitial extends EventAppTheme {}

class EventAppThemeToggle extends EventAppTheme {}

class EventAppThemeSet extends EventAppTheme {
  final ThemeMode themeMode;

  EventAppThemeSet(this.themeMode);
}
