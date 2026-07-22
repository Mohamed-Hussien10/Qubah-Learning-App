import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_dashboard/features/packages/data/models/package_model.dart';
import 'package:web_dashboard/features/packages/data/repositories/packages_repository.dart';
import 'package:web_dashboard/features/packages/presentation/manager/packages_state.dart';

class PackagesCubit extends Cubit<PackagesState> {
  final PackagesRepository _repository;

  PackagesCubit({required PackagesRepository repository})
      : _repository = repository,
        super(const PackagesInitial());

  Future<void> loadPackages() async {
    emit(const PackagesLoading());
    try {
      final packages = await _repository.getPackages();
      emit(PackagesLoaded(
        packages: packages,
        filteredPackages: packages,
      ));
    } catch (e) {
      emit(PackagesError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  void filterPackages(String query) {
    if (state is! PackagesLoaded) return;
    final currentState = state as PackagesLoaded;
    if (query.trim().isEmpty) {
      emit(currentState.copyWith(
        filteredPackages: currentState.packages,
        searchQuery: '',
      ));
    } else {
      final filtered = currentState.packages.where((pkg) {
        final q = query.toLowerCase();
        return pkg.name.toLowerCase().contains(q) ||
            pkg.scopeText.toLowerCase().contains(q) ||
            (pkg.description?.toLowerCase().contains(q) ?? false);
      }).toList();
      emit(currentState.copyWith(
        filteredPackages: filtered,
        searchQuery: query,
      ));
    }
  }

  Future<void> createPackage(PackageModel package) async {
    try {
      await _repository.create(package);
      emit(const PackagesActionSuccess('تمت إضافة الباقة بنجاح'));
      await loadPackages();
    } catch (e) {
      emit(PackagesError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> updatePackage(PackageModel package) async {
    try {
      await _repository.update(package);
      emit(const PackagesActionSuccess('تم تحديث الباقة بنجاح'));
      await loadPackages();
    } catch (e) {
      emit(PackagesError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> deletePackage(String id) async {
    try {
      await _repository.delete(id);
      emit(const PackagesActionSuccess('تم حذف الباقة بنجاح'));
      await loadPackages();
    } catch (e) {
      emit(PackagesError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
