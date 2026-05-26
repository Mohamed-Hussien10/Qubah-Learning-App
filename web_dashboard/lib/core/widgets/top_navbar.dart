import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:web_dashboard/core/constants/app_colors.dart';
import 'package:web_dashboard/core/constants/app_strings.dart';
import 'package:web_dashboard/core/theme/theme_cubit.dart';

/// Top navigation bar with page title, search, theme toggle, notifications, and user avatar.
class TopNavbar extends StatelessWidget implements PreferredSizeWidget {
  /// Optional callback when menu icon is tapped (mobile drawer toggle).
  final VoidCallback? onMenuTap;

  /// Notification count for the badge.
  final int notificationCount;

  /// User name for the avatar dropdown.
  final String? userName;

  /// User email for the avatar dropdown.
  final String? userEmail;

  /// Callback when profile is selected.
  final VoidCallback? onProfile;

  /// Callback when settings is selected.
  final VoidCallback? onSettings;

  /// Callback when logout is selected.
  final VoidCallback? onLogout;

  const TopNavbar({
    super.key,
    this.onMenuTap,
    this.notificationCount = 0,
    this.userName,
    this.userEmail,
    this.onProfile,
    this.onSettings,
    this.onLogout,
  });

  @override
  Size get preferredSize => const Size.fromHeight(72);

  /// Returns the page title based on the current route.
  String _getPageTitle(BuildContext context) {
    final path = GoRouterState.of(context).uri.toString();

    if (path.startsWith('/dashboard')) return AppStrings.dashboard;
    if (path.startsWith('/stages')) return AppStrings.stages;
    if (path.startsWith('/grades')) return AppStrings.grades;
    if (path.startsWith('/sections')) return AppStrings.sections;
    if (path.startsWith('/subjects')) return AppStrings.subjects;
    if (path.startsWith('/units')) return AppStrings.units;
    if (path.startsWith('/lessons')) return AppStrings.lessons;
    if (path.startsWith('/lesson-files')) return AppStrings.lessonFiles;
    if (path.startsWith('/users')) return AppStrings.users;
    if (path.startsWith('/subscriptions')) return AppStrings.subscriptions;
    if (path.startsWith('/notifications')) return AppStrings.notifications;
    if (path.startsWith('/analytics')) return AppStrings.analytics;
    if (path.startsWith('/settings')) return AppStrings.settings;
    if (path.startsWith('/profile')) return AppStrings.profile;

    return AppStrings.dashboard;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final pageTitle = _getPageTitle(context);

    return Container(
      height: preferredSize.height,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
      ),
      child: Row(
        children: [
          // ── Menu icon (mobile) ───────────────────────────────────
          if (onMenuTap != null) ...[
            IconButton(
              onPressed: onMenuTap,
              icon: const Icon(Icons.menu_rounded),
              tooltip: 'القائمة',
            ),
            const SizedBox(width: 8),
          ],

          // ── Page Title ──────────────────────────────────────────
          Text(
            pageTitle,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),

          const Spacer(),

          // ── Search Bar ──────────────────────────────────────────
          SizedBox(
            width: 260,
            child: TextField(
              decoration: InputDecoration(
                hintText: AppStrings.search,
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                filled: true,
                fillColor: isDark
                    ? AppColors.backgroundDark
                    : AppColors.backgroundLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          const SizedBox(width: 16),

          // ── Theme Toggle ────────────────────────────────────────
          BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (context, themeMode) {
              return IconButton(
                onPressed: () =>
                    context.read<ThemeCubit>().toggleTheme(),
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Icon(
                    isDark
                        ? Icons.light_mode_rounded
                        : Icons.dark_mode_rounded,
                    key: ValueKey(isDark),
                    size: 22,
                  ),
                ),
                tooltip: isDark ? 'الوضع الفاتح' : 'الوضع الداكن',
                style: IconButton.styleFrom(
                  backgroundColor: isDark
                      ? AppColors.backgroundDark
                      : AppColors.backgroundLight,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            },
          ),

          const SizedBox(width: 8),

          // ── Notifications ───────────────────────────────────────
          Stack(
            children: [
              IconButton(
                onPressed: () => context.go('/notifications'),
                icon: const Icon(Icons.notifications_outlined, size: 22),
                tooltip: AppStrings.notifications,
                style: IconButton.styleFrom(
                  backgroundColor: isDark
                      ? AppColors.backgroundDark
                      : AppColors.backgroundLight,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              if (notificationCount > 0)
                Positioned(
                  top: 4,
                  left: 4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    decoration: const BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      notificationCount > 99
                          ? '99+'
                          : notificationCount.toString(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(width: 12),

          // ── Divider ─────────────────────────────────────────────
          Container(
            width: 1,
            height: 32,
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),

          const SizedBox(width: 12),

          // ── User Avatar Dropdown ────────────────────────────────
          PopupMenuButton<String>(
            offset: const Offset(0, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onSelected: (value) {
              switch (value) {
                case 'profile':
                  onProfile?.call();
                  if (onProfile == null) context.go('/profile');
                  break;
                case 'settings':
                  onSettings?.call();
                  if (onSettings == null) context.go('/settings');
                  break;
                case 'logout':
                  onLogout?.call();
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                enabled: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName ?? 'المدير',
                      style: theme.textTheme.titleSmall,
                    ),
                    Text(
                      userEmail ?? 'admin@qubah.app',
                      style: theme.textTheme.labelSmall,
                    ),
                    const SizedBox(height: 8),
                    Divider(
                      color: isDark
                          ? AppColors.borderDark
                          : AppColors.borderLight,
                    ),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person_outline_rounded, size: 20),
                    SizedBox(width: 12),
                    Text(AppStrings.profile),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings_outlined, size: 20),
                    SizedBox(width: 12),
                    Text(AppStrings.settings),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    const Icon(
                      Icons.logout_rounded,
                      size: 20,
                      color: AppColors.error,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      AppStrings.logout,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Avatar
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryLight],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      (userName ?? 'م').characters.first,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // Name & arrow
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName ?? 'المدير',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      'مدير النظام',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),

                const SizedBox(width: 4),

                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 18,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
