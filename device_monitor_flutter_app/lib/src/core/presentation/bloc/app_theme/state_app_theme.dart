part of 'bloc_app_theme.dart';

class StateAppTheme extends Equatable {
  final ThemeMode themeMode;

  const StateAppTheme({required this.themeMode});

  bool get isDark => themeMode == ThemeMode.dark;

  bool get isLight => themeMode == ThemeMode.light;

  StateAppTheme copyWith({ThemeMode? themeMode}) {
    return StateAppTheme(
      themeMode: themeMode ?? this.themeMode,
    );
  }

  @override
  List<Object?> get props => [themeMode];
}
