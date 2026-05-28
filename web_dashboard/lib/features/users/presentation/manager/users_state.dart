import 'package:equatable/equatable.dart';
import 'package:web_dashboard/features/users/data/models/user_model.dart';

enum UsersStatus { initial, loading, loaded, error }

class UsersState extends Equatable {
  final UsersStatus status;
  final List<UserModel> users;
  final List<UserModel> filteredUsers;
  final UserRole? selectedRole;
  final String searchQuery;
  final Set<int> selectedIds;
  final String? errorMessage;
  final int currentPage;
  final int itemsPerPage;

  const UsersState({
    this.status = UsersStatus.initial,
    this.users = const [],
    this.filteredUsers = const [],
    this.selectedRole,
    this.searchQuery = '',
    this.selectedIds = const {},
    this.errorMessage,
    this.currentPage = 1,
    this.itemsPerPage = 10,
  });

  int get totalPages => (filteredUsers.length / itemsPerPage).ceil().clamp(1, 999);

  List<UserModel> get paginatedUsers {
    final start = (currentPage - 1) * itemsPerPage;
    final end = start + itemsPerPage;
    if (start >= filteredUsers.length) return [];
    return filteredUsers.sublist(
      start,
      end > filteredUsers.length ? filteredUsers.length : end,
    );
  }

  int get totalCount => users.length;
  int get studentsCount => users.where((u) => u.role == UserRole.student).length;
  int get adminsCount => users.where((u) => u.role == UserRole.admin).length;

  UsersState copyWith({
    UsersStatus? status,
    List<UserModel>? users,
    List<UserModel>? filteredUsers,
    UserRole? selectedRole,
    bool clearRole = false,
    String? searchQuery,
    Set<int>? selectedIds,
    String? errorMessage,
    int? currentPage,
    int? itemsPerPage,
  }) {
    return UsersState(
      status: status ?? this.status,
      users: users ?? this.users,
      filteredUsers: filteredUsers ?? this.filteredUsers,
      selectedRole: clearRole ? null : (selectedRole ?? this.selectedRole),
      searchQuery: searchQuery ?? this.searchQuery,
      selectedIds: selectedIds ?? this.selectedIds,
      errorMessage: errorMessage ?? this.errorMessage,
      currentPage: currentPage ?? this.currentPage,
      itemsPerPage: itemsPerPage ?? this.itemsPerPage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        users,
        filteredUsers,
        selectedRole,
        searchQuery,
        selectedIds,
        errorMessage,
        currentPage,
        itemsPerPage,
      ];
}
