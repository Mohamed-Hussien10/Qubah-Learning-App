import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qubah_learning_app/core/storage/secure_storage.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  final SecureStorage _secureStorage;

  ThemeCubit({required SecureStorage secureStorage})
    : _secureStorage = secureStorage,
      super(ThemeMode.dark) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final mode = await _secureStorage.getThemeMode();
    if (mode == 'light') {
      emit(ThemeMode.light);
    } else if (mode == 'dark') {
      emit(ThemeMode.dark);
    } else {
      emit(ThemeMode.dark); // Default to dark for premium look
    }
  }

  Future<void> toggleTheme() async {
    if (state == ThemeMode.light) {
      await _secureStorage.saveThemeMode('dark');
      emit(ThemeMode.dark);
    } else {
      await _secureStorage.saveThemeMode('light');
      emit(ThemeMode.light);
    }
  }
}
