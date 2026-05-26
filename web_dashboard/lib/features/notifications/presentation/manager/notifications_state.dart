import 'package:equatable/equatable.dart';
import 'package:web_dashboard/features/notifications/data/models/notification_model.dart';

enum NotificationsStatus { initial, loading, loaded, sending, error }

class NotificationsState extends Equatable {
  final NotificationsStatus status;
  final List<NotificationModel> notifications;
  final int selectedTabIndex;
  final String? errorMessage;
  final bool sendSuccess;

  const NotificationsState({
    this.status = NotificationsStatus.initial,
    this.notifications = const [],
    this.selectedTabIndex = 0,
    this.errorMessage,
    this.sendSuccess = false,
  });

  List<NotificationModel> get sentNotifications =>
      notifications.where((n) => n.status == NotificationStatus.sent).toList();

  List<NotificationModel> get scheduledNotifications =>
      notifications.where((n) => n.status == NotificationStatus.scheduled).toList();

  List<NotificationModel> get draftNotifications =>
      notifications.where((n) => n.status == NotificationStatus.draft).toList();

  NotificationsState copyWith({
    NotificationsStatus? status,
    List<NotificationModel>? notifications,
    int? selectedTabIndex,
    String? errorMessage,
    bool? sendSuccess,
  }) {
    return NotificationsState(
      status: status ?? this.status,
      notifications: notifications ?? this.notifications,
      selectedTabIndex: selectedTabIndex ?? this.selectedTabIndex,
      errorMessage: errorMessage ?? this.errorMessage,
      sendSuccess: sendSuccess ?? this.sendSuccess,
    );
  }

  @override
  List<Object?> get props => [status, notifications, selectedTabIndex, errorMessage, sendSuccess];
}
