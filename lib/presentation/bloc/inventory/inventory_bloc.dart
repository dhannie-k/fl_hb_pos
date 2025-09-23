import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/inventory.dart';
import '../../../domain/repositories/inventory_repository.dart';
import '../../bloc/inventory/inventory_event.dart';
import '../../bloc/inventory/inventory_state.dart';

class InventoryBloc extends Bloc<InventoryEvent, InventoryState> {
  final InventoryRepository repository;
  List<InventoryItem> _allItems = [];

  InventoryBloc(this.repository) : super(InventoryInitial()) {
    on<LoadInventory>(_onLoadInventory);
    on<RefreshInventory>(_onRefreshInventory);
    on<SearchInventory>(_onSearchInventory);
    on<AdjustStock>(_onAdjustStock);
    on<LoadInventoryItem>(_onLoadInventoryItem);
  }

  Future<void> _onLoadInventory(
    LoadInventory event,
    Emitter<InventoryState> emit,
  ) async {
    emit(InventoryLoading());
    try {
      final items = await repository.getInventory();
      _allItems = items;
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
      final items = await repository.getInventory();
      _allItems = items;
      emit(InventoryLoaded(items, message: 'Inventory refreshed'));
    } catch (e) {
      emit(InventoryError('Failed to refresh inventory: $e'));
    }
  }

  void _onSearchInventory(SearchInventory event, Emitter<InventoryState> emit) {
    if (event.query.isEmpty) {
      emit(InventoryLoaded(_allItems));
      return;
    }

    final lowerQuery = event.query.toLowerCase();
    final filtered = _allItems.where((item) {
      return item.productName.toLowerCase().contains(lowerQuery) ||
          (item.brand?.toLowerCase().contains(lowerQuery) ?? false) ||
          (item.specification.toLowerCase().contains(lowerQuery)) ||
          (item.color?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();

    emit(InventoryLoaded(filtered));
  }

  Future<void> _onAdjustStock(
    AdjustStock event,
    Emitter<InventoryState> emit,
  ) async {
    try {
      // optimistic update (optional)
      emit(InventoryLoading());

      await repository.adjustStock(event.itemId, event.quantity, event.direction,note: event.note);

      // reload items after adjustment
      final items = await repository.getInventory();
      _allItems = items;

      emit(InventoryLoaded(_allItems, message: 'Stock adjusted successfully'));
    } catch (e) {
      emit(InventoryError('Failed to adjust stock: $e'));
    }
  }

  Future<void> _onLoadInventoryItem(
    LoadInventoryItem event,
    Emitter<InventoryState> emit,
  ) async {
    emit(InventoryLoading());
    try {
      final items = await repository.getInventory();
      final item = items.firstWhere(
        (it) => it.itemId == event.itemId,
        orElse: () => throw Exception("Item not found"),
      );
      emit(InventoryItemLoaded(item));
    } catch (e) {
      emit(InventoryError('Failed to load item: $e'));
    }
  }
}
