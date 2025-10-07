part of 'supplier_bloc.dart';

abstract class SupplierState extends Equatable {
  const SupplierState();
  @override
  List<Object?> get props => [];
}

class SupplierInitial extends SupplierState {}

class SupplierLoading extends SupplierState {}

class SuppliersLoaded extends SupplierState {
  final List<Supplier> suppliers;
  // Holds search results separately to not interfere with the main list
  final List<Supplier>? searchResults;

  const SuppliersLoaded(this.suppliers, {this.searchResults});

  SuppliersLoaded copyWith({
    List<Supplier>? suppliers,
    List<Supplier>? searchResults,
  }) {
    return SuppliersLoaded(
      suppliers ?? this.suppliers,
      searchResults: searchResults ?? this.searchResults,
    );
  }

  @override
  List<Object?> get props => [suppliers, searchResults];
}

class SupplierOperationSuccess extends SupplierState {
  final String message;
  // This will carry the newly created supplier back to the UI
  final Supplier? newSupplier;
  const SupplierOperationSuccess(this.message, {this.newSupplier});
}

class SupplierError extends SupplierState {
  final String message;
  const SupplierError(this.message);
}

