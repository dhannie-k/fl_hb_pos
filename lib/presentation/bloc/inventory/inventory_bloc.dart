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
    on<SearchProductItems>(_onSearchProductItems);
  }

  Future<void> _onLoadInventory(
    LoadInventory event,
    Emitter<InventoryState> emit,
  ) async {
    emit(InventoryLoading());
    try {
      final items = await repository.getInventory();
      _allItems = items;
      emit(InventoryLoaded(items, searchResults: []));
      //emit(const InventoryOperationSuccess('Inventory refreshed'));
    } catch (e) {
      emit(InventoryError('Failed to load inventory: $e'));
    }
  }

  Future<void> _onRefreshInventory(
    RefreshInventory event,
    Emitter<InventoryState> emit,
  ) async {
    // No loading state needed for a pull-to-refresh action
    try {
      final items = await repository.getInventory();
      emit(InventoryLoaded(items, searchResults: [], message: 'Inventory refreshed'));
    } catch (e) {
      // If refresh fails, show an error but keep the old data if available
      if (state is InventoryLoaded) {
        final currentState = state as InventoryLoaded;
        emit(currentState.copyWith(message: 'Failed to refresh: $e'));
      } else {
        emit(InventoryError('Failed to refresh inventory: $e'));
      }
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
      emit(InventoryLoaded(_allItems, message: 'Stock adjusted successfully'));
      // After adjustment, reload all inventory to ensure data consistency
      add(const RefreshInventory());

      /* // reload items after adjustment
      final items = await repository.getInventory();
      _allItems = items; */

    } catch (e) {
      emit(InventoryError('Failed to adjust stock: $e'));
      // After an error, it's good practice to reload the original state
      add(const LoadInventory());
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

  Future<void> _onSearchProductItems(
    SearchProductItems event,
    Emitter<InventoryState> emit,
  ) async {
    // We only perform search when the state is already InventoryLoaded
    if (state is InventoryLoaded) {
      final currentState = state as InventoryLoaded;

      // Emit a state to show a loading indicator in the dialog
      // by setting searchResults to null
      emit(currentState.copyWith(searchResults: null));
      
      try {
        final results = await repository.searchProductItems(event.query);
        // Emit the final state with the search results
        emit(currentState.copyWith(searchResults: results));
      } catch (e) {
        // If search fails, emit an empty list and maybe log the error
        emit(currentState.copyWith(searchResults: []));
        // You could also add an error message to the state if you want to display it
      }
    }
  }
  
}

