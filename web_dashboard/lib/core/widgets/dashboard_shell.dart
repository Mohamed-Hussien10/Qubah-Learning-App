import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_dashboard/core/constants/app_colors.dart';
import 'package:web_dashboard/core/widgets/responsive_layout.dart';
import 'package:web_dashboard/core/widgets/sidebar.dart';
import 'package:web_dashboard/core/widgets/top_navbar.dart';
import 'package:web_dashboard/features/authentication/presentation/manager/auth_cubit.dart';
import 'package:web_dashboard/features/authentication/presentation/manager/auth_state.dart';

/// Main dashboard shell used as the [ShellRoute] builder.
///
/// Provides a responsive sidebar, top navbar, and main content area.
/// Adapts between desktop (persistent sidebar) and mobile (drawer sidebar).
class DashboardShell extends StatefulWidget {
  /// The child route widget to display in the content area.
  final Widget child;

  const DashboardShell({super.key, required this.child});

  @override
  State<DashboardShell> createState() => _DashboardShellState();
}

class _DashboardShellState extends State<DashboardShell> {
  bool _isSidebarCollapsed = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _toggleSidebar() {
    setState(() => _isSidebarCollapsed = !_isSidebarCollapsed);
  }

  void _handleLogout() {
    context.read<AuthCubit>().logout();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMobile = ResponsiveLayout.isMobile(context);
    final isTablet = ResponsiveLayout.isTablet(context);

    // Auto-collapse on tablet
    if (isTablet && !_isSidebarCollapsed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() => _isSidebarCollapsed = true);
        }
      });
    }

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,

      // Mobile drawer
      drawer: isMobile
          ? Drawer(
              width: 280,
              child: Sidebar(
                isCollapsed: false,
                onLogout: _handleLogout,
              ),
            )
          : null,

      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthInitial) {
            context.go('/login');
          }
        },
        child: Row(
          children: [
            // ── Sidebar (desktop & tablet) ─────────────────────────────
            if (!isMobile)
              Sidebar(
                isCollapsed: _isSidebarCollapsed,
                onToggleCollapse: _toggleSidebar,
                onLogout: _handleLogout,
              ),

            // ── Main Content Area ──────────────────────────────────────
            Expanded(
              child: Column(
                children: [
                  // Top Navbar
                  TopNavbar(
                    onMenuTap: isMobile
                        ? () => _scaffoldKey.currentState?.openDrawer()
                        : null,
                    onLogout: _handleLogout,
                  ),

                  // Content
                  Expanded(
                    child: Container(
                      color: isDark
                          ? AppColors.backgroundDark
                          : AppColors.backgroundLight,
                      child: widget.child,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
