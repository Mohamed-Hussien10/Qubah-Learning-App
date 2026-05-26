import 'package:web_dashboard/core/network/api_client.dart';
import 'package:web_dashboard/features/dashboard/data/models/chart_data.dart';
import 'package:web_dashboard/features/dashboard/data/models/dashboard_stats.dart';

/// Repository providing dashboard data.
class DashboardRepository {
  final ApiClient _apiClient;

  DashboardRepository(this._apiClient);

  /// Fetch aggregate dashboard statistics.
  Future<DashboardStats> getStats() async {
    final response = await _apiClient.get('/dashboard/stats');
    final data = response.data['data'] ?? response.data;
    return DashboardStats.fromJson(data as Map<String, dynamic>);
  }

  /// Fetch monthly revenue data for the chart (12 months).
  Future<List<RevenueData>> getRevenueData() async {
    final response = await _apiClient.get('/dashboard/revenue');
    final data = response.data['data'] ?? response.data;
    if (data is List) {
      return data.map((json) => RevenueData.fromJson(json as Map<String, dynamic>)).toList();
    }
    return [];
  }

  /// Fetch monthly user-growth data for the chart (12 months).
  Future<List<ChartData>> getUserGrowthData() async {
    final response = await _apiClient.get('/dashboard/users');
    final data = response.data['data'] ?? response.data;
    if (data is List) {
      return data.map((json) => ChartData.fromJson(json as Map<String, dynamic>)).toList();
    }
    return [];
  }

  /// Fetch recent activity items.
  Future<List<Map<String, dynamic>>> getRecentActivity() async {
    final response = await _apiClient.get('/dashboard/activity');
    final data = response.data['data'] ?? response.data;
    if (data is List) {
      return data.map((item) => Map<String, dynamic>.from(item as Map)).toList();
    }
    return [];
  }
}
