import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' as intl;
import 'package:web_dashboard/core/constants/app_colors.dart';
import 'package:web_dashboard/core/constants/app_strings.dart';
import 'package:web_dashboard/features/notifications/data/models/notification_model.dart';
import 'package:web_dashboard/features/notifications/presentation/manager/notifications_cubit.dart';
import 'package:web_dashboard/core/services/dependency_injection.dart';
import 'package:web_dashboard/features/notifications/presentation/manager/notifications_state.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<NotificationsCubit>()..loadNotifications(),
      child: const _NotificationsScreenBody(),
    );
  }
}

class _NotificationsScreenBody extends StatelessWidget {
  const _NotificationsScreenBody();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, isDark),
              const SizedBox(height: 24),
              _buildTabs(context, isDark),
              const SizedBox(height: 16),
              Expanded(
                child: BlocBuilder<NotificationsCubit, NotificationsState>(
                  builder: (context, state) {
                    if (state.status == NotificationsStatus.loading) {
                      return _buildLoadingShimmer(isDark);
                    }
                    if (state.status == NotificationsStatus.error) {
                      return _buildErrorState(context, isDark, state.errorMessage ?? AppStrings.generalError);
                    }
                    return state.selectedTabIndex == 0
                        ? _buildHistoryTab(context, state, isDark)
                        : _buildCreateTab(context, state, isDark);
                  },
                ),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.02, end: 0),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.notifications,
              style: GoogleFonts.cairo(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 4),
            BlocBuilder<NotificationsCubit, NotificationsState>(
              builder: (context, state) {
                return Text(
                  '${state.sentNotifications.length} مرسل • ${state.scheduledNotifications.length} مجدول • ${state.draftNotifications.length} مسودة',
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                );
              },
            ),
          ],
        ),
        const Spacer(),
        IconButton(
          onPressed: () => context.read<NotificationsCubit>().loadNotifications(),
          icon: const Icon(Icons.refresh),
          tooltip: AppStrings.refresh,
          style: IconButton.styleFrom(
            backgroundColor: isDark ? AppColors.cardDark : AppColors.cardLight,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight),
            ),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 100.ms, duration: 400.ms);
  }

  Widget _buildTabs(BuildContext context, bool isDark) {
    return BlocBuilder<NotificationsCubit, NotificationsState>(
      builder: (context, state) {
        return Row(
          children: [
            _buildTab(context, 'السجل', Icons.history, 0, state.selectedTabIndex, isDark),
            const SizedBox(width: 8),
            _buildTab(context, 'إنشاء جديد', Icons.add_circle_outline, 1, state.selectedTabIndex, isDark),
          ],
        );
      },
    ).animate().fadeIn(delay: 200.ms, duration: 400.ms);
  }

  Widget _buildTab(BuildContext context, String label, IconData icon, int index, int selected, bool isDark) {
    final isSelected = index == selected;
    return InkWell(
      onTap: () => context.read<NotificationsCubit>().changeTab(index),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : (isDark ? AppColors.cardDark : AppColors.cardLight),
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? null
              : Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: isSelected ? Colors.white : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryTab(BuildContext context, NotificationsState state, bool isDark) {
    if (state.notifications.isEmpty) {
      return _buildEmptyState(isDark);
    }

    return ListView.builder(
      itemCount: state.notifications.length,
      itemBuilder: (context, index) {
        final notification = state.notifications[index];
        return _buildNotificationCard(context, notification, isDark, index);
      },
    );
  }

  Widget _buildNotificationCard(BuildContext context, NotificationModel notification, bool isDark, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getStatusColor(notification.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _getStatusIcon(notification.status),
                  size: 20,
                  color: _getStatusColor(notification.status),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      notification.body,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.cairo(
                        fontSize: 13,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildStatusBadge(notification.status),
                  const SizedBox(height: 4),
                  Text(
                    notification.sentAt != null
                        ? intl.DateFormat('yyyy/MM/dd HH:mm').format(notification.sentAt!)
                        : intl.DateFormat('yyyy/MM/dd HH:mm').format(notification.createdAt),
                    style: GoogleFonts.cairo(
                      fontSize: 11,
                      color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'الهدف: ${notification.targetTypeLabel}',
                  style: GoogleFonts.cairo(fontSize: 11, color: AppColors.info, fontWeight: FontWeight.w600),
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => context.read<NotificationsCubit>().deleteNotification(notification.id),
                icon: const Icon(Icons.delete_outline, size: 18),
                tooltip: AppStrings.delete,
                style: IconButton.styleFrom(foregroundColor: AppColors.error),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: (300 + index * 80).ms, duration: 400.ms).slideX(begin: 0.03, end: 0);
  }

  Widget _buildStatusBadge(NotificationStatus status) {
    Color color;
    String label;
    switch (status) {
      case NotificationStatus.sent:
        color = AppColors.success;
        label = 'مرسل';
        break;
      case NotificationStatus.scheduled:
        color = AppColors.warning;
        label = 'مجدول';
        break;
      case NotificationStatus.draft:
        color = AppColors.info;
        label = 'مسودة';
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
    );
  }

  Color _getStatusColor(NotificationStatus status) {
    switch (status) {
      case NotificationStatus.sent:
        return AppColors.success;
      case NotificationStatus.scheduled:
        return AppColors.warning;
      case NotificationStatus.draft:
        return AppColors.info;
    }
  }

  IconData _getStatusIcon(NotificationStatus status) {
    switch (status) {
      case NotificationStatus.sent:
        return Icons.check_circle;
      case NotificationStatus.scheduled:
        return Icons.schedule;
      case NotificationStatus.draft:
        return Icons.edit_note;
    }
  }

  Widget _buildCreateTab(BuildContext context, NotificationsState state, bool isDark) {
    return _CreateNotificationForm(isDark: isDark);
  }

  Widget _buildLoadingShimmer(bool isDark) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Shimmer.fromColors(
        baseColor: isDark ? AppColors.cardDark : Colors.grey[300]!,
        highlightColor: isDark ? AppColors.surfaceDark : Colors.grey[100]!,
        child: Column(
          children: List.generate(4, (i) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          )),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none, size: 80,
            color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight),
          const SizedBox(height: 16),
          Text(AppStrings.noData, style: GoogleFonts.cairo(
            fontSize: 18, fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          )),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildErrorState(BuildContext context, bool isDark, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 80, color: AppColors.error.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(message, style: GoogleFonts.cairo(fontSize: 16,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => context.read<NotificationsCubit>().loadNotifications(),
            icon: const Icon(Icons.refresh),
            label: Text(AppStrings.refresh, style: GoogleFonts.cairo()),
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
          ),
        ],
      ),
    );
  }
}

class _CreateNotificationForm extends StatefulWidget {
  final bool isDark;
  const _CreateNotificationForm({required this.isDark});

  @override
  State<_CreateNotificationForm> createState() => _CreateNotificationFormState();
}

class _CreateNotificationFormState extends State<_CreateNotificationForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();
  NotificationTargetType _targetType = NotificationTargetType.all;
  bool _isScheduled = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;

    return BlocListener<NotificationsCubit, NotificationsState>(
      listener: (context, state) {
        if (state.sendSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('تم إرسال الإشعار بنجاح', style: GoogleFonts.cairo()),
              backgroundColor: AppColors.success,
            ),
          );
          _titleCtrl.clear();
          _bodyCtrl.clear();
          setState(() {
            _targetType = NotificationTargetType.all;
            _isScheduled = false;
          });
        }
      },
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : AppColors.cardLight,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'إنشاء إشعار جديد',
                  style: GoogleFonts.cairo(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 24),

                // Title
                Text('عنوان الإشعار', style: GoogleFonts.cairo(
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                )),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _titleCtrl,
                  style: GoogleFonts.cairo(color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                  decoration: _inputDecoration('أدخل عنوان الإشعار', isDark),
                  validator: (v) => v == null || v.trim().isEmpty ? 'العنوان مطلوب' : null,
                ),
                const SizedBox(height: 16),

                // Body
                Text('محتوى الإشعار', style: GoogleFonts.cairo(
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                )),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _bodyCtrl,
                  maxLines: 5,
                  style: GoogleFonts.cairo(color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                  decoration: _inputDecoration('أدخل محتوى الإشعار', isDark),
                  validator: (v) => v == null || v.trim().isEmpty ? 'المحتوى مطلوب' : null,
                ),
                const SizedBox(height: 16),

                // Target
                Text('الجمهور المستهدف', style: GoogleFonts.cairo(
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                )),
                const SizedBox(height: 8),
                DropdownButtonFormField<NotificationTargetType>(
                  value: _targetType,
                  style: GoogleFonts.cairo(color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                  decoration: _inputDecoration(null, isDark),
                  dropdownColor: isDark ? AppColors.cardDark : AppColors.cardLight,
                  items: [
                    DropdownMenuItem(
                      value: NotificationTargetType.all,
                      child: Text('الجميع', style: GoogleFonts.cairo()),
                    ),
                    DropdownMenuItem(
                      value: NotificationTargetType.stage,
                      child: Text('مرحلة محددة', style: GoogleFonts.cairo()),
                    ),
                    DropdownMenuItem(
                      value: NotificationTargetType.grade,
                      child: Text('صف محدد', style: GoogleFonts.cairo()),
                    ),
                  ],
                  onChanged: (v) {
                    if (v != null) setState(() => _targetType = v);
                  },
                ),
                const SizedBox(height: 16),

                // Schedule toggle
                Row(
                  children: [
                    Text('جدولة الإرسال', style: GoogleFonts.cairo(
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    )),
                    const Spacer(),
                    Switch(
                      value: _isScheduled,
                      onChanged: (v) => setState(() => _isScheduled = v),
                      activeColor: AppColors.primary,
                    ),
                  ],
                ),
                if (_isScheduled) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.infoBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, size: 18, color: AppColors.info),
                        const SizedBox(width: 8),
                        Text(
                          'سيتم جدولة الإشعار للإرسال لاحقاً',
                          style: GoogleFonts.cairo(fontSize: 13, color: AppColors.info),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 28),

                // Actions
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          if (!_formKey.currentState!.validate()) return;
                          context.read<NotificationsCubit>().saveDraft(
                            title: _titleCtrl.text.trim(),
                            body: _bodyCtrl.text.trim(),
                            targetType: _targetType,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('تم حفظ المسودة', style: GoogleFonts.cairo()),
                              backgroundColor: AppColors.info,
                            ),
                          );
                        },
                        icon: const Icon(Icons.save_outlined, size: 18),
                        label: Text('حفظ كمسودة', style: GoogleFonts.cairo()),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: BlocBuilder<NotificationsCubit, NotificationsState>(
                        builder: (context, state) {
                          final isSending = state.status == NotificationsStatus.sending;
                          return FilledButton.icon(
                            onPressed: isSending
                                ? null
                                : () {
                                    if (!_formKey.currentState!.validate()) return;
                                    if (_isScheduled) {
                                      context.read<NotificationsCubit>().scheduleNotification(
                                        title: _titleCtrl.text.trim(),
                                        body: _bodyCtrl.text.trim(),
                                        targetType: _targetType,
                                      );
                                    } else {
                                      context.read<NotificationsCubit>().sendNotification(
                                        title: _titleCtrl.text.trim(),
                                        body: _bodyCtrl.text.trim(),
                                        targetType: _targetType,
                                      );
                                    }
                                  },
                            icon: isSending
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : Icon(_isScheduled ? Icons.schedule_send : Icons.send, size: 18),
                            label: Text(
                              isSending
                                  ? 'جاري الإرسال...'
                                  : (_isScheduled ? 'جدولة الإرسال' : 'إرسال الآن'),
                              style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                            ),
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ).animate().fadeIn(delay: 300.ms, duration: 400.ms),
      ),
    );
  }

  InputDecoration _inputDecoration(String? hint, bool isDark) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.cairo(color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight),
      filled: true,
      fillColor: isDark ? AppColors.surfaceDark : AppColors.backgroundLight,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}
