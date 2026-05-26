import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:web_dashboard/core/constants/app_colors.dart';
import 'package:web_dashboard/core/constants/app_strings.dart';

/// A navigation item in the sidebar.
class SidebarItem {
  final String label;
  final IconData icon;
  final IconData? activeIcon;
  final String route;

  const SidebarItem({
    required this.label,
    required this.icon,
    this.activeIcon,
    required this.route,
  });
}

/// A section divider with optional label in the sidebar.
class SidebarSection {
  final String? label;
  final List<SidebarItem> items;

  const SidebarSection({
    this.label,
    required this.items,
  });
}

/// Sidebar navigation items definition.
final List<SidebarSection> sidebarSections = [
  // Main
  const SidebarSection(
    items: [
      SidebarItem(
        label: AppStrings.dashboard,
        icon: Icons.dashboard_outlined,
        activeIcon: Icons.dashboard_rounded,
        route: '/dashboard',
      ),
    ],
  ),
  // Educational Management
  const SidebarSection(
    label: 'الإدارة التعليمية',
    items: [
      SidebarItem(
        label: AppStrings.stages,
        icon: Icons.school_outlined,
        activeIcon: Icons.school_rounded,
        route: '/stages',
      ),
      SidebarItem(
        label: AppStrings.grades,
        icon: Icons.grade_outlined,
        activeIcon: Icons.grade_rounded,
        route: '/grades',
      ),
      SidebarItem(
        label: AppStrings.sections,
        icon: Icons.category_outlined,
        activeIcon: Icons.category_rounded,
        route: '/sections',
      ),
      SidebarItem(
        label: AppStrings.subjects,
        icon: Icons.menu_book_outlined,
        activeIcon: Icons.menu_book_rounded,
        route: '/subjects',
      ),
      SidebarItem(
        label: AppStrings.units,
        icon: Icons.folder_outlined,
        activeIcon: Icons.folder_rounded,
        route: '/units',
      ),
      SidebarItem(
        label: AppStrings.lessons,
        icon: Icons.play_lesson_outlined,
        activeIcon: Icons.play_lesson_rounded,
        route: '/lessons',
      ),
      SidebarItem(
        label: AppStrings.lessonFiles,
        icon: Icons.attach_file_outlined,
        activeIcon: Icons.attach_file_rounded,
        route: '/lesson-files',
      ),
    ],
  ),
  // Management
  const SidebarSection(
    label: 'الإدارة',
    items: [
      SidebarItem(
        label: AppStrings.users,
        icon: Icons.people_outline_rounded,
        activeIcon: Icons.people_rounded,
        route: '/users',
      ),
      SidebarItem(
        label: AppStrings.subscriptions,
        icon: Icons.card_membership_outlined,
        activeIcon: Icons.card_membership_rounded,
        route: '/subscriptions',
      ),
      SidebarItem(
        label: AppStrings.notifications,
        icon: Icons.notifications_outlined,
        activeIcon: Icons.notifications_rounded,
        route: '/notifications',
      ),
    ],
  ),
  // Reports & Settings
  const SidebarSection(
    label: 'التقارير والإعدادات',
    items: [
      SidebarItem(
        label: AppStrings.analytics,
        icon: Icons.analytics_outlined,
        activeIcon: Icons.analytics_rounded,
        route: '/analytics',
      ),
      SidebarItem(
        label: AppStrings.settings,
        icon: Icons.settings_outlined,
        activeIcon: Icons.settings_rounded,
        route: '/settings',
      ),
    ],
  ),
];

/// The sidebar widget with logo, navigation items, and logout.
class Sidebar extends StatelessWidget {
  /// Whether the sidebar is collapsed (icon-only mode).
  final bool isCollapsed;

  /// Callback to toggle collapse state.
  final VoidCallback? onToggleCollapse;

  /// Callback when logout is tapped.
  final VoidCallback? onLogout;

  const Sidebar({
    super.key,
    this.isCollapsed = false,
    this.onToggleCollapse,
    this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currentPath = GoRouterState.of(context).uri.toString();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOutCubic,
      width: isCollapsed ? 72 : 280,
      decoration: BoxDecoration(
        color: isDark ? AppColors.sidebarDark : AppColors.sidebarLight,
        border: Border(
          left: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
      ),
      child: Column(
        children: [
          // ── Logo / Brand ──────────────────────────────────────────
          _buildLogo(theme, isDark),

          // ── Navigation Items ──────────────────────────────────────
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: [
                for (final section in sidebarSections) ...[
                  // Section label
                  if (section.label != null && !isCollapsed)
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 20, bottom: 8, right: 12, left: 12),
                      child: Text(
                        section.label!,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: isDark
                              ? AppColors.textTertiaryDark
                              : AppColors.textTertiaryLight,
                          letterSpacing: 0.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  if (section.label != null && isCollapsed)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Divider(
                        color: isDark
                            ? AppColors.borderDark
                            : AppColors.borderLight,
                        indent: 12,
                        endIndent: 12,
                      ),
                    ),

                  // Items
                  for (final item in section.items)
                    _buildNavItem(
                      context,
                      theme,
                      isDark,
                      item,
                      isActive: _isActive(currentPath, item.route),
                    ),
                ],
              ],
            ),
          ),

          // ── Logout ────────────────────────────────────────────────
          _buildLogoutButton(theme, isDark),

          // ── Collapse Toggle ───────────────────────────────────────
          _buildCollapseToggle(theme, isDark),
        ],
      ),
    );
  }

  Widget _buildLogo(ThemeData theme, bool isDark) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
      ),
      child: Row(
        children: [
          // Logo icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.hexagon_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),

          // Logo text
          if (!isCollapsed) ...[
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.appName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    AppStrings.appNameEn,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: isDark
                          ? AppColors.textTertiaryDark
                          : AppColors.textTertiaryLight,
                      fontSize: 10,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    SidebarItem item, {
    required bool isActive,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => context.go(item.route),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(
              horizontal: isCollapsed ? 0 : 12,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: isActive
                  ? AppColors.primary.withValues(alpha: isDark ? 0.15 : 0.08)
                  : Colors.transparent,
            ),
            child: isCollapsed
                ? Tooltip(
                    message: item.label,
                    child: Center(
                      child: Icon(
                        isActive
                            ? (item.activeIcon ?? item.icon)
                            : item.icon,
                        size: 22,
                        color: isActive
                            ? AppColors.primary
                            : (isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight),
                      ),
                    ),
                  )
                : Row(
                    children: [
                      Icon(
                        isActive
                            ? (item.activeIcon ?? item.icon)
                            : item.icon,
                        size: 20,
                        color: isActive
                            ? AppColors.primary
                            : (isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          item.label,
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: isActive
                                ? AppColors.primary
                                : (isDark
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textPrimaryLight),
                            fontWeight:
                                isActive ? FontWeight.w700 : FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Active indicator
                      if (isActive)
                        Container(
                          width: 4,
                          height: 20,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onLogout,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isCollapsed ? 0 : 12,
              vertical: 10,
            ),
            child: isCollapsed
                ? const Tooltip(
                    message: AppStrings.logout,
                    child: Center(
                      child: Icon(
                        Icons.logout_rounded,
                        size: 22,
                        color: AppColors.error,
                      ),
                    ),
                  )
                : Row(
                    children: [
                      const Icon(
                        Icons.logout_rounded,
                        size: 20,
                        color: AppColors.error,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        AppStrings.logout,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: AppColors.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildCollapseToggle(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: IconButton(
        onPressed: onToggleCollapse,
        icon: Icon(
          isCollapsed
              ? Icons.keyboard_double_arrow_left_rounded
              : Icons.keyboard_double_arrow_right_rounded,
          size: 20,
        ),
        tooltip: isCollapsed ? 'توسيع القائمة' : 'طي القائمة',
        style: IconButton.styleFrom(
          backgroundColor: isDark
              ? AppColors.backgroundDark
              : AppColors.backgroundLight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  bool _isActive(String currentPath, String route) {
    if (route == '/dashboard') return currentPath == '/dashboard';
    return currentPath.startsWith(route);
  }
}
