import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/datasources/supabase_datasource.dart';
import 'inventory_item_movements_state.dart';
import 'inventory_item_movement_event.dart';
import '/../domain/entities/ledger_entry.dart';

class InventoryItemMovementBloc
    extends Bloc<ItemMovementsEvent, ItemMovementsState> {
  final SupabaseDatasource dataSource;

  InventoryItemMovementBloc(this.dataSource)
      : super(ItemMovementsLoading()) {
    on<LoadItemMovements>(_onLoadItemMovements);
  }

  Future<void> _onLoadItemMovements(
    LoadItemMovements event,
    Emitter<ItemMovementsState> emit,
  ) async {
    emit(ItemMovementsLoading());
    try {
      // 1. Fetch current stock
      final currentStock = await dataSource.getCurrentStock(event.itemId);

      // 2. Fetch stock movements for this item
      final movements = await dataSource.getStockMovements(
        startDate: event.startDate,
        endDate: event.endDate,
        type: null,
        direction: null,
      );

      final itemMovements = movements
          .where((m) => m.sku != null) // ensure item movements
          .toList()
        ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

      // 3. Calculate opening balance
      final afterStart = itemMovements
          .where((m) =>
              event.startDate != null && m.timestamp.isAfter(event.startDate!))
          .fold<double>(0, (sum, m) => sum + m.quantity);

      final openingBalance = currentStock - afterStart;

      // 4. Build ledger
      final List<LedgerEntry> entries = [];
      entries.add(
        LedgerEntry(
          timestamp: event.startDate ?? DateTime.now(),
          type: "carried_forward",
          qtyChange: 0,
          balance: openingBalance,
        ),
      );

      double runningBalance = openingBalance;
      for (final m in itemMovements) {
        runningBalance += m.quantity;
        entries.add(
          LedgerEntry(
            timestamp: m.timestamp,
            type: m.transactionType,
            qtyChange: m.quantity,
            balance: runningBalance,
            note: m.note,
          ),
        );
      }

      emit(ItemMovementsLoaded(entries));
    } catch (e) {
      emit(ItemMovementsError(e.toString()));
    }
  }
}
