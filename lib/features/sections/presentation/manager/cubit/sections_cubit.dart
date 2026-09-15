import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/get_sections_usecase.dart';
import '../state/sections_state.dart';
import 'package:qubah_learning_app/core/errors/error_handler.dart';

class SectionsCubit extends Cubit<SectionsState> {
  final GetSectionsUseCase _getSectionsUseCase;
  String? _lastParentId;

  SectionsCubit({required GetSectionsUseCase getSectionsUseCase})
    : _getSectionsUseCase = getSectionsUseCase,
      super(SectionsInitial());

  Future<void> loadSections(String parentId, {bool forceRefresh = false}) async {
    // Skip reload if same parent's data is already loaded
    if (_lastParentId == parentId && state is SectionsLoaded && !forceRefresh) return;

    emit(SectionsLoading());
    try {
      final data = await _getSectionsUseCase(parentId);
      _lastParentId = parentId;
      emit(SectionsLoaded(data));
    } catch (e) {
      emit(SectionsError(ErrorHandler.handle(e)));
    }
  }
}
