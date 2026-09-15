import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/get_units_usecase.dart';
import '../state/units_state.dart';
import 'package:qubah_learning_app/core/errors/error_handler.dart';

class UnitsCubit extends Cubit<UnitsState> {
  final GetUnitsUseCase _getUnitsUseCase;
  String? _lastParentId;

  UnitsCubit({required GetUnitsUseCase getUnitsUseCase})
    : _getUnitsUseCase = getUnitsUseCase,
      super(UnitsInitial());

  Future<void> loadUnits(String parentId, {bool forceRefresh = false}) async {
    // Skip reload if same parent's data is already loaded
    if (_lastParentId == parentId && state is UnitsLoaded && !forceRefresh) return;

    emit(UnitsLoading());
    try {
      final data = await _getUnitsUseCase(parentId);
      _lastParentId = parentId;
      emit(UnitsLoaded(data));
    } catch (e) {
      emit(UnitsError(ErrorHandler.handle(e)));
    }
  }
}
