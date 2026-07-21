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
                  // Name
                  FutureBuilder<UserEntity?>(
                    future: sl<AuthRepository>().getCachedUser(),
                    builder: (context, snapshot) {
                      String name = 'اسم الطالب';
                      String email = 'طالب@مثال.com';
                      String stage = 'غير محدد';
                      String grade = 'غير محدد';
                      String subscription = 'غير فعال';

                      if (snapshot.hasData && snapshot.data != null) {
                        final user = snapshot.data!;
                        name = user.name.isNotEmpty ? user.name : name;
                        email = user.email.isNotEmpty ? user.email : email;
                        stage = user.stageName ?? stage;
                        grade = user.gradeName ?? grade;

                        final exp = user.subscriptionExpiry;
                        if (exp != null && exp.isAfter(DateTime.now())) {
                          subscription = 'فعال';
                          subscription +=
                              ' حتى ${exp.toString().split(" ").first.split("T").first}';
                        } else {
                          subscription = 'غير فعال أو منتهي';
                        }
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
                              ).textTheme.bodySmall?.color?.withOpacity(0.6),
                            ),
                          ).animate().fadeIn(delay: 300.ms),
                          const SizedBox(height: 40),
                          // Info Cards
                          _ProfileMenuItem(
                                icon: Icons.school_rounded,
                                title: 'المرحلة والصف',
                                subtitle: '$stage - $grade',
                                onTap: () {},
                              )
                              .animate()
                              .fadeIn(delay: 400.ms)
                              .slideY(begin: 0.1, end: 0),
                          const SizedBox(height: 12),
                          subscription != 'غير فعال أو منتهي'
                              ? _ProfileMenuItem(
                                      icon: Icons.subscriptions_rounded,
                                      title: 'الاشتراك',
                                      subtitle: subscription,
                                      onTap: () => {},
                                    )
                                    .animate()
                                    .fadeIn(delay: 500.ms)
                                    .slideY(begin: 0.1, end: 0)
                              : _ProfileMenuItem(
                                      icon: Icons.support_agent_rounded,
                                      title: 'تجديد الاشتراك',
                                      subtitle: 'تواصل مع الإدارة للتجديد',
                                      onTap: () {
                                        showDialog(
                                          context: context,
                                          builder: (ctx) => AlertDialog(
                                            title: Text(
                                              'تواصل مع الإدارة',
                                              style: GoogleFonts.cairo(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            content: Text(
                                              'عزيزي الطالب، يرجى التواصل مع إدارة التطبيق لتجديد اشتراكك.',
                                              style: GoogleFonts.cairo(),
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(ctx),
                                                child: Text(
                                                  'حسناً',
                                                  style: GoogleFonts.cairo(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    )
                                    .animate()
                                    .fadeIn(delay: 500.ms)
                                    .slideY(begin: 0.1, end: 0),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 40),
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
            border: Border.all(color: Colors.grey.withOpacity(0.1)),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
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
                        ).textTheme.bodySmall?.color?.withOpacity(0.6),
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
