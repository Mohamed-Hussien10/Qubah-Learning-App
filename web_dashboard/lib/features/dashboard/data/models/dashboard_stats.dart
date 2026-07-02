import 'package:equatable/equatable.dart';

/// Aggregate statistics displayed on the dashboard home screen.
class DashboardStats extends Equatable {
  final int totalUsers;
  final int totalLessons;
  final double userGrowthPercent;

  const DashboardStats({
    required this.totalUsers,
    required this.totalLessons,
    required this.userGrowthPercent,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalUsers: json['total_users'] as int? ?? 0,
      totalLessons: json['total_lessons'] as int? ?? 0,
      userGrowthPercent:
          (json['user_growth_percent'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_users': totalUsers,
      'total_lessons': totalLessons,
      'user_growth_percent': userGrowthPercent,
    };
  }

  @override
  List<Object?> get props => [
        totalUsers,
        totalLessons,
        userGrowthPercent,
      ];
}
