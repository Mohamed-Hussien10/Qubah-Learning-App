import 'package:equatable/equatable.dart';

enum NotificationTargetType { all, stage, grade }

enum NotificationStatus { sent, scheduled, draft }

class NotificationModel extends Equatable {
  final int id;
  final String title;
  final String body;
  final NotificationTargetType targetType;
  final int? targetId;
  final NotificationStatus status;
  final DateTime? sentAt;
  final DateTime createdAt;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.targetType,
    this.targetId,
    required this.status,
    this.sentAt,
    required this.createdAt,
  });

  String get targetTypeLabel {
    switch (targetType) {
      case NotificationTargetType.all:
        return 'الجميع';
      case NotificationTargetType.stage:
        return 'مرحلة محددة';
      case NotificationTargetType.grade:
        return 'صف محدد';
    }
  }

  String get statusLabel {
    switch (status) {
      case NotificationStatus.sent:
        return 'مرسل';
      case NotificationStatus.scheduled:
        return 'مجدول';
      case NotificationStatus.draft:
        return 'مسودة';
    }
  }

  NotificationModel copyWith({
    int? id,
    String? title,
    String? body,
    NotificationTargetType? targetType,
    int? targetId,
    NotificationStatus? status,
    DateTime? sentAt,
    DateTime? createdAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      targetType: targetType ?? this.targetType,
      targetId: targetId ?? this.targetId,
      status: status ?? this.status,
      sentAt: sentAt ?? this.sentAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as int,
      title: json['title'] as String,
      body: json['body'] as String,
      targetType: NotificationTargetType.values.firstWhere(
        (e) => e.name == json['target_type'],
        orElse: () => NotificationTargetType.all,
      ),
      targetId: json['target_id'] as int?,
      status: NotificationStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => NotificationStatus.draft,
      ),
      sentAt: json['sent_at'] != null
          ? DateTime.parse(json['sent_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'target_type': targetType.name,
      'target_id': targetId,
      'status': status.name,
      'sent_at': sentAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  static List<NotificationModel> dummyList = [
    NotificationModel(
      id: 1,
      title: 'تحديث المنهج الدراسي',
      body: 'تم تحديث المنهج الدراسي للمرحلة الابتدائية. يرجى الاطلاع على التغييرات الجديدة.',
      targetType: NotificationTargetType.stage,
      targetId: 1,
      status: NotificationStatus.sent,
      sentAt: DateTime(2026, 5, 25, 10, 0),
      createdAt: DateTime(2026, 5, 25, 9, 30),
    ),
    NotificationModel(
      id: 2,
      title: 'إضافة دروس جديدة',
      body: 'تمت إضافة مجموعة جديدة من الدروس في مادة الرياضيات للصف الرابع.',
      targetType: NotificationTargetType.grade,
      targetId: 4,
      status: NotificationStatus.sent,
      sentAt: DateTime(2026, 5, 24, 14, 0),
      createdAt: DateTime(2026, 5, 24, 13, 30),
    ),
    NotificationModel(
      id: 3,
      title: 'عرض خاص على الاشتراكات',
      body: 'احصل على خصم 30% على جميع الباقات السنوية! العرض ساري حتى نهاية الشهر.',
      targetType: NotificationTargetType.all,
      status: NotificationStatus.sent,
      sentAt: DateTime(2026, 5, 20, 8, 0),
      createdAt: DateTime(2026, 5, 19, 16, 0),
    ),
    NotificationModel(
      id: 4,
      title: 'صيانة مجدولة',
      body: 'سيتم إجراء صيانة مجدولة يوم السبت القادم من الساعة 2 إلى 4 صباحاً.',
      targetType: NotificationTargetType.all,
      status: NotificationStatus.scheduled,
      createdAt: DateTime(2026, 5, 26, 11, 0),
    ),
    NotificationModel(
      id: 5,
      title: 'مرحباً بالطلاب الجدد',
      body: 'نرحب بجميع الطلاب الجدد في منصة قبة التعليمية. نتمنى لكم تجربة تعليمية ممتعة.',
      targetType: NotificationTargetType.all,
      status: NotificationStatus.draft,
      createdAt: DateTime(2026, 5, 26, 12, 0),
    ),
    NotificationModel(
      id: 6,
      title: 'نتائج الاختبارات',
      body: 'تم رفع نتائج الاختبارات الشهرية. يمكنكم الاطلاع عليها من خلال التطبيق.',
      targetType: NotificationTargetType.all,
      status: NotificationStatus.sent,
      sentAt: DateTime(2026, 5, 18, 9, 0),
      createdAt: DateTime(2026, 5, 18, 8, 0),
    ),
  ];

  @override
  List<Object?> get props => [id, title, body, targetType, targetId, status, sentAt, createdAt];
}
