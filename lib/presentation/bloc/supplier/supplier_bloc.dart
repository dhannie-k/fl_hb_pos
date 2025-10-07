import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/supplier.dart';
import '../../../domain/repositories/supplier_repository.dart';

part 'supplier_event.dart';
part 'supplier_state.dart';

class SupplierBloc extends Bloc<SupplierEvent, SupplierState> {
  final SupplierRepository _supplierRepository;

  SupplierBloc(this._supplierRepository) : super(SupplierInitial()) {
    on<LoadSuppliers>(_onLoadSuppliers);
    on<SearchSuppliers>(_onSearchSuppliers);
    on<AddSupplier>(_onAddSupplier);
    on<UpdateSupplier>(_onUpdateSupplier);
    on<DeleteSupplier>(_onDeleteSupplier);
  }

  Future<void> _onLoadSuppliers(
      LoadSuppliers event, Emitter<SupplierState> emit) async {
    emit(SupplierLoading());
    try {
      final suppliers = await _supplierRepository.getSuppliers();
      emit(SuppliersLoaded(suppliers));
    } catch (e) {
      emit(SupplierError(e.toString()));
    }
  }

  Future<void> _onSearchSuppliers(
      SearchSuppliers event, Emitter<SupplierState> emit) async {
    // We can only search if the main supplier list is already loaded.
    final currentState = state;
    if (currentState is SuppliersLoaded) {
      try {
        final results = await _supplierRepository.searchSuppliers(event.query);
        // Emit a new state with the search results
        emit(currentState.copyWith(searchResults: results));
      } catch (e) {
        emit(SupplierError('Failed to search suppliers: $e'));
      }
    }
  }

  Future<void> _onAddSupplier(
      AddSupplier event, Emitter<SupplierState> emit) async {
    try {
      final newSupplier = await _supplierRepository.addSupplier(
        name: event.name,
        address: event.address,
        phoneNumber: event.phoneNumber,
      );
      // Emit success state WITH the new supplier object, which is crucial for the UI
      emit(SupplierOperationSuccess('Supplier added!', newSupplier: newSupplier));
    } catch (e) {
      emit(SupplierError(e.toString()));
    }
  }

  Future<void> _onUpdateSupplier(
      UpdateSupplier event, Emitter<SupplierState> emit) async {
    try {
      await _supplierRepository.updateSupplier(event.supplier);
      emit(const SupplierOperationSuccess('Supplier updated successfully!'));
      add(LoadSuppliers()); // Refresh the main list
    } catch (e) {
      emit(SupplierError(e.toString()));
    }
  }

  Future<void> _onDeleteSupplier(
      DeleteSupplier event, Emitter<SupplierState> emit) async {
    try {
      await _supplierRepository.deleteSupplier(event.id);
      emit(const SupplierOperationSuccess('Supplier deleted successfully.'));
      add(LoadSuppliers()); // Refresh the main list
    } catch (e) {
      emit(SupplierError(e.toString()));
    }
  }
}

