import 'package:equatable/equatable.dart';

class UserAnalytics extends Equatable {
  final int totalUsers;
  final int activeUsers;
  final int newUsersThisMonth;
  final Map<String, int> usersByRole;
  final List<MonthlyData> monthlyGrowth;

  const UserAnalytics({
    required this.totalUsers,
    required this.activeUsers,
    required this.newUsersThisMonth,
    required this.usersByRole,
    required this.monthlyGrowth,
  });

  double get activePercentage =>
      totalUsers > 0 ? (activeUsers / totalUsers) * 100 : 0;

  factory UserAnalytics.fromJson(Map<String, dynamic> json) {
    final growthJson = json['monthly_growth'] as List? ?? json['monthlyGrowth'] as List? ?? [];
    return UserAnalytics(
      totalUsers: json['total_users'] as int? ?? json['totalUsers'] as int? ?? 0,
      activeUsers: json['active_users'] as int? ?? json['activeUsers'] as int? ?? 0,
      newUsersThisMonth: json['new_users_this_month'] as int? ?? json['newUsersThisMonth'] as int? ?? 0,
      usersByRole: Map<String, int>.from(json['users_by_role'] ?? json['usersByRole'] ?? {}),
      monthlyGrowth: growthJson.map((e) => MonthlyData.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  static UserAnalytics dummy = UserAnalytics(
    totalUsers: 1250,
    activeUsers: 980,
    newUsersThisMonth: 85,
    usersByRole: {
      'طلاب': 850,
      'أولياء أمور': 320,
      'مدراء': 80,
    },
    monthlyGrowth: [
      const MonthlyData(month: 'يناير', value: 120),
      const MonthlyData(month: 'فبراير', value: 150),
      const MonthlyData(month: 'مارس', value: 180),
      const MonthlyData(month: 'أبريل', value: 220),
      const MonthlyData(month: 'مايو', value: 200),
      const MonthlyData(month: 'يونيو', value: 170),
      const MonthlyData(month: 'يوليو', value: 140),
      const MonthlyData(month: 'أغسطس', value: 190),
      const MonthlyData(month: 'سبتمبر', value: 260),
      const MonthlyData(month: 'أكتوبر', value: 300),
      const MonthlyData(month: 'نوفمبر', value: 280),
      const MonthlyData(month: 'ديسمبر', value: 250),
    ],
  );

  @override
  List<Object?> get props => [totalUsers, activeUsers, newUsersThisMonth, usersByRole, monthlyGrowth];
}

class ContentAnalytics extends Equatable {
  final int totalLessons;
  final int totalDownloads;
  final List<LessonViewData> mostViewedLessons;
  final Map<String, int> contentByStage;

  const ContentAnalytics({
    required this.totalLessons,
    required this.totalDownloads,
    required this.mostViewedLessons,
    required this.contentByStage,
  });

  factory ContentAnalytics.fromJson(Map<String, dynamic> json) {
    final viewedJson = json['most_viewed_lessons'] as List? ?? json['mostViewedLessons'] as List? ?? [];
    return ContentAnalytics(
      totalLessons: json['total_lessons'] as int? ?? json['totalLessons'] as int? ?? 0,
      totalDownloads: json['total_downloads'] as int? ?? json['totalDownloads'] as int? ?? 0,
      mostViewedLessons: viewedJson.map((e) => LessonViewData.fromJson(e as Map<String, dynamic>)).toList(),
      contentByStage: Map<String, int>.from(json['content_by_stage'] ?? json['contentByStage'] ?? {}),
    );
  }

  static ContentAnalytics dummy = ContentAnalytics(
    totalLessons: 486,
    totalDownloads: 12500,
    mostViewedLessons: [
      const LessonViewData(name: 'أساسيات الجبر', views: 1250),
      const LessonViewData(name: 'قواعد النحو العربي', views: 1100),
      const LessonViewData(name: 'الدوال الرياضية', views: 980),
      const LessonViewData(name: 'المحادثة الإنجليزية', views: 870),
      const LessonViewData(name: 'التاريخ الإسلامي', views: 750),
      const LessonViewData(name: 'الفيزياء الحديثة', views: 680),
      const LessonViewData(name: 'الكيمياء العضوية', views: 620),
    ],
    contentByStage: {
      'ابتدائي': 180,
      'متوسط': 156,
      'ثانوي': 150,
    },
  );

  @override
  List<Object?> get props => [totalLessons, totalDownloads, mostViewedLessons, contentByStage];
}

class RevenueAnalytics extends Equatable {
  final double totalRevenue;
  final List<MonthlyData> monthlyRevenue;
  final Map<String, double> subscriptionBreakdown;

  const RevenueAnalytics({
    required this.totalRevenue,
    required this.monthlyRevenue,
    required this.subscriptionBreakdown,
  });

  factory RevenueAnalytics.fromJson(Map<String, dynamic> json) {
    final revenueJson = json['monthly_revenue'] as List? ?? json['monthlyRevenue'] as List? ?? [];
    return RevenueAnalytics(
      totalRevenue: (json['total_revenue'] as num? ?? json['totalRevenue'] as num? ?? 0.0).toDouble(),
      monthlyRevenue: revenueJson.map((e) => MonthlyData.fromJson(e as Map<String, dynamic>)).toList(),
      subscriptionBreakdown: Map<String, double>.from(json['subscription_breakdown'] ?? json['subscriptionBreakdown'] ?? {}),
    );
  }

  static RevenueAnalytics dummy = RevenueAnalytics(
    totalRevenue: 185000.0,
    monthlyRevenue: [
      const MonthlyData(month: 'يناير', value: 12000),
      const MonthlyData(month: 'فبراير', value: 14500),
      const MonthlyData(month: 'مارس', value: 16200),
      const MonthlyData(month: 'أبريل', value: 18000),
      const MonthlyData(month: 'مايو', value: 15500),
      const MonthlyData(month: 'يونيو', value: 13800),
      const MonthlyData(month: 'يوليو', value: 11200),
      const MonthlyData(month: 'أغسطس', value: 14000),
      const MonthlyData(month: 'سبتمبر', value: 19500),
      const MonthlyData(month: 'أكتوبر', value: 21000),
      const MonthlyData(month: 'نوفمبر', value: 18300),
      const MonthlyData(month: 'ديسمبر', value: 17000),
    ],
    subscriptionBreakdown: {
      'الباقة الذهبية': 85000,
      'الباقة الفضية': 62000,
      'الباقة الأساسية': 38000,
    },
  );

  @override
  List<Object?> get props => [totalRevenue, monthlyRevenue, subscriptionBreakdown];
}

class MonthlyData extends Equatable {
  final String month;
  final double value;

  const MonthlyData({required this.month, required this.value});

  factory MonthlyData.fromJson(Map<String, dynamic> json) {
    return MonthlyData(
      month: json['month'] as String? ?? '',
      value: (json['value'] as num? ?? 0.0).toDouble(),
    );
  }

  @override
  List<Object?> get props => [month, value];
}

class LessonViewData extends Equatable {
  final String name;
  final int views;

  const LessonViewData({required this.name, required this.views});

  factory LessonViewData.fromJson(Map<String, dynamic> json) {
    return LessonViewData(
      name: json['name'] as String? ?? '',
      views: json['views'] as int? ?? 0,
    );
  }

  @override
  List<Object?> get props => [name, views];
}
