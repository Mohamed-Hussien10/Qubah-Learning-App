import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_dashboard/features/analytics/data/repositories/analytics_repository.dart';
import 'package:web_dashboard/features/analytics/presentation/manager/analytics_state.dart';
import 'package:web_dashboard/core/errors/error_handler.dart';

class AnalyticsCubit extends Cubit<AnalyticsState> {
  final AnalyticsRepository _repository;

  AnalyticsCubit(this._repository) : super(const AnalyticsState());

  Future<void> loadAnalytics() async {
    emit(state.copyWith(status: AnalyticsStatus.loading));
    try {
      final results = await Future.wait([
        _repository.getUserAnalytics(),
        _repository.getContentAnalytics(),
        _repository.getRevenueAnalytics(),
      ]);

      emit(state.copyWith(
        status: AnalyticsStatus.loaded,
        userAnalytics: results[0] as dynamic,
        contentAnalytics: results[1] as dynamic,
        revenueAnalytics: results[2] as dynamic,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AnalyticsStatus.error,
        errorMessage: ErrorHandler.handle(e),
      ));
    }
  }

  Future<void> refreshAnalytics() async {
    await loadAnalytics();
  }
}
