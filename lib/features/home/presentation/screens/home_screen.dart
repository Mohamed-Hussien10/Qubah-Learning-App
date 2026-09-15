import 'package:qubah_learning_app/core/widgets/hover_scale.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/child_friendly_card.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../../../core/services/dependency_injection.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../core/utils/package_access_helper.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../authentication/domain/repositories/auth_repository.dart';

/// Main home screen with navigation to educational stages, profile, settings.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isGuest = false;
  bool _enablePayment = false;
  bool _isStatusLoaded = false;
  String? _imagePath;
  String? _avatarUrl;

  @override
  void initState() {
    super.initState();
    _checkGuestStatus();
    _loadImage();
  }

  Future<void> _loadImage() async {
    final user = await sl<AuthRepository>().getCachedUser();
    final prefs = await SharedPreferences.getInstance();
    final userId = user?.id ?? await sl<SecureStorage>().getUserId() ?? 'guest';

    String? path = prefs.getString('user_profile_image_$userId');
    if (path == null && prefs.containsKey('user_profile_image')) {
      final oldPath = prefs.getString('user_profile_image');
      if (oldPath != null && File(oldPath).existsSync()) {
        path = oldPath;
        await prefs.setString('user_profile_image_$userId', oldPath);
      }
    }

    if (mounted) {
      setState(() {
        _imagePath = (path != null && File(path).existsSync()) ? path : null;
        _avatarUrl = user?.avatarUrl;
      });
    }
  }

  ImageProvider? _getAvatarImage() {
    if (_imagePath != null && File(_imagePath!).existsSync()) {
      return FileImage(File(_imagePath!));
    }
    if (_avatarUrl != null && _avatarUrl!.isNotEmpty) {
      return CachedNetworkImageProvider(AppHelpers.resolveMediaUrl(_avatarUrl!));
    }
    return null;
  }

  Future<void> _checkGuestStatus() async {
    final secureStorage = sl<SecureStorage>();
    final isGuest = await secureStorage.isGuest();
    final enablePayment = await secureStorage.isPaymentEnabled();
    if (mounted) {
      setState(() {
        _isGuest = isGuest;
        _enablePayment = enablePayment;
        _isStatusLoaded = true;
      });
    }
  }

  Future<void> _handleStagesTap() async {
    final secureStorage = sl<SecureStorage>();
    final userDataJson = await secureStorage.getUserData();
    bool isExpired = false;

    if (userDataJson != null && userDataJson.isNotEmpty) {
      try {
        final userData = jsonDecode(userDataJson);
        if (!PackageAccessHelper.isSubscriptionActiveFromJson(userData)) {
          isExpired = true;
        }
      } catch (_) {}
    }

    if (!mounted) return;

    if (isExpired) {
      _showRenewSubscriptionDialog();
    } else {
      context.push(AppRoutes.stages);
    }
  }

  Future<void> _handleSubscribeNow() async {
    final url = Uri.parse('https://a-z.om/ProgramCheckout?pid=2&mid=qaLRgzEwq3qrR2wOwRMr');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('لا يمكن فتح الرابط')),
        );
      }
    }
  }

  void _showRenewSubscriptionDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.warning_rounded, color: AppColors.error, size: 28),
            const SizedBox(width: 8),
            Text(
              'الاشتراك منتهي',
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
            ),
          ],
        ),
        content: Text(
          'انتهى اشتراكك. يرجى تجديد الاشتراك لمواصلة التعلم وتصفح المراحل الدراسية.',
          style: GoogleFonts.cairo(
            fontSize: 16,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),
        actions: [
          HoverScale(child: TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'إلغاء',
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
          )),
          HoverScale(child: FilledButton(
            onPressed: () {
              Navigator.pop(context);
              context.push(AppRoutes.subscriptionExpired);
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'تواصل مع الدعم',
              style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
            ),
          )),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        SystemNavigator.pop();
      },
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                // ── Header ──────────────────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'مرحباً بك! 👋',
                            style: GoogleFonts.cairo(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ).animate().fadeIn(duration: 400.ms),
                          const SizedBox(height: 4),
                          Text(
                            "هيا نتعلم شيئاً جديداً اليوم!",
                            style: TextStyle(
                              fontSize: 15,
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                            ),
                          ).animate().fadeIn(delay: 200.ms),
                        ],
                      ),
                    ),
                    // Profile Avatar
                    const SizedBox(width: 4),
                    Builder(
                      builder: (context) {
                        final avatarImage = _getAvatarImage();
                        return MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () async {
                              await context.push(AppRoutes.profile);
                              _loadImage();
                            },
                            child: CircleAvatar(
                              radius: 22,
                              backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                              backgroundImage: avatarImage,
                              child: avatarImage == null
                                  ? const Icon(
                                      Icons.person_rounded,
                                      color: AppColors.primary,
                                    )
                                  : null,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ).animate().fadeIn(duration: 400.ms),

                const SizedBox(height: 28),

                // ── Hero Card (3D Claymorphism) ─────────────────────────────────
                _buildHeroCard(
                  context,
                ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1, end: 0),
                const SizedBox(height: 32),

                // ── Quick Actions ───────────────────────────────────────
                Text(
                  'إجراءات سريعة',
                  style: GoogleFonts.cairo(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ).animate().fadeIn(delay: 400.ms),
                const SizedBox(height: 16),
                GridView.extent(
                  maxCrossAxisExtent: 280,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: context.responsiveValue(mobile: 0.85, tablet: 1.0, desktop: 1.2),
                  children:
                      [
                            ChildFriendlyCard(
                              title: 'المراحل الدراسية',
                              subtitle: 'تصفح كل المراحل',
                              imageUrl: null,
                              color: AppColors.primary,
                              defaultIcon: Icons.school_rounded,
                              onTap: _handleStagesTap,
                            ),

                            ChildFriendlyCard(
                              title: 'الإعدادات',
                              subtitle: 'تخصيص التطبيق',
                              imageUrl: null,
                              color: AppColors.accent,
                              defaultIcon: Icons.settings_rounded,
                              onTap: () => context.push(AppRoutes.settings),
                            ),
                            ChildFriendlyCard(
                              title: 'الملف الشخصي',
                              subtitle: 'عرض وتعديل الحساب',
                              imageUrl: null,
                              color: AppColors.green,
                              defaultIcon: Icons.person_rounded,
                              onTap: () async {
                                await context.push(AppRoutes.profile);
                                _loadImage();
                              },
                            ),
                          ]
                          .animate(interval: 100.ms)
                          .fadeIn(delay: 500.ms)
                          .slideY(begin: 0.15, end: 0),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  ));
  }

  Widget _buildHeroCard(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: AppColors.heroGradient,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (_isGuest && _enablePayment) ? 'اشترك الآن!' : 'ابدأ التعلم',
                        style: GoogleFonts.cairo(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        (_isGuest && _enablePayment)
                            ? 'اشترك عبر موقعنا لفتح جميع الدروس والمميزات'
                            : 'استكشف المواد، شاهد الفيديوهات، والعب!',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                        ),
                      ),
                      if (_isStatusLoaded && (!_isGuest || _enablePayment)) ...[
                        const SizedBox(height: 20),
                        HoverScale(child: ElevatedButton(
                          onPressed: _isGuest ? _handleSubscribeNow : _handleStagesTap,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.primary,
                            elevation: 4,
                            shadowColor: Colors.black26,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                          ),
                          child: Text(
                            _isGuest ? 'اشترك الآن' : 'استكشف الآن',
                            style: GoogleFonts.cairo(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.5),
                      width: 1.5,
                    ),
                  ),
                  child: const Icon(
                    Icons.auto_stories_rounded,
                    size: 48,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
