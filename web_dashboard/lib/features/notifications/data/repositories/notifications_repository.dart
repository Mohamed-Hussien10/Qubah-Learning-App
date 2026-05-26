import 'package:web_dashboard/core/network/api_client.dart';
import 'package:web_dashboard/features/notifications/data/models/notification_model.dart';

class NotificationsRepository {
  final ApiClient _apiClient;

  NotificationsRepository(this._apiClient);

  Future<List<NotificationModel>> getAll() async {
    final response = await _apiClient.get('/notifications');
    final data = response.data['data'] ?? response.data;
    if (data is List) {
      return data.map((json) => NotificationModel.fromJson(json as Map<String, dynamic>)).toList();
    }
    return [];
  }

  Future<NotificationModel> create({
    required String title,
    required String body,
    required NotificationTargetType targetType,
    int? targetId,
    required NotificationStatus status,
    DateTime? sentAt,
  }) async {
    final payload = {
      'title': title,
      'body': body,
      'target_type': targetType.name,
      'target_id': targetId,
      'status': status.name,
      'sent_at': sentAt?.toIso8601String(),
    };
    final response = await _apiClient.post('/notifications', data: payload);
    final data = response.data['data'] ?? response.data;
    return NotificationModel.fromJson(data as Map<String, dynamic>);
  }

  Future<NotificationModel> send(int id) async {
    final response = await _apiClient.post('/notifications/$id/send');
    final data = response.data['data'] ?? response.data;
    return NotificationModel.fromJson(data as Map<String, dynamic>);
  }

  Future<void> delete(int id) async {
    await _apiClient.delete('/notifications/$id');
  }

  Future<NotificationModel> update(NotificationModel notification) async {
    final payload = notification.toJson();
    final response = await _apiClient.put('/notifications/${notification.id}', data: payload);
    final data = response.data['data'] ?? response.data;
    return NotificationModel.fromJson(data as Map<String, dynamic>);
  }
}
