import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qubah_learning_app/core/storage/secure_storage.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  final SecureStorage _secureStorage;

  ThemeCubit({required SecureStorage secureStorage})
    : _secureStorage = secureStorage,
      super(ThemeMode.light) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final mode = await _secureStorage.getThemeMode();
    if (mode == 'dark') {
      emit(ThemeMode.dark);
    } else {
      emit(ThemeMode.light); // Default to light
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final modeString = mode.toString().split('.').last; // 'light', 'dark', or 'system'
    await _secureStorage.saveThemeMode(modeString);
    emit(mode);
  }

  Future<void> toggleTheme() async {
    if (state == ThemeMode.light || state == ThemeMode.system) {
      // If light or system (assuming we toggle to a fixed state), go dark
      await setThemeMode(ThemeMode.dark);
    } else {
      await setThemeMode(ThemeMode.light);
    }
  }
}
