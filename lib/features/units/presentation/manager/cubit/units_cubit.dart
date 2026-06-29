import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/get_units_usecase.dart';
import '../state/units_state.dart';

class UnitsCubit extends Cubit<UnitsState> {
  final GetUnitsUseCase _getUnitsUseCase;

  UnitsCubit({required GetUnitsUseCase getUnitsUseCase})
    : _getUnitsUseCase = getUnitsUseCase,
      super(UnitsInitial());

  Future<void> loadUnits(String parentId) async {
    emit(UnitsLoading());
    try {
      final data = await _getUnitsUseCase(parentId);
      emit(UnitsLoaded(data));
    } catch (e) {
      emit(UnitsError(e.toString().split('Error: ').last.trim()));
    }
  }
}
