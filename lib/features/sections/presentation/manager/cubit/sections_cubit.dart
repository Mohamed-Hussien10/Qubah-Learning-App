import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/get_sections_usecase.dart';
import '../state/sections_state.dart';
import 'package:qubah_learning_app/core/errors/error_handler.dart';

class SectionsCubit extends Cubit<SectionsState> {
  final GetSectionsUseCase _getSectionsUseCase;

  SectionsCubit({required GetSectionsUseCase getSectionsUseCase})
    : _getSectionsUseCase = getSectionsUseCase,
      super(SectionsInitial());

  Future<void> loadSections(String parentId) async {
    emit(SectionsLoading());
    try {
      final data = await _getSectionsUseCase(parentId);
      emit(SectionsLoaded(data));
    } catch (e) {
      emit(SectionsError(ErrorHandler.handle(e)));
    }
  }
}
