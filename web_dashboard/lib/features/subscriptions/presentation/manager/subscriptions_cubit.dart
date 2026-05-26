import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_dashboard/features/subscriptions/data/models/plan_model.dart';
import 'package:web_dashboard/features/subscriptions/data/repositories/subscriptions_repository.dart';
import 'package:web_dashboard/features/subscriptions/presentation/manager/subscriptions_state.dart';

class SubscriptionsCubit extends Cubit<SubscriptionsState> {
  final SubscriptionsRepository _repository;

  SubscriptionsCubit(this._repository) : super(const SubscriptionsState());

  Future<void> loadAll() async {
    emit(state.copyWith(status: SubscriptionsStatus.loading));
    try {
      final subscriptions = await _repository.getAllSubscriptions();
      final plans = await _repository.getAllPlans();
      emit(state.copyWith(
        status: SubscriptionsStatus.loaded,
        subscriptions: subscriptions,
        plans: plans,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: SubscriptionsStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  void changeTab(int index) {
    emit(state.copyWith(selectedTabIndex: index));
  }

  Future<void> createPlan(PlanModel plan) async {
    try {
      await _repository.createPlan(plan);
      await loadAll();
    } catch (e) {
      emit(state.copyWith(
        status: SubscriptionsStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> updatePlan(PlanModel plan) async {
    try {
      await _repository.updatePlan(plan);
      await loadAll();
    } catch (e) {
      emit(state.copyWith(
        status: SubscriptionsStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> deletePlan(int id) async {
    try {
      await _repository.deletePlan(id);
      await loadAll();
    } catch (e) {
      emit(state.copyWith(
        status: SubscriptionsStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> assignSubscription({
    required int userId,
    required String userName,
    required String planName,
    required DateTime startDate,
    required DateTime endDate,
    required double amount,
  }) async {
    try {
      await _repository.assignSubscription(
        userId: userId,
        userName: userName,
        planName: planName,
        startDate: startDate,
        endDate: endDate,
        amount: amount,
      );
      await loadAll();
    } catch (e) {
      emit(state.copyWith(
        status: SubscriptionsStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> cancelSubscription(int id) async {
    try {
      await _repository.cancelSubscription(id);
      await loadAll();
    } catch (e) {
      emit(state.copyWith(
        status: SubscriptionsStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }
}
