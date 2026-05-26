import 'package:equatable/equatable.dart';
import 'package:web_dashboard/features/analytics/data/models/analytics_data.dart';

enum AnalyticsStatus { initial, loading, loaded, error }

class AnalyticsState extends Equatable {
  final AnalyticsStatus status;
  final UserAnalytics? userAnalytics;
  final ContentAnalytics? contentAnalytics;
  final RevenueAnalytics? revenueAnalytics;
  final String? errorMessage;

  const AnalyticsState({
    this.status = AnalyticsStatus.initial,
    this.userAnalytics,
    this.contentAnalytics,
    this.revenueAnalytics,
    this.errorMessage,
  });

  AnalyticsState copyWith({
    AnalyticsStatus? status,
    UserAnalytics? userAnalytics,
    ContentAnalytics? contentAnalytics,
    RevenueAnalytics? revenueAnalytics,
    String? errorMessage,
  }) {
    return AnalyticsState(
      status: status ?? this.status,
      userAnalytics: userAnalytics ?? this.userAnalytics,
      contentAnalytics: contentAnalytics ?? this.contentAnalytics,
      revenueAnalytics: revenueAnalytics ?? this.revenueAnalytics,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, userAnalytics, contentAnalytics, revenueAnalytics, errorMessage];
}
