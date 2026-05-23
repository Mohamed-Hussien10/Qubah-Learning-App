import 'dart:io';

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/services/file_picker_service.dart';
import '../../../core/widgets/loading_overlay.dart';
import '../../../core/utils/debug_logger.dart';
import '../data/datasources/scorm_local_datasource.dart';
import '../domain/scorm_package.dart';
import '../services/scorm_extractor_service.dart';
import '../services/security_service.dart';
import 'scorm_player_screen.dart';

/// ──────────────────────────────────────────────────────────────────────────────
/// Home screen – entry point for the SCORM player feature.
///
/// Provides:
///   • "Load SCORM Package" action button
///   • Recent packages list with resume / delete
///   • Dark-mode-first, modern glassmorphic UI
/// ──────────────────────────────────────────────────────────────────────────────
class ScormHomeScreen extends StatefulWidget {
  const ScormHomeScreen({super.key});

  @override
  State<ScormHomeScreen> createState() => _ScormHomeScreenState();
}

class _ScormHomeScreenState extends State<ScormHomeScreen>
    with TickerProviderStateMixin {
  final ScormLocalDataSource _dataSource = ScormLocalDataSource();

  List<ScormPackage> _recentPackages = [];
  bool _isLoading = false;
  String _loadingMessage = '';
  double? _loadingProgress;

  late final AnimationController _fabAnimationController;
  late final Animation<double> _fabScale;

  @override
  void initState() {
    super.initState();
    _loadRecentPackages();

    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fabScale = CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.elasticOut,
    );
    _fabAnimationController.forward();
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    super.dispose();
  }

  Future<void> _loadRecentPackages() async {
    final packages = await _dataSource.getRecentPackages();
    if (mounted) {
      setState(() => _recentPackages = packages);
    }
  }

  // ── Load New SCORM Package ──────────────────────────────────────────────
  Future<void> _pickAndLoadPackage() async {
    // 1. Request permissions
    final hasPermission = await FilePickerService.requestStoragePermission();
    if (!hasPermission) {
      _showSnackBar(
        'Storage permission required to load SCORM packages.',
        isError: true,
      );
      return;
    }

    // 2. Pick ZIP file
    final zipPath = await FilePickerService.pickZipFile();
    if (zipPath == null) return;

    setState(() {
      _isLoading = true;
      _loadingMessage = AppStrings.extracting;
      _loadingProgress = 0.0;
    });

    try {
      // 3. Security placeholder checks
      await SecurityService.validateZipEncryption(zipPath);
      await SecurityService.validateAccessToken(null);

      // 4. Extract and prepare
      final package = await ScormExtractorService.extractAndPrepare(
        zipPath,
        onProgress: (progress) {
          if (mounted) {
            setState(() => _loadingProgress = progress);
          }
        },
      );

      // 5. Save to local storage
      await _dataSource.savePackage(package);
      await _loadRecentPackages();

      setState(() => _isLoading = false);

      // 6. Navigate to player
      if (mounted) {
        _openPlayer(package);
      }
    } catch (e, st) {
      DebugLogger.error('Failed to load SCORM package', e, st);
      setState(() => _isLoading = false);
      _showSnackBar('Failed to load package: ${e.toString()}', isError: true);
    }
  }

  void _openPlayer(ScormPackage package) {
    // Update last opened timestamp
    _dataSource.updateLastOpened(package.id);

    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            ScormPlayerScreen(package: package),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(0.03, 0),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  Future<void> _deletePackage(ScormPackage package) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Delete Package',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          'Delete "${package.name}" and its extracted files?',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ScormExtractorService.deleteExtractedPackage(package.extractedPath);
      await _dataSource.removePackage(package.id);
      await _loadRecentPackages();
      _showSnackBar('Package deleted.');
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ── Background Gradient ──────────────────────────────────────────
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.scaffoldDark, Color(0xFF0A0E1A)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          // ── Main Content ─────────────────────────────────────────────────
          SafeArea(
            child: CustomScrollView(
              slivers: [
                // ── Header ─────────────────────────────────────────────────
                SliverToBoxAdapter(child: _buildHeader()),

                // ── Action Card ────────────────────────────────────────────
                SliverToBoxAdapter(child: _buildActionCard()),

                // ── Recent Packages Header ─────────────────────────────────
                SliverToBoxAdapter(child: _buildSectionHeader()),

                // ── Recent Packages List ───────────────────────────────────
                _recentPackages.isEmpty
                    ? SliverToBoxAdapter(child: _buildEmptyState())
                    : SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) => _buildPackageCard(
                              _recentPackages[index],
                              index,
                            ),
                            childCount: _recentPackages.length,
                          ),
                        ),
                      ),

                // Bottom padding
                const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
              ],
            ),
          ),

          // ── Loading Overlay ──────────────────────────────────────────────
          if (_isLoading)
            LoadingOverlay(
              message: _loadingMessage,
              progress: _loadingProgress,
            ),
        ],
      ),

      // ── FAB ────────────────────────────────────────────────────────────────
      floatingActionButton: ScaleTransition(
        scale: _fabScale,
        child: Container(
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.4),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: FloatingActionButton.extended(
            onPressed: _isLoading ? null : _pickAndLoadPackage,
            backgroundColor: Colors.transparent,
            elevation: 0,
            icon: const Icon(Icons.add_rounded, size: 24),
            label: const Text(
              'Load Package',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
          ),
        ),
      ),
    );
  }

  // ── Header Widget ───────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // App icon + title row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: AppColors.heroGradient,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.school_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.appName,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      AppStrings.appTagline,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
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

  // ── Action Card (Pick ZIP) ──────────────────────────────────────────────
  Widget _buildActionCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: GestureDetector(
        onTap: _isLoading ? null : _pickAndLoadPackage,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withValues(alpha: 0.15),
                AppColors.accent.withValues(alpha: 0.08),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.25),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.upload_file_rounded,
                  color: AppColors.primaryLight,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.pickScormZip,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Select a .zip SCORM package from your device',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: AppColors.primary.withValues(alpha: 0.6),
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Section Header ──────────────────────────────────────────────────────
  Widget _buildSectionHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 12),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            AppStrings.recentPackages,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.3,
            ),
          ),
          const Spacer(),
          Text(
            '${_recentPackages.length} package${_recentPackages.length != 1 ? 's' : ''}',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  // ── Empty State ─────────────────────────────────────────────────────────
  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.cardDark.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.folder_open_rounded,
              size: 48,
              color: AppColors.textSecondary.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            AppStrings.noRecentPackages,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the button below to load your first SCORM package',
            style: TextStyle(
              color: AppColors.textSecondary.withValues(alpha: 0.7),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  // ── Package Card ────────────────────────────────────────────────────────
  Widget _buildPackageCard(ScormPackage package, int index) {
    final timeAgo = _formatTimeAgo(package.lastOpenedAt);
    final hasManifest = package.manifest != null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: Duration(milliseconds: 300 + (index * 80)),
        curve: Curves.easeOutCubic,
        builder: (context, value, child) {
          return Opacity(
            opacity: value,
            child: Transform.translate(
              offset: Offset(0, 20 * (1 - value)),
              child: child,
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: AppColors.cardGradient,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.06),
              width: 1,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => _resumePackage(package),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Package icon
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: AppColors.accentGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.play_lesson_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    // Package info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            package.name,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time_rounded,
                                size: 13,
                                color: AppColors.textSecondary.withValues(
                                  alpha: 0.7,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                timeAgo,
                                style: TextStyle(
                                  color: AppColors.textSecondary.withValues(
                                    alpha: 0.7,
                                  ),
                                  fontSize: 12,
                                ),
                              ),
                              if (hasManifest) ...[
                                const SizedBox(width: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.accent.withValues(
                                      alpha: 0.15,
                                    ),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'SCORM ${package.manifest!.scormVersion ?? ''}',
                                    style: const TextStyle(
                                      color: AppColors.accent,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          // Progress bar placeholder
                          if (package.progress > 0) ...[
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: package.progress,
                                backgroundColor: AppColors.primary.withValues(
                                  alpha: 0.15,
                                ),
                                valueColor: const AlwaysStoppedAnimation(
                                  AppColors.primary,
                                ),
                                minHeight: 4,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    // Actions
                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_vert_rounded,
                        color: AppColors.textSecondary.withValues(alpha: 0.6),
                      ),
                      color: AppColors.cardDarkElevated,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      onSelected: (value) {
                        if (value == 'open') _resumePackage(package);
                        if (value == 'delete') _deletePackage(package);
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'open',
                          child: Row(
                            children: [
                              Icon(
                                Icons.play_arrow_rounded,
                                color: AppColors.accent,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                AppStrings.openPackage,
                                style: TextStyle(color: AppColors.textPrimary),
                              ),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(
                                Icons.delete_outline_rounded,
                                color: AppColors.error,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                AppStrings.deletePackage,
                                style: TextStyle(color: AppColors.error),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Resume a previously loaded package – verify files still exist on disk.
  Future<void> _resumePackage(ScormPackage package) async {
    final entryFile = File(package.entryFilePath);
    if (!await entryFile.exists()) {
      _showSnackBar(
        'Package files not found. The extracted content may have been deleted.',
        isError: true,
      );
      return;
    }
    _openPlayer(package);
  }

  String _formatTimeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.day}/${date.month}/${date.year}';
  }
}
