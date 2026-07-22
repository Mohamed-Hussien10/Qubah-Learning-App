import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/services/dependency_injection.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../core/widgets/qubah_button.dart';
import '../../../authentication/presentation/manager/cubit/auth_cubit.dart';
import '../../../authentication/presentation/manager/state/auth_state.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/network/dio_client.dart';
import '../../../subscriptions/data/models/package_model.dart';
import '../../../subscriptions/domain/entities/package_entity.dart';
import '../../../authentication/domain/entities/user_entity.dart';
import '../../../authentication/domain/repositories/auth_repository.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AuthCubit>(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'الملف الشخصي',
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
          ),
        ),
        body: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is AuthUnauthenticated) {
              context.go(AppRoutes.login);
            }
          },
          builder: (context, state) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // Avatar
                  const _ProfileAvatarWidget(),
                  const SizedBox(height: 24),
                  // User Details & Package Information
                  FutureBuilder<UserEntity?>(
                    future: sl<AuthRepository>().getCachedUser(),
                    builder: (context, snapshot) {
                      String name = 'اسم الطالب';
                      String email = 'طالب@مثال.com';
                      String stage = 'غير محدد';
                      String grade = 'غير محدد';

                      UserEntity? user;
                      if (snapshot.hasData && snapshot.data != null) {
                        user = snapshot.data!;
                        name = user.name.isNotEmpty ? user.name : name;
                        email = user.email.isNotEmpty ? user.email : email;
                        stage = user.stageName ?? stage;
                        grade = user.gradeName ?? grade;
                      }

                      return Column(
                        children: [
                          Text(
                            name,
                            style: GoogleFonts.cairo(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ).animate().fadeIn(delay: 200.ms),
                          const SizedBox(height: 4),
                          Text(
                            email,
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).textTheme.bodySmall?.color?.withValues(alpha: 0.6),
                            ),
                          ).animate().fadeIn(delay: 300.ms),
                          const SizedBox(height: 32),

                          // Stage & Grade Info Card
                          _ProfileMenuItem(
                                icon: Icons.school_rounded,
                                title: 'المرحلة والصف',
                                subtitle: '$stage - $grade',
                                onTap: () {},
                              )
                              .animate()
                              .fadeIn(delay: 400.ms)
                              .slideY(begin: 0.1, end: 0),
                          const SizedBox(height: 16),

                          // Student Package Card
                          _StudentPackageCard(user: user)
                              .animate()
                              .fadeIn(delay: 500.ms)
                              .slideY(begin: 0.1, end: 0),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 36),
                  // Logout Button
                  QubahButton(
                    text: 'تسجيل الخروج',
                    icon: Icons.logout_rounded,
                    gradient: AppColors.sunsetGradient,
                    onPressed: () {
                      context.read<AuthCubit>().logout();
                    },
                  ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.1, end: 0),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _StudentPackageCard extends StatefulWidget {
  final UserEntity? user;
  const _StudentPackageCard({this.user});

  @override
  State<_StudentPackageCard> createState() => _StudentPackageCardState();
}

class _StudentPackageCardState extends State<_StudentPackageCard> {
  PackageEntity? _fetchedPackage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchPackageIfNeeded();
  }

  @override
  void didUpdateWidget(covariant _StudentPackageCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.user?.packageId != oldWidget.user?.packageId ||
        widget.user?.package != oldWidget.user?.package) {
      _fetchPackageIfNeeded();
    }
  }

  Future<void> _fetchPackageIfNeeded() async {
    final user = widget.user;
    if (user == null) return;

    if (user.package != null) {
      if (mounted) {
        setState(() {
          _fetchedPackage = user.package;
        });
      }
      return;
    }

    final pkgId = user.packageId;
    if (pkgId == null || pkgId.isEmpty) {
      if (mounted) {
        setState(() {
          _fetchedPackage = null;
        });
      }
      return;
    }

    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final dioClient = sl<DioClient>();
      final response = await dioClient.get('packages/$pkgId');
      final data = response.data;
      if (data != null && data['data'] != null) {
        final pkgJson = data['data'] as Map<String, dynamic>;
        final pkgEntity = PackageModel.fromJson(pkgJson).toEntity();
        if (mounted) {
          setState(() {
            _fetchedPackage = pkgEntity;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching package details: $e');
      }
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isActive = widget.user?.isSubscriptionValid ?? false;
    final package = _fetchedPackage ?? widget.user?.package;
    final String packageName = package?.name ?? 'الباقة الفعالة';
    final String scopeText = package?.scopeText ?? '${widget.user?.stageName ?? "المرحلة"} - ${widget.user?.gradeName ?? "الصف"}';
    final String scopeLevelLabel = package?.scopeLevelLabel ?? 'باقة شاملة';

    final exp = widget.user?.subscriptionExpiry;
    final String expiryText = (exp != null)
        ? exp.toString().split(" ").first.split("T").first
        : 'غير محدد';

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive
              ? AppColors.primary.withValues(alpha: 0.3)
              : AppColors.error.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (isActive ? AppColors.primary : AppColors.error)
                .withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          )
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Icon + Title + Status Chip
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: (isActive ? AppColors.primary : Colors.grey)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.card_membership_rounded,
                  color: isActive ? AppColors.primary : Colors.grey,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        isActive ? packageName : 'لا يوجد اشتراك فعال',
                        style: GoogleFonts.cairo(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (_isLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: (isActive ? Colors.green : Colors.red)
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isActive
                          ? Icons.check_circle_rounded
                          : Icons.cancel_rounded,
                      size: 14,
                      color: isActive ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isActive ? 'مفعل' : 'منتهي',
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isActive ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, thickness: 1),
          const SizedBox(height: 16),

          // Details grid: Scope + Expiry Date
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.layers_outlined,
                            size: 16, color: Colors.grey.shade600),
                        const SizedBox(width: 6),
                        Text(
                          'نطاق الباقة',
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      scopeText,
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        scopeLevelLabel,
                        style: GoogleFonts.cairo(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.event_outlined,
                            size: 16, color: Colors.grey.shade600),
                        const SizedBox(width: 6),
                        Text(
                          'تاريخ الانتهاء',
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      expiryText,
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (!isActive) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text(
                        'تفعيل اشتراك',
                        style: GoogleFonts.cairo(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      content: Text(
                        'عزيزي الطالب، يرجى التواصل مع إدارة التطبيق أو استخدام كود التفعيل لتجديد اشتراكك.',
                        style: GoogleFonts.cairo(),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: Text(
                            'إغلاق',
                            style: GoogleFonts.cairo(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: Text(
                  'تجديد الباقة / كود التفعيل',
                  style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Theme.of(
                          context,
                        ).textTheme.bodySmall?.color?.withValues(alpha: 0.6),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileAvatarWidget extends StatefulWidget {
  const _ProfileAvatarWidget();

  @override
  State<_ProfileAvatarWidget> createState() => _ProfileAvatarWidgetState();
}

class _ProfileAvatarWidgetState extends State<_ProfileAvatarWidget> {
  String? _imagePath;
  String? _avatarUrl;
  String? _userId;

  @override
  void initState() {
    super.initState();
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
        _userId = userId;
        _imagePath = (path != null && File(path).existsSync()) ? path : null;
        _avatarUrl = user?.avatarUrl;
      });
    }
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.single.path != null) {
      final path = result.files.single.path!;
      final prefs = await SharedPreferences.getInstance();
      final userId = _userId ?? (await sl<AuthRepository>().getCachedUser())?.id ?? await sl<SecureStorage>().getUserId() ?? 'guest';
      await prefs.setString('user_profile_image_$userId', path);
      if (mounted) {
        setState(() {
          _imagePath = path;
        });
      }
    }
  }

  ImageProvider? _getAvatarImage() {
    if (_imagePath != null && File(_imagePath!).existsSync()) {
      return FileImage(File(_imagePath!));
    }
    if (_avatarUrl != null && _avatarUrl!.isNotEmpty) {
      return NetworkImage(AppHelpers.resolveMediaUrl(_avatarUrl!));
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final avatarImage = _getAvatarImage();
    return Center(
      child: Stack(
        children: [
          GestureDetector(
            onTap: _pickImage,
            child: CircleAvatar(
              radius: 60,
              backgroundColor: AppColors.primary.withValues(
                alpha: 0.1,
              ),
              backgroundImage: avatarImage,
              child: avatarImage == null
                  ? const Icon(
                      Icons.person_rounded,
                      size: 70,
                      color: AppColors.primary,
                    )
                  : null,
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primary,
                child: const Icon(
                  Icons.camera_alt_rounded,
                  size: 18,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate().scale(duration: 400.ms, curve: Curves.elasticOut);
  }
}
