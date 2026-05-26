import 'package:equatable/equatable.dart';

/// Aggregate statistics displayed on the dashboard home screen.
class DashboardStats extends Equatable {
  final int totalUsers;
  final int activeSubscriptions;
  final int totalLessons;
  final double totalRevenue;
  final double userGrowthPercent;
  final double revenueGrowthPercent;

  const DashboardStats({
    required this.totalUsers,
    required this.activeSubscriptions,
    required this.totalLessons,
    required this.totalRevenue,
    required this.userGrowthPercent,
    required this.revenueGrowthPercent,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalUsers: json['total_users'] as int? ?? 0,
      activeSubscriptions: json['active_subscriptions'] as int? ?? 0,
      totalLessons: json['total_lessons'] as int? ?? 0,
      totalRevenue: (json['total_revenue'] as num?)?.toDouble() ?? 0.0,
      userGrowthPercent:
          (json['user_growth_percent'] as num?)?.toDouble() ?? 0.0,
      revenueGrowthPercent:
          (json['revenue_growth_percent'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_users': totalUsers,
      'active_subscriptions': activeSubscriptions,
      'total_lessons': totalLessons,
      'total_revenue': totalRevenue,
      'user_growth_percent': userGrowthPercent,
      'revenue_growth_percent': revenueGrowthPercent,
    };
  }

  @override
  List<Object?> get props => [
        totalUsers,
        activeSubscriptions,
        totalLessons,
        totalRevenue,
        userGrowthPercent,
        revenueGrowthPercent,
      ];
}
