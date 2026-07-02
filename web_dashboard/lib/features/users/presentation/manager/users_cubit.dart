import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_dashboard/features/users/data/models/user_model.dart';
import 'package:web_dashboard/features/users/data/repositories/users_repository.dart';
import 'package:web_dashboard/features/users/presentation/manager/users_state.dart';
import 'package:web_dashboard/core/errors/error_handler.dart';

class UsersCubit extends Cubit<UsersState> {
  final UsersRepository _repository;

  UsersCubit(this._repository) : super(const UsersState());

  Future<void> loadUsers() async {
    safeEmit(state.copyWith(status: UsersStatus.loading));
    try {
      final users = await _repository.getAll();
      safeEmit(state.copyWith(
        status: UsersStatus.loaded,
        users: users,
        filteredUsers: users,
      ));
    } catch (e) {
      safeEmit(state.copyWith(
        status: UsersStatus.error,
        errorMessage: ErrorHandler.handle(e),
      ));
    }
  }

  Future<void> createUser({
    required String name,
    required String email,
    required String password,
    required UserRole role,
    bool isActive = true,
    int? stageId,
    int? gradeId,
  }) async {
    try {
      await _repository.create(
        name: name,
        email: email,
        password: password,
        role: role,
        isActive: isActive,
        stageId: stageId,
        gradeId: gradeId,
      );
      await loadUsers();
      _applyFilters();
    } catch (e) {
      safeEmit(state.copyWith(
        status: UsersStatus.error,
        errorMessage: ErrorHandler.handle(e),
      ));
    }
  }

  Future<void> updateUser(UserModel user) async {
    try {
      await _repository.update(user);
      await loadUsers();
      _applyFilters();
    } catch (e) {
      safeEmit(state.copyWith(
        status: UsersStatus.error,
        errorMessage: ErrorHandler.handle(e),
      ));
    }
  }

  Future<void> deleteUser(int id) async {
    try {
      await _repository.delete(id);
      final updatedSelected = Set<int>.from(state.selectedIds)..remove(id);
      safeEmit(state.copyWith(selectedIds: updatedSelected));
      await loadUsers();
      _applyFilters();
    } catch (e) {
      safeEmit(state.copyWith(
        status: UsersStatus.error,
        errorMessage: ErrorHandler.handle(e),
      ));
    }
  }

  Future<void> deleteSelected() async {
    try {
      for (final id in state.selectedIds) {
        await _repository.delete(id);
      }
      safeEmit(state.copyWith(selectedIds: {}));
      await loadUsers();
      _applyFilters();
    } catch (e) {
      safeEmit(state.copyWith(
        status: UsersStatus.error,
        errorMessage: ErrorHandler.handle(e),
      ));
    }
  }

  Future<void> toggleStatus(int id) async {
    try {
      await _repository.toggleStatus(id);
      await loadUsers();
      _applyFilters();
    } catch (e) {
      safeEmit(state.copyWith(
        status: UsersStatus.error,
        errorMessage: ErrorHandler.handle(e),
      ));
    }
  }

  void search(String query) {
    safeEmit(state.copyWith(searchQuery: query, currentPage: 1));
    _applyFilters();
  }

  void filterByRole(UserRole? role) {
    if (role == null) {
      safeEmit(state.copyWith(clearRole: true, currentPage: 1));
    } else {
      safeEmit(state.copyWith(selectedRole: role, currentPage: 1));
    }
    _applyFilters();
  }

  void toggleSelection(int id) {
    final selectedIds = Set<int>.from(state.selectedIds);
    if (selectedIds.contains(id)) {
      selectedIds.remove(id);
    } else {
      selectedIds.add(id);
    }
    safeEmit(state.copyWith(selectedIds: selectedIds));
  }

  void selectAll() {
    if (state.selectedIds.length == state.filteredUsers.length) {
      safeEmit(state.copyWith(selectedIds: {}));
    } else {
      safeEmit(state.copyWith(
        selectedIds: state.filteredUsers.map((u) => u.id).toSet(),
      ));
    }
  }

  void changePage(int page) {
    safeEmit(state.copyWith(currentPage: page));
  }

  void _applyFilters() {
    var filtered = List<UserModel>.from(state.users);

    // Filter by role
    if (state.selectedRole != null) {
      filtered = filtered.where((u) => u.role == state.selectedRole).toList();
    }

    // Filter by search
    if (state.searchQuery.isNotEmpty) {
      filtered = filtered
          .where((u) =>
              u.name.contains(state.searchQuery) ||
              u.email.contains(state.searchQuery))
          .toList();
    }

    safeEmit(state.copyWith(filteredUsers: filtered));
  }

  void safeEmit(UsersState newState) {
    if (!isClosed) {
      emit(newState);
    }
  }
}
