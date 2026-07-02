import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';

import 'package:web_dashboard/core/constants/app_colors.dart';
import 'package:web_dashboard/core/constants/app_strings.dart';
import 'package:web_dashboard/features/settings/data/models/app_settings_model.dart';
import 'package:web_dashboard/features/settings/presentation/manager/settings_cubit.dart';
import 'package:web_dashboard/core/services/dependency_injection.dart';
import 'package:web_dashboard/features/settings/presentation/manager/settings_state.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<SettingsCubit>()..loadSettings(),
      child: const _SettingsView(),
    );
  }
}

class _SettingsView extends StatefulWidget {
  const _SettingsView();

  @override
  State<_SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<_SettingsView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _generalFormKey = GlobalKey<FormState>();
  final _socialFormKey = GlobalKey<FormState>();

  // General Controllers
  late TextEditingController _appNameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _phoneCtrl;

  // Social Controllers
  late TextEditingController _fbCtrl;
  late TextEditingController _twCtrl;
  late TextEditingController _igCtrl;
  late TextEditingController _ytCtrl;

  // API Settings Controllers (Read-Only)
  late TextEditingController _baseUrlCtrl;
  late TextEditingController _apiKeyCtrl;

  bool _maintenanceMode = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    _appNameCtrl = TextEditingController();
    _emailCtrl = TextEditingController();
    _phoneCtrl = TextEditingController();

    _fbCtrl = TextEditingController();
    _twCtrl = TextEditingController();
    _igCtrl = TextEditingController();
    _ytCtrl = TextEditingController();

    _baseUrlCtrl = TextEditingController();
    _apiKeyCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _appNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _fbCtrl.dispose();
    _twCtrl.dispose();
    _igCtrl.dispose();
    _ytCtrl.dispose();
    _baseUrlCtrl.dispose();
    _apiKeyCtrl.dispose();
    super.dispose();
  }

  void _populateControllers(AppSettingsModel settings) {
    _appNameCtrl.text = settings.appName;
    _emailCtrl.text = settings.contactEmail;
    _phoneCtrl.text = settings.contactPhone;

    _fbCtrl.text = settings.socialLinks['facebook'] ?? '';
    _twCtrl.text = settings.socialLinks['twitter'] ?? '';
    _igCtrl.text = settings.socialLinks['instagram'] ?? '';
    _ytCtrl.text = settings.socialLinks['youtube'] ?? '';

    _baseUrlCtrl.text = settings.baseUrl;
    _apiKeyCtrl.text = settings.apiKey;
    _maintenanceMode = settings.maintenanceMode;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BlocConsumer<SettingsCubit, SettingsState>(
        listener: (context, state) {
          if (state.saveSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('تم حفظ الإعدادات بنجاح'),
                backgroundColor: AppColors.success,
              ),
            );
            context.read<SettingsCubit>().clearSaveSuccess();
          }
          if (state.status == SettingsStatus.loaded && state.settings != null) {
            _populateControllers(state.settings!);
          }
        },
        builder: (context, state) {
          if (state.status == SettingsStatus.loading ||
              state.status == SettingsStatus.initial) {
            return _buildShimmer(isDark);
          }

          if (state.status == SettingsStatus.error) {
            return _buildError(context, state.errorMessage ?? '');
          }

          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, isDark),
                const SizedBox(height: 20),
                _buildTabBar(isDark),
                const SizedBox(height: 20),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildGeneralTab(context, state, isDark),
                      _buildSocialTab(context, state, isDark),
                      _buildApiTab(context, state, isDark),
                    ],
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.02, end: 0);
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Row(
      children: [
        Icon(Icons.settings_rounded, color: AppColors.primary, size: 28),
        const SizedBox(width: 12),
        Text(
          AppStrings.settings,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
        ),
      ],
    );
  }

  Widget _buildTabBar(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: TabBar(
        controller: _tabController,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(text: 'الإعدادات العامة', icon: Icon(Icons.info_outline_rounded)),
          Tab(text: 'روابط التواصل', icon: Icon(Icons.share_rounded)),
          Tab(text: 'الربط البرمجي API', icon: Icon(Icons.api_rounded)),
        ],
      ),
    );
  }

  Widget _buildGeneralTab(BuildContext context, SettingsState state, bool isDark) {
    return SingleChildScrollView(
      child: Form(
        key: _generalFormKey,
        child: Column(
          children: [
            // App Identity Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'هوية المنصة والاتصال',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _appNameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'اسم التطبيق *',
                        prefixIcon: Icon(Icons.branding_watermark_outlined),
                      ),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'اسم التطبيق مطلوب' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailCtrl,
                      decoration: const InputDecoration(
                        labelText: 'بريد الدعم والاتصال *',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'البريد مطلوب' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneCtrl,
                      decoration: const InputDecoration(
                        labelText: 'هاتف الاتصال *',
                        prefixIcon: Icon(Icons.phone_outlined),
                      ),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'الهاتف مطلوب' : null,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Maintenance Mode Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'وضع الصيانة (Maintenance Mode)',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'عند تفعيل وضع الصيانة، لن يتمكن الطلاب أو أولياء الأمور من استخدام التطبيقات المحمولة وستظهر لهم شاشة صيانة توضيحية.',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    Switch.adaptive(
                      value: _maintenanceMode,
                      activeColor: AppColors.error,
                      onChanged: (val) {
                        setState(() {
                          _maintenanceMode = val;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FilledButton.icon(
                  onPressed: state.status == SettingsStatus.saving
                      ? null
                      : () {
                          if (_generalFormKey.currentState!.validate()) {
                            context.read<SettingsCubit>().updateGeneralSettings(
                                  appName: _appNameCtrl.text.trim(),
                                  contactEmail: _emailCtrl.text.trim(),
                                  contactPhone: _phoneCtrl.text.trim(),
                                  maintenanceMode: _maintenanceMode,
                                );
                          }
                        },
                  icon: state.status == SettingsStatus.saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Icon(Icons.save_rounded),
                  label: Text(state.status == SettingsStatus.saving ? 'جاري الحفظ...' : 'حفظ الإعدادات العامة'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialTab(BuildContext context, SettingsState state, bool isDark) {
    return SingleChildScrollView(
      child: Form(
        key: _socialFormKey,
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'روابط التواصل الاجتماعي الرسمية للمنصة',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _fbCtrl,
                      decoration: const InputDecoration(
                        labelText: 'حساب فيسبوك (Facebook)',
                        prefixIcon: Icon(Icons.facebook),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _twCtrl,
                      decoration: const InputDecoration(
                        labelText: 'حساب تويتر / إكس (X / Twitter)',
                        prefixIcon: Icon(Icons.tag_faces_rounded),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _igCtrl,
                      decoration: const InputDecoration(
                        labelText: 'حساب إنستغرام (Instagram)',
                        prefixIcon: Icon(Icons.camera_alt_outlined),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _ytCtrl,
                      decoration: const InputDecoration(
                        labelText: 'قناة يوتيوب (YouTube)',
                        prefixIcon: Icon(Icons.play_circle_fill_outlined),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FilledButton.icon(
                  onPressed: state.status == SettingsStatus.saving
                      ? null
                      : () {
                          context.read<SettingsCubit>().updateSocialLinks({
                            'facebook': _fbCtrl.text.trim(),
                            'twitter': _twCtrl.text.trim(),
                            'instagram': _igCtrl.text.trim(),
                            'youtube': _ytCtrl.text.trim(),
                          });
                        },
                  icon: state.status == SettingsStatus.saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Icon(Icons.save_rounded),
                  label: Text(state.status == SettingsStatus.saving ? 'جاري الحفظ...' : 'حفظ روابط التواصل'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApiTab(BuildContext context, SettingsState state, bool isDark) {
    return SingleChildScrollView(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'بيانات الربط الخارجي ومفاتيح الوصول',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                'هذه البيانات يتم إعدادها من قبل مهندس النظام، وهي للقراءة فقط لحماية الاتصال بالخادم.',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _baseUrlCtrl,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'رابط الخادم الرئيسي (Base URL)',
                  prefixIcon: Icon(Icons.link),
                  filled: true,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _apiKeyCtrl,
                readOnly: true,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'مفتاح الوصول البرمجي (API Secret Key)',
                  prefixIcon: const Icon(Icons.vpn_key_outlined),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.copy_rounded),
                    onPressed: () {
                      // Copy API Key
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('تم نسخ مفتاح الوصول إلى الحافظة')),
                      );
                    },
                  ),
                  filled: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 80, color: AppColors.error),
          const SizedBox(height: 16),
          Text(message, style: const TextStyle(color: AppColors.error)),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => context.read<SettingsCubit>().loadSettings(),
            icon: const Icon(Icons.refresh),
            label: const Text(AppStrings.refresh),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmer(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Shimmer.fromColors(
        baseColor: isDark ? AppColors.surfaceDark : Colors.grey.shade200,
        highlightColor: isDark ? AppColors.cardDark : Colors.grey.shade50,
        child: Column(
          children: [
            Container(height: 30, width: 150, color: Colors.white),
            const SizedBox(height: 20),
            Container(height: 48, color: Colors.white),
            const SizedBox(height: 24),
            Container(height: 300, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
