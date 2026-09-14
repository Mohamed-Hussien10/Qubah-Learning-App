import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/dependency_injection.dart';
import '../storage/secure_storage.dart';
import '../../features/authentication/presentation/manager/cubit/auth_cubit.dart';
import '../../features/authentication/presentation/manager/state/auth_state.dart';

/// ──────────────────────────────────────────────────────────────────────────────
/// Student Watermark Overlay
///
/// Displays a semi-transparent forensic watermark at a fixed top-left position
/// containing only the student's username.
/// ──────────────────────────────────────────────────────────────────────────────
class StudentWatermarkOverlay extends StatefulWidget {
  final double opacity;

  const StudentWatermarkOverlay({
    super.key,
    this.opacity = 0.25,
  });

  @override
  State<StudentWatermarkOverlay> createState() =>
      _StudentWatermarkOverlayState();
}

class _StudentWatermarkOverlayState extends State<StudentWatermarkOverlay> {
  String _studentName = '';

  @override
  void initState() {
    super.initState();
    _loadStudentInfo();
  }

  Future<void> _loadStudentInfo() async {
    // 1. Try reading from AuthCubit if available in context
    try {
      final authState = context.read<AuthCubit>().state;
      if (authState is AuthAuthenticated) {
        final user = authState.user;
        if (mounted) {
          setState(() {
            _studentName = user.name.trim();
          });
          return;
        }
      }
    } catch (_) {
      // AuthCubit not in context, proceed to fallback storage
    }

    // 2. Fallback: Read from SecureStorage
    try {
      final secureStorage = sl<SecureStorage>();
      final userDataStr = await secureStorage.getUserData();
      if (userDataStr != null && userDataStr.isNotEmpty) {
        final Map<String, dynamic> data = jsonDecode(userDataStr);
        final name = data['name']?.toString() ?? '';
        if (mounted && name.isNotEmpty) {
          setState(() {
            _studentName = name.trim();
          });
          return;
        }
      }
    } catch (_) {}

    if (mounted && _studentName.isEmpty) {
      setState(() {
        _studentName = 'Qubah Student';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_studentName.isEmpty) {
      return const SizedBox.shrink();
    }

    return RepaintBoundary(
      child: IgnorePointer(
        ignoring: true,
        child: SafeArea(
          child: Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Opacity(
                opacity: widget.opacity,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _studentName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.none,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
