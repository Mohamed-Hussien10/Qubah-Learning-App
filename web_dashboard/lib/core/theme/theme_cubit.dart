import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_dashboard/core/storage/local_storage.dart';

/// Cubit that manages the app's [ThemeMode] (light / dark / system).
///
/// Reads the persisted preference on creation and saves any change.
class ThemeCubit extends Cubit<ThemeMode> {
  final LocalStorage _localStorage;

  ThemeCubit(this._localStorage) : super(ThemeMode.light) {
    _loadSavedTheme();
  }

  /// Reads the stored theme mode and emits it.
  void _loadSavedTheme() {
    final savedMode = _localStorage.getThemeMode();
    emit(savedMode);
  }

  /// Toggles between light and dark themes.
  void toggleTheme() {
    final newMode =
        state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    _localStorage.setThemeMode(newMode);
    emit(newMode);
  }

  /// Sets a specific [ThemeMode].
  void setThemeMode(ThemeMode mode) {
    _localStorage.setThemeMode(mode);
    emit(mode);
  }

  /// Whether the current theme is dark.
  bool get isDark => state == ThemeMode.dark;

  /// Whether the current theme is light.
  bool get isLight => state == ThemeMode.light;
}
