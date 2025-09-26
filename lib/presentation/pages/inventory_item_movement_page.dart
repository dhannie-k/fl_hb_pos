import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/datasources/supabase_datasource.dart';
import '../bloc/inventory_item_movements/inventory_item_movement_bloc.dart';
import '../bloc/inventory_item_movements/inventory_item_movement_event.dart';
import '../bloc/inventory_item_movements/inventory_item_movements_state.dart';
import '../../domain/entities/ledger_entry.dart';

class InventoryItemMovementsPage extends StatelessWidget {
  final int itemId;
  const InventoryItemMovementsPage({super.key, required this.itemId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => InventoryItemMovementBloc(SupabaseDatasource())
        ..add(LoadItemMovements(itemId)),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Item Movements"),
        ),
        body: BlocBuilder<InventoryItemMovementBloc, ItemMovementsState>(
          builder: (context, state) {
            if (state is ItemMovementsLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ItemMovementsError) {
              return Center(
                child: Text("Error: ${state.message}"),
              );
            } else if (state is ItemMovementsLoaded) {
              if (state.entries.isEmpty) {
                return const Center(
                  child: Text("No movements found for this item."),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(8),
                itemCount: state.entries.length,
                separatorBuilder: (_, _) =>
                    const Divider(height: 1, thickness: 0.5),
                itemBuilder: (context, index) {
                  final entry = state.entries[index];
                  return _buildLedgerTile(entry);
                },
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildLedgerTile(LedgerEntry entry) {
    final isIn = entry.qtyChange >= 0;
    final qtyPrefix = entry.type == "carried_forward"
        ? "" // no prefix for carried forward
        : isIn
            ? "+"
            : "–";
    final qtyColor = entry.type == "carried_forward"
        ? Colors.grey
        : isIn
            ? Colors.green
            : Colors.red;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      title: Text(
        entry.type == "carried_forward"
            ? "Carried Forward"
            : entry.type[0].toUpperCase() + entry.type.substring(1),
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            entry.timestamp.toLocal().toString(),
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          if (entry.note != null && entry.note!.isNotEmpty)
            Text(
              entry.note!,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
        ],
      ),
      trailing: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            "$qtyPrefix${entry.qtyChange.abs()}",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: qtyColor,
            ),
          ),
          Text(
            "Bal: ${entry.balance}",
            style: const TextStyle(fontSize: 12, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}
