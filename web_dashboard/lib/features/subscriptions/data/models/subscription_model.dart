import 'package:equatable/equatable.dart';

enum SubscriptionStatus { active, expired, cancelled }

class SubscriptionModel extends Equatable {
  final int id;
  final int userId;
  final String userName;
  final String planName;
  final SubscriptionStatus status;
  final DateTime startDate;
  final DateTime endDate;
  final double amount;

  const SubscriptionModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.planName,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.amount,
  });

  String get statusLabel {
    switch (status) {
      case SubscriptionStatus.active:
        return 'نشط';
      case SubscriptionStatus.expired:
        return 'منتهي';
      case SubscriptionStatus.cancelled:
        return 'ملغي';
    }
  }

  bool get isExpired => endDate.isBefore(DateTime.now());

  int get remainingDays {
    final diff = endDate.difference(DateTime.now()).inDays;
    return diff > 0 ? diff : 0;
  }

  SubscriptionModel copyWith({
    int? id,
    int? userId,
    String? userName,
    String? planName,
    SubscriptionStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    double? amount,
  }) {
    return SubscriptionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      planName: planName ?? this.planName,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      amount: amount ?? this.amount,
    );
  }

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      userName: json['user_name'] as String,
      planName: json['plan_name'] as String,
      status: SubscriptionStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => SubscriptionStatus.active,
      ),
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      amount: (json['amount'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'user_name': userName,
      'plan_name': planName,
      'status': status.name,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'amount': amount,
    };
  }

  static List<SubscriptionModel> dummyList = [
    SubscriptionModel(
      id: 1,
      userId: 2,
      userName: 'فاطمة حسن إبراهيم',
      planName: 'الباقة الذهبية',
      status: SubscriptionStatus.active,
      startDate: DateTime(2026, 1, 1),
      endDate: DateTime(2026, 12, 31),
      amount: 499.99,
    ),
    SubscriptionModel(
      id: 2,
      userId: 3,
      userName: 'عمر خالد الصالح',
      planName: 'الباقة الفضية',
      status: SubscriptionStatus.active,
      startDate: DateTime(2026, 3, 1),
      endDate: DateTime(2026, 9, 1),
      amount: 299.99,
    ),
    SubscriptionModel(
      id: 3,
      userId: 4,
      userName: 'مريم عبدالله الشمري',
      planName: 'الباقة الأساسية',
      status: SubscriptionStatus.expired,
      startDate: DateTime(2025, 6, 1),
      endDate: DateTime(2025, 12, 1),
      amount: 99.99,
    ),
    SubscriptionModel(
      id: 4,
      userId: 5,
      userName: 'يوسف سعيد القحطاني',
      planName: 'الباقة الذهبية',
      status: SubscriptionStatus.active,
      startDate: DateTime(2026, 2, 15),
      endDate: DateTime(2027, 2, 15),
      amount: 499.99,
    ),
    SubscriptionModel(
      id: 5,
      userId: 6,
      userName: 'نورة محمد العتيبي',
      planName: 'الباقة الفضية',
      status: SubscriptionStatus.active,
      startDate: DateTime(2026, 4, 1),
      endDate: DateTime(2026, 10, 1),
      amount: 299.99,
    ),
    SubscriptionModel(
      id: 6,
      userId: 7,
      userName: 'سلطان عبدالرحمن الدوسري',
      planName: 'الباقة الأساسية',
      status: SubscriptionStatus.cancelled,
      startDate: DateTime(2025, 11, 1),
      endDate: DateTime(2026, 5, 1),
      amount: 99.99,
    ),
    SubscriptionModel(
      id: 7,
      userId: 8,
      userName: 'هند ناصر الحربي',
      planName: 'الباقة الفضية',
      status: SubscriptionStatus.expired,
      startDate: DateTime(2025, 4, 1),
      endDate: DateTime(2025, 10, 1),
      amount: 299.99,
    ),
    SubscriptionModel(
      id: 8,
      userId: 10,
      userName: 'ريم عادل السبيعي',
      planName: 'الباقة الذهبية',
      status: SubscriptionStatus.active,
      startDate: DateTime(2026, 5, 1),
      endDate: DateTime(2027, 5, 1),
      amount: 499.99,
    ),
  ];

  @override
  List<Object?> get props => [id, userId, userName, planName, status, startDate, endDate, amount];
}
