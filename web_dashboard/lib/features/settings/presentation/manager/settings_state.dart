import 'package:equatable/equatable.dart';
import 'package:web_dashboard/features/settings/data/models/app_settings_model.dart';

enum SettingsStatus { initial, loading, loaded, saving, error }

class SettingsState extends Equatable {
  final SettingsStatus status;
  final AppSettingsModel? settings;
  final String? errorMessage;
  final bool saveSuccess;

  const SettingsState({
    this.status = SettingsStatus.initial,
    this.settings,
    this.errorMessage,
    this.saveSuccess = false,
  });

  SettingsState copyWith({
    SettingsStatus? status,
    AppSettingsModel? settings,
    String? errorMessage,
    bool? saveSuccess,
  }) {
    return SettingsState(
      status: status ?? this.status,
      settings: settings ?? this.settings,
      errorMessage: errorMessage ?? this.errorMessage,
      saveSuccess: saveSuccess ?? this.saveSuccess,
    );
  }

  @override
  List<Object?> get props => [status, settings, errorMessage, saveSuccess];
}
