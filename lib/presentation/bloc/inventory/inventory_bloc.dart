import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/inventory.dart';
import '../../../domain/repositories/product_repository.dart';
import '../../bloc/inventory/inventory_event.dart';
import '../../bloc/inventory/inventory_state.dart';

class InventoryBloc extends Bloc<InventoryEvent, InventoryState> {
  final ProductRepository repository;

  InventoryBloc(this.repository) : super(InventoryInitial()) {
    on<LoadInventory>(_onLoadInventory);
    on<RefreshInventory>(_onRefreshInventory);
  }

  Future<void> _onLoadInventory(
    LoadInventory event,
    Emitter<InventoryState> emit,
  ) async {
    emit(InventoryLoading());
    try {
      final data = await repository.getInventory();
      final items = data.map((json) => InventoryItem.fromJson(json)).toList();
      emit(InventoryLoaded(items));
      //emit(const InventoryOperationSuccess('Inventory refreshed'));
    } catch (e) {
      emit(InventoryError('Failed to load inventory: $e'));
    }
  }

  Future<void> _onRefreshInventory(
    RefreshInventory event,
    Emitter<InventoryState> emit,
  ) async {
    try {
      final data = await repository.getInventory();
      final items = data.map((json) => InventoryItem.fromJson(json)).toList();
      emit(InventoryLoaded(items, message: 'Inventory refreshed'));
    } catch (e) {
      emit(InventoryError('Failed to refresh inventory: $e'));
    }
  }
}
