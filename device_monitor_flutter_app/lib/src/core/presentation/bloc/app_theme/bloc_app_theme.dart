import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'event_app_theme.dart';

part 'state_app_theme.dart';

class BlocAppTheme extends Bloc<EventAppTheme, StateAppTheme> {
  BlocAppTheme() : super(const StateAppTheme(themeMode: ThemeMode.light)) {
    on<EventAppThemeInitial>(_onInitialAppTheme);
    on<EventAppThemeToggle>(_onToggleAppTheme);
    on<EventAppThemeSet>(_onSetAppTheme);
  }

  void _onInitialAppTheme(EventAppThemeInitial event, Emitter<StateAppTheme> emit) {
    emit(state.copyWith(themeMode: ThemeMode.light));
  }

  void _onToggleAppTheme(EventAppThemeToggle event, Emitter<StateAppTheme> emit) {
    final newMode = state.themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;

    emit(state.copyWith(themeMode: newMode));
  }

  void _onSetAppTheme(EventAppThemeSet event, Emitter<StateAppTheme> emit) {
    emit(state.copyWith(themeMode: event.themeMode));
  }
}
