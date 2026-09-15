import 'package:qubah_learning_app/core/widgets/hover_scale.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
        leading: HoverScale(child: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              // fallback
              Navigator.of(context).pushReplacementNamed('/home');
            }
          },
        )),
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
                      String name = 'طالب';
                      String stage = 'غير محدد';
                      String grade = 'غير محدد';

                      UserEntity? user;
                      if (snapshot.hasData && snapshot.data != null) {
                        user = snapshot.data!;
                        name = user.name.isNotEmpty ? user.name : name;
                        stage = user.stageName ?? stage;
                        grade = user.gradeName ?? grade;
                      } else {
                        name = 'زائر (تجربة مجانية)';
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
                          const SizedBox(height: 32),

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
    final bool isGuest = widget.user == null;
    final bool isActive = widget.user?.isSubscriptionValid ?? false;
    final package = _fetchedPackage ?? widget.user?.package;
    final String packageName = isGuest
        ? 'تجربة مجانية'
        : (isActive ? (package?.name ?? 'الباقة الفعالة') : 'لا يوجد اشتراك فعال');
    final String scopeText = isGuest
        ? 'دروس ومراحل تجريبية'
        : (package?.scopeText ??
            '${widget.user?.stageName ?? "المرحلة"} - ${widget.user?.gradeName ?? "الصف"}');
    final String scopeLevelLabel = isGuest
        ? 'تصفح مجاني'
        : (package?.scopeLevelLabel ?? 'باقة شاملة');

    final exp = widget.user?.subscriptionExpiry;
    final String expiryText = isGuest
        ? 'مفتوح'
        : ((exp != null)
            ? exp.toString().split(" ").first.split("T").first
            : 'غير محدد');

    final Color statusColor = isGuest
        ? Colors.blue
        : (isActive ? Colors.green : Colors.red);
    final String statusText = isGuest
        ? 'زائر'
        : (isActive ? 'مفعل' : 'منتهي');
    final IconData statusIcon = isGuest
        ? Icons.explore_rounded
        : (isActive ? Icons.check_circle_rounded : Icons.cancel_rounded);
    final Color cardBorderColor = (isActive || isGuest)
        ? AppColors.primary.withValues(alpha: 0.3)
        : AppColors.error.withValues(alpha: 0.3);
    final Color cardShadowColor = (isActive || isGuest)
        ? AppColors.primary.withValues(alpha: 0.08)
        : AppColors.error.withValues(alpha: 0.08);
    final Color headerIconColor = (isActive || isGuest) ? AppColors.primary : Colors.grey;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: cardBorderColor,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: cardShadowColor,
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
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
                  color: headerIconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.card_membership_rounded,
                  color: headerIconColor,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        packageName,
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
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(
                    alpha: 0.12,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      statusIcon,
                      size: 14,
                      color: statusColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      statusText,
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
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
                        Icon(
                          Icons.layers_outlined,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),
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
                        horizontal: 8,
                        vertical: 2,
                      ),
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
                        Icon(
                          Icons.event_outlined,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),
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
        ],
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
      final userId =
          _userId ??
          (await sl<AuthRepository>().getCachedUser())?.id ??
          await sl<SecureStorage>().getUserId() ??
          'guest';
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
      return CachedNetworkImageProvider(AppHelpers.resolveMediaUrl(_avatarUrl!));
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final avatarImage = _getAvatarImage();
    return Center(
      child: Stack(
        children: [
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: _pickImage,
            child: CircleAvatar(
              radius: 60,
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
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
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
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
          ),
        ],
      ),
    ).animate().scale(duration: 400.ms, curve: Curves.elasticOut);
  }
}
