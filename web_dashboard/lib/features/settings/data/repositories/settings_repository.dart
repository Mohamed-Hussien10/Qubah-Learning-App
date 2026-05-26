import 'package:web_dashboard/core/network/api_client.dart';
import 'package:web_dashboard/features/settings/data/models/app_settings_model.dart';

class SettingsRepository {
  final ApiClient _apiClient;

  SettingsRepository(this._apiClient);

  Future<AppSettingsModel> getSettings() async {
    final response = await _apiClient.get('/settings');
    final data = response.data['data'] ?? response.data;
    return AppSettingsModel.fromJson(data as Map<String, dynamic>);
  }

  Future<AppSettingsModel> updateSettings(AppSettingsModel settings) async {
    final payload = settings.toJson();
    final response = await _apiClient.put('/settings', data: payload);
    final data = response.data['data'] ?? response.data;
    return AppSettingsModel.fromJson(data as Map<String, dynamic>);
  }

  Future<AppSettingsModel> toggleMaintenanceMode() async {
    final settings = await getSettings();
    final updated = settings.copyWith(maintenanceMode: !settings.maintenanceMode);
    return updateSettings(updated);
  }

  Future<AppSettingsModel> updateSocialLinks(Map<String, String> links) async {
    final settings = await getSettings();
    final updated = settings.copyWith(socialLinks: links);
    return updateSettings(updated);
  }

  Future<AppSettingsModel> updateGeneralSettings({
    String? appName,
    String? contactEmail,
    String? contactPhone,
    String? logoUrl,
  }) async {
    final settings = await getSettings();
    final updated = settings.copyWith(
      appName: appName,
      contactEmail: contactEmail,
      contactPhone: contactPhone,
      logoUrl: logoUrl,
    );
    return updateSettings(updated);
  }
}
