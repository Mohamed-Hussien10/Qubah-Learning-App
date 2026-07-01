import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:web_dashboard/features/dashboard/data/repositories/dashboard_repository.dart';
import 'package:web_dashboard/features/dashboard/presentation/manager/dashboard_state.dart';
import 'package:web_dashboard/core/errors/error_handler.dart';

/// Cubit managing dashboard home screen state.
class DashboardCubit extends Cubit<DashboardState> {
  final DashboardRepository _repository;

  DashboardCubit({required DashboardRepository repository})
      : _repository = repository,
        super(const DashboardInitial());

  /// Load all dashboard data concurrently.
  Future<void> loadDashboard() async {
    emit(const DashboardLoading());

    try {
      // Fetch all data in parallel for faster loading
      final results = await Future.wait([
        _repository.getStats(),
        _repository.getRevenueData(),
        _repository.getUserGrowthData(),
        _repository.getRecentActivity(),
      ]);

      if (!isClosed) {
        emit(DashboardLoaded(
          stats: results[0] as dynamic,
          revenueData: results[1] as dynamic,
          userGrowthData: results[2] as dynamic,
          recentActivity: results[3] as dynamic,
        ));
      }
    } catch (e) {
      if (!isClosed) {
        emit(DashboardError(
          message: ErrorHandler.handle(e),
        ));
      }
    }
  }

  /// Refresh dashboard data (same as load, but can be called again).
  Future<void> refresh() => loadDashboard();
}
