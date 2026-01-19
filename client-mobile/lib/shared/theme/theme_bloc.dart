/// Theme BLoC for managing app theme state
///
/// Handles theme mode switching (light/dark/system) with persistence.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

// =============================================================================
// EVENTS
// =============================================================================

/// Base theme event
sealed class ThemeEvent {}

/// Set theme to light mode
final class SetLightTheme extends ThemeEvent {}

/// Set theme to dark mode
final class SetDarkTheme extends ThemeEvent {}

/// Set theme to follow system
final class SetSystemTheme extends ThemeEvent {}

/// Set theme mode directly
final class SetThemeMode extends ThemeEvent {
  final ThemeMode mode;
  SetThemeMode(this.mode);
}

/// Load saved theme from storage
final class LoadSavedTheme extends ThemeEvent {}

// =============================================================================
// STATE
// =============================================================================

/// Theme state containing current mode
class ThemeState {
  /// The current theme mode setting
  final ThemeMode mode;

  const ThemeState({required this.mode});

  /// Initial state - follow system
  factory ThemeState.initial() => const ThemeState(mode: ThemeMode.system);

  /// Copy with new values
  ThemeState copyWith({ThemeMode? mode}) {
    return ThemeState(mode: mode ?? this.mode);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ThemeState &&
          runtimeType == other.runtimeType &&
          mode == other.mode;

  @override
  int get hashCode => mode.hashCode;
}

// =============================================================================
// BLOC
// =============================================================================

/// BLoC for theme management
class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  static const String _storageKey = 'guardyn_theme_mode';

  ThemeBloc() : super(ThemeState.initial()) {
    on<SetLightTheme>(_onSetLight);
    on<SetDarkTheme>(_onSetDark);
    on<SetSystemTheme>(_onSetSystem);
    on<SetThemeMode>(_onSetMode);
    on<LoadSavedTheme>(_onLoadSaved);
  }

  /// Set to light mode
  Future<void> _onSetLight(
    SetLightTheme event,
    Emitter<ThemeState> emit,
  ) async {
    emit(state.copyWith(mode: ThemeMode.light));
    await _saveThemeMode(ThemeMode.light);
  }

  /// Set to dark mode
  Future<void> _onSetDark(SetDarkTheme event, Emitter<ThemeState> emit) async {
    emit(state.copyWith(mode: ThemeMode.dark));
    await _saveThemeMode(ThemeMode.dark);
  }

  /// Set to system mode
  Future<void> _onSetSystem(
    SetSystemTheme event,
    Emitter<ThemeState> emit,
  ) async {
    emit(state.copyWith(mode: ThemeMode.system));
    await _saveThemeMode(ThemeMode.system);
  }

  /// Set mode directly
  Future<void> _onSetMode(SetThemeMode event, Emitter<ThemeState> emit) async {
    emit(state.copyWith(mode: event.mode));
    await _saveThemeMode(event.mode);
  }

  /// Load saved theme from storage
  Future<void> _onLoadSaved(
    LoadSavedTheme event,
    Emitter<ThemeState> emit,
  ) async {
    final mode = await _loadThemeMode();
    emit(state.copyWith(mode: mode));
  }

  /// Save theme mode to SharedPreferences
  Future<void> _saveThemeMode(ThemeMode mode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKey, mode.name);
    } catch (e) {
      // Silently fail - theme will use default on next app start
    }
  }

  /// Load theme mode from SharedPreferences
  Future<ThemeMode> _loadThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_storageKey);
      if (saved != null) {
        return ThemeMode.values.firstWhere(
          (mode) => mode.name == saved,
          orElse: () => ThemeMode.system,
        );
      }
    } catch (e) {
      // Return default on error
    }
    return ThemeMode.system;
  }
}
