import 'package:web_dashboard/core/network/api_client.dart';
import 'package:web_dashboard/features/analytics/data/models/analytics_data.dart';

class AnalyticsRepository {
  final ApiClient _apiClient;

  AnalyticsRepository(this._apiClient);

  Future<UserAnalytics> getUserAnalytics() async {
    final response = await _apiClient.get('/analytics/users');
    final data = response.data['data'] ?? response.data;
    return UserAnalytics.fromJson(data as Map<String, dynamic>);
  }

  Future<ContentAnalytics> getContentAnalytics() async {
    final response = await _apiClient.get('/analytics/content');
    final data = response.data['data'] ?? response.data;
    return ContentAnalytics.fromJson(data as Map<String, dynamic>);
  }

  Future<RevenueAnalytics> getRevenueAnalytics() async {
    final response = await _apiClient.get('/analytics/revenue');
    final data = response.data['data'] ?? response.data;
    return RevenueAnalytics.fromJson(data as Map<String, dynamic>);
  }
}
