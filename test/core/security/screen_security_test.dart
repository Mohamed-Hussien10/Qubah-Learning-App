import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qubah_learning_app/core/security/models/screen_capture_state.dart';
import 'package:qubah_learning_app/core/security/screen_security_service.dart';
import 'package:qubah_learning_app/core/security/protected_lesson_scaffold.dart';
import 'package:qubah_learning_app/core/security/student_watermark_overlay.dart';
import 'package:qubah_learning_app/core/services/dependency_injection.dart';
import 'package:qubah_learning_app/core/storage/secure_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ScreenCaptureState', () {
    test('initial state is not captured and not protected', () {
      const state = ScreenCaptureState.initial();
      expect(state.isCaptured, isFalse);
      expect(state.isProtected, isFalse);
      expect(state.message, isNull);
    });

    test('copyWith updates fields correctly', () {
      const state = ScreenCaptureState.initial();
      final updated = state.copyWith(isCaptured: true, isProtected: true, message: 'Alert');
      expect(updated.isCaptured, isTrue);
      expect(updated.isProtected, isTrue);
      expect(updated.message, equals('Alert'));
    });

    test('equality works based on values', () {
      const state1 = ScreenCaptureState(isCaptured: true, isProtected: true);
      const state2 = ScreenCaptureState(isCaptured: true, isProtected: true);
      const state3 = ScreenCaptureState(isCaptured: false, isProtected: true);

      expect(state1, equals(state2));
      expect(state1, isNot(equals(state3)));
    });
  });

  group('ScreenSecurityService', () {
    late ScreenSecurityService service;

    setUp(() {
      service = ScreenSecurityService();
    });

    tearDown(() {
      service.dispose();
    });

    test('reference counting enables and disables protection correctly', () async {
      expect(service.isProtectionActive, isFalse);

      await service.enableProtection();
      expect(service.isProtectionActive, isTrue);

      // Second screen enters
      await service.enableProtection();
      expect(service.isProtectionActive, isTrue);

      // First screen leaves (ref count 1)
      await service.disableProtection();
      expect(service.isProtectionActive, isTrue);

      // Second screen leaves (ref count 0)
      await service.disableProtection();
      expect(service.isProtectionActive, isFalse);
    });

    test('forceDisableProtection disables protection immediately', () async {
      await service.enableProtection();
      await service.enableProtection();
      expect(service.isProtectionActive, isTrue);

      await service.forceDisableProtection();
      expect(service.isProtectionActive, isFalse);
    });
  });

  group('ProtectedLessonScaffold & StudentWatermarkOverlay Widgets', () {
    setUp(() {
      if (!sl.isRegistered<ScreenSecurityService>()) {
        sl.registerLazySingleton<ScreenSecurityService>(() => ScreenSecurityService());
      }
      if (!sl.isRegistered<SecureStorage>()) {
        sl.registerLazySingleton<SecureStorage>(() => SecureStorage());
      }
    });

    testWidgets('renders child and watermark overlay by default', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ProtectedLessonScaffold(
            withWatermark: true,
            child: Text('Protected Video Player Content'),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('Protected Video Player Content'), findsOneWidget);
      expect(find.byType(StudentWatermarkOverlay), findsOneWidget);
    });
  });
}
