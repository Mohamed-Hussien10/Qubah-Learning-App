import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_dashboard/features/subjects/data/models/subject_model.dart';
import 'package:web_dashboard/features/units/data/models/unit_model.dart';
import 'package:web_dashboard/features/units/data/repositories/units_repository.dart';
import 'package:web_dashboard/features/units/presentation/manager/units_state.dart';

class UnitsCubit extends Cubit<UnitsState> {
  final UnitsRepository _repository;
  late String _subjectId;

  UnitsCubit({required UnitsRepository repository})
      : _repository = repository,
        super(const UnitsInitial());

  Future<void> loadUnits(String subjectId) async {
    _subjectId = subjectId;
    emit(const UnitsLoading());
    try {
      final units = await _repository.getBySubjectId(subjectId);
      String subjectName = 'المادة';
      for (final subjects in SubjectModel.dummyMap.values) {
        for (final s in subjects) {
          if (s.id == subjectId) {
            subjectName = s.title;
            break;
          }
        }
      }
      emit(UnitsLoaded(
        units: units,
        filteredUnits: units,
        subjectId: subjectId,
        subjectName: subjectName,
      ));
    } catch (e) {
      emit(UnitsError(e.toString()));
    }
  }

  Future<void> createUnit(UnitModel unit, {List<int>? imageBytes, String? imageName}) async {
    try {
      await _repository.create(unit, imageBytes: imageBytes, imageName: imageName);
      await loadUnits(_subjectId);
    } catch (e) {
      emit(UnitsError(e.toString()));
    }
  }

  Future<void> updateUnit(UnitModel unit, {List<int>? imageBytes, String? imageName}) async {
    try {
      await _repository.update(unit, imageBytes: imageBytes, imageName: imageName);
      await loadUnits(_subjectId);
    } catch (e) {
      emit(UnitsError(e.toString()));
    }
  }

  Future<void> deleteUnit(String id) async {
    try {
      await _repository.delete(_subjectId, id);
      await loadUnits(_subjectId);
    } catch (e) {
      emit(UnitsError(e.toString()));
    }
  }

  Future<void> toggleStatus(String id) async {
    try {
      await _repository.toggleStatus(_subjectId, id);
      await loadUnits(_subjectId);
    } catch (e) {
      emit(UnitsError(e.toString()));
    }
  }

  void search(String query) {
    final currentState = state;
    if (currentState is UnitsLoaded) {
      if (query.isEmpty) {
        emit(currentState.copyWith(
          filteredUnits: currentState.units,
          searchQuery: '',
        ));
      } else {
        final filtered = currentState.units.where((u) {
          final q = query.toLowerCase();
          return u.title.toLowerCase().contains(q) ||
              (u.description?.toLowerCase().contains(q) ?? false);
        }).toList();
        emit(currentState.copyWith(
          filteredUnits: filtered,
          searchQuery: query,
        ));
      }
    }
  }
}
