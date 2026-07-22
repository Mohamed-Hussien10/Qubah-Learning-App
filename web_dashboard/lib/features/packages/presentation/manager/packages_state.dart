import 'package:equatable/equatable.dart';
import 'package:web_dashboard/features/packages/data/models/package_model.dart';

abstract class PackagesState extends Equatable {
  const PackagesState();

  @override
  List<Object?> get props => [];
}

class PackagesInitial extends PackagesState {
  const PackagesInitial();
}

class PackagesLoading extends PackagesState {
  const PackagesLoading();
}

class PackagesLoaded extends PackagesState {
  final List<PackageModel> packages;
  final List<PackageModel> filteredPackages;
  final String searchQuery;

  const PackagesLoaded({
    required this.packages,
    required this.filteredPackages,
    this.searchQuery = '',
  });

  @override
  List<Object?> get props => [packages, filteredPackages, searchQuery];

  PackagesLoaded copyWith({
    List<PackageModel>? packages,
    List<PackageModel>? filteredPackages,
    String? searchQuery,
  }) {
    return PackagesLoaded(
      packages: packages ?? this.packages,
      filteredPackages: filteredPackages ?? this.filteredPackages,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class PackagesActionSuccess extends PackagesState {
  final String message;
  const PackagesActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class PackagesError extends PackagesState {
  final String message;
  const PackagesError(this.message);

  @override
  List<Object?> get props => [message];
}
