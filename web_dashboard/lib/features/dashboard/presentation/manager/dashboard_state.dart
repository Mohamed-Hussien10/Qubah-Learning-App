import 'package:equatable/equatable.dart';

import 'package:web_dashboard/features/dashboard/data/models/chart_data.dart';
import 'package:web_dashboard/features/dashboard/data/models/dashboard_stats.dart';

/// Base class for all dashboard states.
abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

/// Initial state – data has not been fetched yet.
class DashboardInitial extends DashboardState {
  const DashboardInitial();
}

/// Data is being loaded from the repository.
class DashboardLoading extends DashboardState {
  const DashboardLoading();
}

class DashboardLoaded extends DashboardState {
  final DashboardStats stats;
  final List<ChartData> userGrowthData;
  final List<Map<String, dynamic>> recentActivity;

  const DashboardLoaded({
    required this.stats,
    required this.userGrowthData,
    required this.recentActivity,
  });

  @override
  List<Object?> get props => [stats, userGrowthData, recentActivity];
}

/// An error occurred while fetching dashboard data.
class DashboardError extends DashboardState {
  final String message;

  const DashboardError({required this.message});

  @override
  List<Object?> get props => [message];
}
