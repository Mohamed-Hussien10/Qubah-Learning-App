import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_dashboard/features/notifications/data/models/notification_model.dart';
import 'package:web_dashboard/features/notifications/data/repositories/notifications_repository.dart';
import 'package:web_dashboard/features/notifications/presentation/manager/notifications_state.dart';
import 'package:web_dashboard/core/errors/error_handler.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  final NotificationsRepository _repository;

  NotificationsCubit(this._repository) : super(const NotificationsState());

  Future<void> loadNotifications() async {
    emit(state.copyWith(status: NotificationsStatus.loading));
    try {
      final notifications = await _repository.getAll();
      emit(state.copyWith(
        status: NotificationsStatus.loaded,
        notifications: notifications,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: NotificationsStatus.error,
        errorMessage: ErrorHandler.handle(e),
      ));
    }
  }

  void changeTab(int index) {
    emit(state.copyWith(selectedTabIndex: index, sendSuccess: false));
  }

  Future<void> sendNotification({
    required String title,
    required String body,
    required NotificationTargetType targetType,
    int? targetId,
  }) async {
    emit(state.copyWith(status: NotificationsStatus.sending));
    try {
      await _repository.create(
        title: title,
        body: body,
        targetType: targetType,
        targetId: targetId,
        status: NotificationStatus.sent,
        sentAt: DateTime.now(),
      );
      await loadNotifications();
      emit(state.copyWith(sendSuccess: true));
    } catch (e) {
      emit(state.copyWith(
        status: NotificationsStatus.error,
        errorMessage: ErrorHandler.handle(e),
      ));
    }
  }

  Future<void> scheduleNotification({
    required String title,
    required String body,
    required NotificationTargetType targetType,
    int? targetId,
  }) async {
    emit(state.copyWith(status: NotificationsStatus.sending));
    try {
      await _repository.create(
        title: title,
        body: body,
        targetType: targetType,
        targetId: targetId,
        status: NotificationStatus.scheduled,
      );
      await loadNotifications();
      emit(state.copyWith(sendSuccess: true));
    } catch (e) {
      emit(state.copyWith(
        status: NotificationsStatus.error,
        errorMessage: ErrorHandler.handle(e),
      ));
    }
  }

  Future<void> saveDraft({
    required String title,
    required String body,
    required NotificationTargetType targetType,
    int? targetId,
  }) async {
    try {
      await _repository.create(
        title: title,
        body: body,
        targetType: targetType,
        targetId: targetId,
        status: NotificationStatus.draft,
      );
      await loadNotifications();
    } catch (e) {
      emit(state.copyWith(
        status: NotificationsStatus.error,
        errorMessage: ErrorHandler.handle(e),
      ));
    }
  }

  Future<void> deleteNotification(int id) async {
    try {
      await _repository.delete(id);
      await loadNotifications();
    } catch (e) {
      emit(state.copyWith(
        status: NotificationsStatus.error,
        errorMessage: ErrorHandler.handle(e),
      ));
    }
  }
}
