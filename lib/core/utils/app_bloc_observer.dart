import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/logger_service.dart';

/// ──────────────────────────────────────────────────────────────────────────────
/// AppBlocObserver
///
/// Custom BlocObserver that logs Bloc lifecycle events, state changes, and
/// unhandled errors using the centralized LoggerService.
/// ──────────────────────────────────────────────────────────────────────────────
class AppBlocObserver extends BlocObserver {
  @override
  void onCreate(BlocBase bloc) {
    super.onCreate(bloc);
    LoggerService.instance.debug('🟢 [Bloc Created] ${bloc.runtimeType}');
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    LoggerService.instance.debug(
      '🔄 [Bloc Change] in ${bloc.runtimeType}:\n'
      '   Current: ${change.currentState}\n'
      '   Next:    ${change.nextState}',
    );
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    LoggerService.instance.error(
      '🔴 [Bloc Error] in ${bloc.runtimeType}',
      error: error,
      stackTrace: stackTrace,
    );
  }

  @override
  void onClose(BlocBase bloc) {
    super.onClose(bloc);
    LoggerService.instance.debug('🚫 [Bloc Closed] ${bloc.runtimeType}');
  }
}
