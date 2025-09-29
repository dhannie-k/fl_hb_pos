// inventory_item_movement_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/datasources/supabase_datasource.dart';
import '../../../domain/entities/ledger_entry.dart';
import '../../../domain/entities/stock_movement.dart';
import 'inventory_item_movement_event.dart';
import 'inventory_item_movements_state.dart';

class InventoryItemMovementBloc
    extends Bloc<ItemMovementsEvent, ItemMovementsState> {
  final SupabaseDatasource dataSource;

  InventoryItemMovementBloc(this.dataSource) : super(ItemMovementsLoading()) {
    on<LoadItemMovements>(_onLoadItemMovements);
  }

  Future<void> _onLoadItemMovements(
    LoadItemMovements event,
    Emitter<ItemMovementsState> emit,
  ) async {
    emit(ItemMovementsLoading());
    try {
      // period defaults: first day of current month -> now
      final DateTime now = DateTime.now();
      final DateTime start =
          event.startDate ??
          DateTime(now.year, now.month, 1); // first day of current month
      final DateTime end = event.endDate ?? now;

      // Fetch all movements for this item (no date filter) so we can compute opening balance
      final List<StockMovement> allMovements = await dataSource
          .getStockMovements(
            startDate: null,
            endDate: null,
            direction: null,
            type: null,
            itemId: event.itemId,
          );

      // Ensure stock movements include product_item_id and are for this item (RPC returns for itemId filter already)
      final itemMovements =
          allMovements.where((m) => m.productItemId == event.itemId).toList()
            ..sort((a, b) => a.timestamp.compareTo(b.timestamp)); // ascending

      // Use UTC-safe comparisons
      final startUtc = start.toUtc();
      final endUtc = end.toUtc();

      // Opening balance = sum of quantities BEFORE start (strictly earlier)
      final double openingBalance = itemMovements
          .where((m) => m.timestamp.toUtc().isBefore(startUtc))
          .fold<double>(0.0, (sum, m) => sum + m.quantity);

      // Build ledger entries
      final List<LedgerEntry> entries = [];

      // Always add carried forward row (per your preference) — show zero if none
      entries.add(
        LedgerEntry(
          timestamp: start,
          type: 'carried_forward',
          qtyChange: 0.0,
          balance: openingBalance,
          note:
              'Opening balance as of ${start.toLocal().toString().split(' ')[0]}',
        ),
      );

      double running = openingBalance;

      // Movements IN period: timestamp >= start && timestamp <= end
      final movementsInPeriod = itemMovements.where((m) {
        final t = m.timestamp.toUtc();
        final afterOrEqStart = !t.isBefore(startUtc); // >= start
        final beforeOrEqEnd = !t.isAfter(endUtc); // <= end
        return afterOrEqStart && beforeOrEqEnd;
      }).toList();

      for (final m in movementsInPeriod) {
        running += m.quantity; // m.quantity already signed (+in, -out)
        entries.add(
          LedgerEntry(
            timestamp: m.timestamp,
            type: m.transactionType,
            qtyChange: m.quantity,
            balance: running,
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
