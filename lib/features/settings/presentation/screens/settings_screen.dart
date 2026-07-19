import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/routing/app_router.dart';
import '../../../theme/presentation/manager/cubit/theme_cubit.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _showThemeDialog(BuildContext context) {
    final themeCubit = context.read<ThemeCubit>();
    final currentMode = themeCubit.state;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'اختر مظهر التطبيق',
            style: GoogleFonts.cairo(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
            textAlign: TextAlign.right,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<ThemeMode>(
                title: Text(
                  'فاتح',
                  style: GoogleFonts.cairo(color: isDark ? Colors.white : Colors.black87),
                ),
                activeColor: AppColors.primary,
                value: ThemeMode.light,
                groupValue: currentMode,
                onChanged: (mode) {
                  if (mode != null) themeCubit.setThemeMode(mode);
                  Navigator.pop(context);
                },
              ),
              RadioListTile<ThemeMode>(
                title: Text(
                  'داكن',
                  style: GoogleFonts.cairo(color: isDark ? Colors.white : Colors.black87),
                ),
                activeColor: AppColors.primary,
                value: ThemeMode.dark,
                groupValue: currentMode,
                onChanged: (mode) {
                  if (mode != null) themeCubit.setThemeMode(mode);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeMode) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            title: Text(
              'الإعدادات',
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
            centerTitle: true,
            iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black87),
          ),
          body: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            children: [
              _buildSectionHeader(context, 'الحساب'),
              const SizedBox(height: 12),
              _buildSettingsCard(context, [
                _buildSettingsTile(
                  context: context,
                  icon: Icons.person_outline_rounded,
                  title: 'الملف الشخصي',
                  onTap: () {
                    context.push(AppRoutes.profile);
                  },
                ),
              ]),
              const SizedBox(height: 32),
              _buildSectionHeader(context, 'الأمان'),
              const SizedBox(height: 12),
              _buildSettingsCard(context, [
                _buildSettingsTile(
                  context: context,
                  icon: Icons.admin_panel_settings_outlined,
                  title: 'إعدادات الرقابة الأبوية',
                  onTap: () {
                    context.push(AppRoutes.parentLock);
                  },
                ),
              ]),
              const SizedBox(height: 32),
              _buildSectionHeader(context, 'المظهر'),
              const SizedBox(height: 12),
              _buildSettingsCard(context, [
                _buildSettingsTile(
                  context: context,
                  icon: Icons.dark_mode_outlined,
                  title: 'مظهر التطبيق',
                  subtitle: themeMode == ThemeMode.dark ? 'داكن' : 'فاتح',
                  onTap: () => _showThemeDialog(context),
                ),
              ]),
              const SizedBox(height: 32),
              _buildSectionHeader(context, 'الدعم'),
              const SizedBox(height: 12),
              _buildSettingsCard(context, [
                _buildSettingsTile(
                  context: context,
                  icon: Icons.help_outline_rounded,
                  title: 'مركز المساعدة',
                  onTap: () => context.push(AppRoutes.support),
                ),
              ]),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        title,
        style: GoogleFonts.cairo(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(BuildContext context, List<Widget> children) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: Column(children: children),
      ),
    );
  }

  Widget _buildSettingsTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primary, size: 24),
      ),
      title: Text(
        title,
        style: GoogleFonts.cairo(
          fontWeight: FontWeight.w600,
          fontSize: 15,
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: GoogleFonts.cairo(
                fontSize: 13,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            )
          : null,
      trailing: const Icon(
        Icons.arrow_forward_ios_rounded,
        size: 16,
        color: Colors.grey,
      ),
      onTap: onTap,
    );
  }
}
