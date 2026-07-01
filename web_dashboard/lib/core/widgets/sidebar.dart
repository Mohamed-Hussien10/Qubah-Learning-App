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
  // Educational Management
  const SidebarSection(
    label: 'الإدارة التعليمية',
    items: [
      SidebarItem(
        label: AppStrings.stages,
        icon: Icons.account_balance_outlined,
        activeIcon: Icons.account_balance_rounded,
        route: '/stages',
      ),
      SidebarItem(
        label: AppStrings.grades,
        icon: Icons.layers_outlined,
        activeIcon: Icons.layers_rounded,
        route: '/grades',
      ),
      SidebarItem(
        label: AppStrings.sections,
        icon: Icons.grid_view_outlined,
        activeIcon: Icons.grid_view_rounded,
        route: '/sections',
      ),
      SidebarItem(
        label: AppStrings.subjects,
        icon: Icons.library_books_outlined,
        activeIcon: Icons.library_books_rounded,
        route: '/subjects',
      ),
      SidebarItem(
        label: AppStrings.units,
        icon: Icons.view_module_outlined,
        activeIcon: Icons.view_module_rounded,
        route: '/units',
      ),
      SidebarItem(
        label: AppStrings.lessons,
        icon: Icons.smart_display_outlined,
        activeIcon: Icons.smart_display_rounded,
        route: '/lessons',
      ),
      SidebarItem(
        label: AppStrings.lessonFiles,
        icon: Icons.snippet_folder_outlined,
        activeIcon: Icons.snippet_folder_rounded,
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
        icon: Icons.groups_outlined,
        activeIcon: Icons.groups_rounded,
        route: '/users',
      ),
    ],
  ),
  // Reports & Settings
  const SidebarSection(
    label: 'التقارير والإعدادات',
    items: [
      SidebarItem(
        label: AppStrings.settings,
        icon: Icons.admin_panel_settings_outlined,
        activeIcon: Icons.admin_panel_settings_rounded,
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
          // Logo image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              'assets/images/logo.png',
              width: 40,
              height: 40,
              fit: BoxFit.contain,
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
