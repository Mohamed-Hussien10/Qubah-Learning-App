import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_dashboard/features/settings/data/models/app_settings_model.dart';
import 'package:web_dashboard/features/settings/data/repositories/settings_repository.dart';
import 'package:web_dashboard/features/settings/presentation/manager/settings_state.dart';
import 'package:web_dashboard/core/errors/error_handler.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final SettingsRepository _repository;

  SettingsCubit(this._repository) : super(const SettingsState());

  Future<void> loadSettings() async {
    emit(state.copyWith(status: SettingsStatus.loading));
    try {
      final settings = await _repository.getSettings();
      emit(state.copyWith(
        status: SettingsStatus.loaded,
        settings: settings,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: SettingsStatus.error,
        errorMessage: ErrorHandler.handle(e),
      ));
    }
  }

  Future<void> updateSettings(AppSettingsModel settings) async {
    emit(state.copyWith(status: SettingsStatus.saving));
    try {
      final updated = await _repository.updateSettings(settings);
      emit(state.copyWith(
        status: SettingsStatus.loaded,
        settings: updated,
        saveSuccess: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: SettingsStatus.error,
        errorMessage: ErrorHandler.handle(e),
      ));
    }
  }

  Future<void> toggleMaintenanceMode() async {
    try {
      final updated = await _repository.toggleMaintenanceMode();
      emit(state.copyWith(settings: updated));
    } catch (e) {
      emit(state.copyWith(
        status: SettingsStatus.error,
        errorMessage: ErrorHandler.handle(e),
      ));
    }
  }

  Future<void> updateGeneralSettings({
    String? appName,
    String? contactEmail,
    String? contactPhone,
    String? logoUrl,
    bool? maintenanceMode,
  }) async {
    emit(state.copyWith(status: SettingsStatus.saving));
    try {
      final updated = await _repository.updateGeneralSettings(
        appName: appName,
        contactEmail: contactEmail,
        contactPhone: contactPhone,
        logoUrl: logoUrl,
        maintenanceMode: maintenanceMode,
      );
      emit(state.copyWith(
        status: SettingsStatus.loaded,
        settings: updated,
        saveSuccess: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: SettingsStatus.error,
        errorMessage: ErrorHandler.handle(e),
      ));
    }
  }

  Future<void> updateSocialLinks(Map<String, String> links) async {
    emit(state.copyWith(status: SettingsStatus.saving));
    try {
      final updated = await _repository.updateSocialLinks(links);
      emit(state.copyWith(
        status: SettingsStatus.loaded,
        settings: updated,
        saveSuccess: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: SettingsStatus.error,
        errorMessage: ErrorHandler.handle(e),
      ));
    }
  }

  void clearSaveSuccess() {
    emit(state.copyWith(saveSuccess: false));
  }
}
