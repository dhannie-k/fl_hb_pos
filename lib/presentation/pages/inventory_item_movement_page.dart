import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/datasources/supabase_datasource.dart';
import '../bloc/inventory_item_movements/inventory_item_movement_bloc.dart';
import '../bloc/inventory_item_movements/inventory_item_movement_event.dart';
import '../bloc/inventory_item_movements/inventory_item_movements_state.dart';
import '../../domain/entities/ledger_entry.dart';
import 'package:intl/intl.dart';


class InventoryItemMovementsPage extends StatelessWidget {
  final int itemId;
  final String productName;
  final String itemSpec;
  const InventoryItemMovementsPage({super.key, required this.itemId, required this.productName, required this.itemSpec });

  @override
  Widget build(BuildContext context) {
    
    final bool isMobile = MediaQuery.of(context).size.width < 768;
    return BlocProvider(
      create: (_) => InventoryItemMovementBloc(SupabaseDatasource())
        ..add(LoadItemMovements(itemId)),
      child: Scaffold(
        appBar: AppBar(
          title: Text("Item Movements of $productName - $itemSpec "),
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
              return isMobile?
              _buildMobileList(state.entries) :
              _buildDesktopTable(state.entries);
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildMobileList(List<LedgerEntry> entries) {
    final dateFormat = DateFormat('dd-MMM-yyyy HH:mm'); 
    return ListView.separated(
      itemCount: entries.length,
      separatorBuilder: (_, _) => const Divider(),
      itemBuilder: (context, i) {
        final e = entries[i];
        final qtyPrefix = e.qtyChange > 0 ? "+" : "";
        final qtyColor =
            e.qtyChange > 0 ? Colors.green : (e.qtyChange < 0 ? Colors.red : Colors.grey);

        return ListTile(
          title: Text(
            e.type == "carried_forward"
                ? "Stok Awal"
                : e.type[0].toUpperCase() + e.type.substring(1),
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            "${dateFormat.format(e.timestamp.toLocal())} • ${e.note ?? ''}",
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          trailing: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (e.type != "carried_forward")
                Text(
                  "$qtyPrefix${e.qtyChange}",
                  style: TextStyle(
                    color: qtyColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              Text("Stock: ${e.balance}", style: const TextStyle(fontSize: 12)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDesktopTable(List<LedgerEntry> entries) {
    final dateFormat = DateFormat('dd-MMM-yyyy HH:mm'); 
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor:
            WidgetStatePropertyAll(Colors.grey.shade200),
        columns: const [
          DataColumn(label: Text("Date & Time")),
          DataColumn(label: Text("Movement Type")),
          DataColumn(label: Text("Qty Change")),
          DataColumn(label: Text("Balance")),
          DataColumn(label: Text("Note")),
        ],
        rows: entries.map((e) {
          final qtyPrefix = e.qtyChange > 0 ? "+" : "";
          final qtyColor =
              e.qtyChange > 0 ? Colors.green : (e.qtyChange < 0 ? Colors.red : Colors.grey);
          return DataRow(cells: [
            DataCell(Text(dateFormat.format(e.timestamp.toLocal()).toString())),
            DataCell(Text(
                e.type == "carried_forward" ? "Stok Awal" : e.type)),
            DataCell(Text(
              e.type == "carried_forward"
                  ? "-"
                  : "$qtyPrefix${e.qtyChange}",
              style: TextStyle(color: qtyColor),
            )),
            DataCell(Text("${e.balance}")),
            DataCell(Text(e.note ?? "")),
          ]);
        }).toList(),
      ),
    );
  }
}

  /* Widget _buildLedgerTile(LedgerEntry entry) {
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
            ? "Stok Awal"
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
            "Sisa Stok: ${entry.balance}",
            style: const TextStyle(fontSize: 12, color: Colors.black87),
          ),
        ],
      ),
    );
  } */


