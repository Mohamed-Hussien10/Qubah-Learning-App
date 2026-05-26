import 'package:equatable/equatable.dart';
import 'package:web_dashboard/features/subscriptions/data/models/subscription_model.dart';
import 'package:web_dashboard/features/subscriptions/data/models/plan_model.dart';

enum SubscriptionsStatus { initial, loading, loaded, error }

class SubscriptionsState extends Equatable {
  final SubscriptionsStatus status;
  final List<SubscriptionModel> subscriptions;
  final List<PlanModel> plans;
  final int selectedTabIndex;
  final String? errorMessage;

  const SubscriptionsState({
    this.status = SubscriptionsStatus.initial,
    this.subscriptions = const [],
    this.plans = const [],
    this.selectedTabIndex = 0,
    this.errorMessage,
  });

  int get activeSubscriptionsCount =>
      subscriptions.where((s) => s.status == SubscriptionStatus.active).length;

  int get expiredSubscriptionsCount =>
      subscriptions.where((s) => s.status == SubscriptionStatus.expired).length;

  double get totalRevenue =>
      subscriptions
          .where((s) => s.status == SubscriptionStatus.active)
          .fold(0.0, (sum, s) => sum + s.amount);

  SubscriptionsState copyWith({
    SubscriptionsStatus? status,
    List<SubscriptionModel>? subscriptions,
    List<PlanModel>? plans,
    int? selectedTabIndex,
    String? errorMessage,
  }) {
    return SubscriptionsState(
      status: status ?? this.status,
      subscriptions: subscriptions ?? this.subscriptions,
      plans: plans ?? this.plans,
      selectedTabIndex: selectedTabIndex ?? this.selectedTabIndex,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, subscriptions, plans, selectedTabIndex, errorMessage];
}
