import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/services/dependency_injection.dart';

class SupportScreen extends StatefulWidget {
  final String? initialContactEmail;
  final String? initialContactPhone;

  const SupportScreen({
    super.key,
    this.initialContactEmail,
    this.initialContactPhone,
  });

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  late String contactEmail;
  late String contactPhone;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    contactEmail = widget.initialContactEmail ?? 'support@qubah.com';
    contactPhone = widget.initialContactPhone ?? '+966500000000';
    if (widget.initialContactEmail == null || widget.initialContactPhone == null) {
      _fetchConfig();
    }
  }

  Future<void> _fetchConfig() async {
    setState(() => isLoading = true);
    try {
      final dio = sl<DioClient>();
      final response = await dio.get(ApiEndpoints.appConfig);
      final data = response.data['data'] ?? response.data;
      if (mounted) {
        setState(() {
          contactEmail = data['contactEmail']?.toString() ?? contactEmail;
          contactPhone = data['contactPhone']?.toString() ?? contactPhone;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('لا يمكن فتح الرابط، تأكد من وجود التطبيق المناسب')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'مركز المساعدة',
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () => context.pop(),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Image.asset('assets/images/logo.png', height: 120),
                const SizedBox(height: 32),
                Text(
                  'نحن هنا لمساعدتك!',
                  style: GoogleFonts.cairo(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'تواصل معنا عبر إحدى القنوات التالية وسيقوم فريق الدعم بالرد عليك في أقرب وقت ممكن.',
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                _buildContactCard(
                  icon: Icons.chat_bubble_outline_rounded,
                  title: 'تواصل عبر واتساب',
                  subtitle: contactPhone,
                  color: const Color(0xFF25D366),
                  onTap: () {
                    final phone = contactPhone.replaceAll(RegExp(r'[^\d+]'), '');
                    _launchUrl('https://wa.me/${phone.replaceAll('+', '')}');
                  },
                ),
                const SizedBox(height: 16),
                _buildContactCard(
                  icon: Icons.email_outlined,
                  title: 'راسلنا عبر البريد',
                  subtitle: contactEmail,
                  color: AppColors.primary,
                  onTap: () => _launchUrl('mailto:$contactEmail'),
                ),
              ],
            ),
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.cairo(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                    textDirection: TextDirection.ltr,
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: color, size: 16),
          ],
        ),
      ),
    );
  }
}
