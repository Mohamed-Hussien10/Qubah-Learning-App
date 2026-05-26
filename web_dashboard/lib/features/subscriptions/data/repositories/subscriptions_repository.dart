import 'package:web_dashboard/core/network/api_client.dart';
import 'package:web_dashboard/features/subscriptions/data/models/subscription_model.dart';
import 'package:web_dashboard/features/subscriptions/data/models/plan_model.dart';

class SubscriptionsRepository {
  final ApiClient _apiClient;

  SubscriptionsRepository(this._apiClient);

  // ── Plans ──────────────────────────────────────────────────────────────

  Future<List<PlanModel>> getAllPlans() async {
    final response = await _apiClient.get('/subscriptions/plans');
    final data = response.data['data'] ?? response.data;
    if (data is List) {
      return data.map((json) => PlanModel.fromJson(json as Map<String, dynamic>)).toList();
    }
    return [];
  }

  Future<PlanModel> createPlan(PlanModel plan) async {
    final payload = plan.toJson()..remove('id');
    final response = await _apiClient.post('/subscriptions/plans', data: payload);
    final data = response.data['data'] ?? response.data;
    return PlanModel.fromJson(data as Map<String, dynamic>);
  }

  Future<PlanModel> updatePlan(PlanModel plan) async {
    final payload = plan.toJson();
    final response = await _apiClient.put('/subscriptions/plans/${plan.id}', data: payload);
    final data = response.data['data'] ?? response.data;
    return PlanModel.fromJson(data as Map<String, dynamic>);
  }

  Future<void> deletePlan(int id) async {
    await _apiClient.delete('/subscriptions/plans/$id');
  }

  // ── Subscriptions ─────────────────────────────────────────────────────

  Future<List<SubscriptionModel>> getAllSubscriptions() async {
    final response = await _apiClient.get('/subscriptions');
    final data = response.data['data'] ?? response.data;
    if (data is List) {
      return data.map((json) => SubscriptionModel.fromJson(json as Map<String, dynamic>)).toList();
    }
    return [];
  }

  Future<SubscriptionModel> assignSubscription({
    required int userId,
    required String userName,
    required String planName,
    required DateTime startDate,
    required DateTime endDate,
    required double amount,
  }) async {
    final payload = {
      'user_id': userId,
      'user_name': userName,
      'plan_name': planName,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'amount': amount,
    };
    final response = await _apiClient.post('/subscriptions', data: payload);
    final data = response.data['data'] ?? response.data;
    return SubscriptionModel.fromJson(data as Map<String, dynamic>);
  }

  Future<SubscriptionModel> updateSubscription(SubscriptionModel subscription) async {
    final payload = subscription.toJson();
    final response = await _apiClient.put('/subscriptions/${subscription.id}', data: payload);
    final data = response.data['data'] ?? response.data;
    return SubscriptionModel.fromJson(data as Map<String, dynamic>);
  }

  Future<void> cancelSubscription(int id) async {
    await _apiClient.post('/subscriptions/$id/cancel');
  }

  Future<void> deleteSubscription(int id) async {
    await _apiClient.delete('/subscriptions/$id');
  }
}
