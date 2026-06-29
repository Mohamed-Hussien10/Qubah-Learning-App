import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          'الإعدادات',
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        children: [
          _buildSectionHeader(context, 'الحساب'),
          const SizedBox(height: 12),
          _buildSettingsCard([
            _buildSettingsTile(
              icon: Icons.person_outline_rounded,
              title: 'الملف الشخصي',
              onTap: () {
                context.push('/profile');
              },
            ),
          ]),
          const SizedBox(height: 32),
          _buildSectionHeader(context, 'الأمان'),
          const SizedBox(height: 12),
          _buildSettingsCard([
            _buildSettingsTile(
              icon: Icons.admin_panel_settings_outlined,
              title: 'إعدادات الرقابة الأبوية',
              onTap: () {
                context.push('/parent-lock');
              },
            ),
          ]),
          const SizedBox(height: 32),
          _buildSectionHeader(context, 'الدعم'),
          const SizedBox(height: 12),
          _buildSettingsCard([
            _buildSettingsTile(
              icon: Icons.help_outline_rounded,
              title: 'مركز المساعدة',
              onTap: () => context.push('/support'),
            ),
            const Divider(height: 1, indent: 56),
            _buildSettingsTile(
              icon: Icons.privacy_tip_outlined,
              title: 'سياسة الخصوصية',
              onTap: () => context.push('/privacy'),
            ),
          ]),
        ],
      ),
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

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
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
        style: GoogleFonts.cairo(fontWeight: FontWeight.w600, fontSize: 15),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios_rounded,
        size: 16,
        color: Colors.grey,
      ),
      onTap: onTap,
    );
  }
}
