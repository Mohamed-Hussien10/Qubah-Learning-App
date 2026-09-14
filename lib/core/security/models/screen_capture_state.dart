import 'package:equatable/equatable.dart';

/// Represents the real-time screen capture and protection state.
class ScreenCaptureState extends Equatable {
  /// Whether the screen is currently being captured (screen recorded, mirrored, or AirPlayed).
  final bool isCaptured;

  /// Whether OS-level protection (e.g. FLAG_SECURE or display affinity) is currently enabled.
  final bool isProtected;

  /// Optional detail message.
  final String? message;

  const ScreenCaptureState({
    required this.isCaptured,
    required this.isProtected,
    this.message,
  });

  const ScreenCaptureState.initial()
      : isCaptured = false,
        isProtected = false,
        message = null;

  ScreenCaptureState copyWith({
    bool? isCaptured,
    bool? isProtected,
    String? message,
  }) {
    return ScreenCaptureState(
      isCaptured: isCaptured ?? this.isCaptured,
      isProtected: isProtected ?? this.isProtected,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [isCaptured, isProtected, message];
}
