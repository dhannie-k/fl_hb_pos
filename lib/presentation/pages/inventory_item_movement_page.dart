import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../data/datasources/supabase_datasource.dart';
import '../bloc/inventory_item_movements/inventory_item_movement_bloc.dart';
import '../bloc/inventory_item_movements/inventory_item_movement_event.dart';
import '../bloc/inventory_item_movements/inventory_item_movements_state.dart';
import '../../domain/entities/ledger_entry.dart';

class InventoryItemMovementsPage extends StatefulWidget {
  final int itemId;
  final String productName;
  final String itemSpec;

  const InventoryItemMovementsPage({
    super.key,
    required this.itemId,
    required this.productName,
    required this.itemSpec,
  });

  @override
  State<InventoryItemMovementsPage> createState() =>
      _InventoryItemMovementsPageState();
}

class _InventoryItemMovementsPageState extends State<InventoryItemMovementsPage> {
  late DateTime _startDate;
  late DateTime _endDate;

  @override
  void initState() {
    super.initState();
    // Default to the current month
    final now = DateTime.now();
    _startDate = DateTime(now.year, now.month, 1);
    _endDate = now;
  }

  // Helper to format the date range for display
  String get _formattedDateRange {
    final DateFormat formatter = DateFormat('dd MMM yyyy');
    return '${formatter.format(_startDate)} - ${formatter.format(_endDate)}';
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 768;

    return BlocProvider(
      // The BLoC is created here and we immediately add the initial event
      create: (context) => InventoryItemMovementBloc(SupabaseDatasource())
        ..add(LoadItemMovements(
          //itemId: widget.itemId,
          widget.itemId,
          startDate: _startDate,
          endDate: _endDate,
        )),
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Movements: ${widget.productName}"),
              Text(
                _formattedDateRange,
                style: const TextStyle(fontSize: 14, color: Colors.white70),
              ),
            ],
          ),
          actions: [
            // We need the Builder to get the right context for the Bloc
            Builder(builder: (context) {
              return IconButton(
                icon: const Icon(Icons.calendar_today),
                tooltip: 'Select Date Range',
                onPressed: () => _showDateRangeFilter(context),
              );
            }),
          ],
        ),
        body: BlocBuilder<InventoryItemMovementBloc, ItemMovementsState>(
          builder: (context, state) {
            if (state is ItemMovementsLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ItemMovementsError) {
              return Center(child: Text("Error: ${state.message}"));
            } else if (state is ItemMovementsLoaded) {
              if (state.entries.isEmpty) {
                return const Center(child: Text("No movements found for this item in the selected period."));
              }
              return isMobile
                  ? _buildMobileList(state.entries)
                  : _buildDesktopTable(state.entries);
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  void _showDateRangeFilter(BuildContext blocContext) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text("Select Period", style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              ElevatedButton(
                child: const Text("This Month"),
                onPressed: () {
                  final now = DateTime.now();
                  _updateDateRangeAndReload(
                    blocContext,
                    DateTime(now.year, now.month, 1),
                    now,
                  );
                  Navigator.pop(context);
                },
              ),
              ElevatedButton(
                child: const Text("Last Month"),
                onPressed: () {
                  final now = DateTime.now();
                  final prevMonth = DateTime(now.year, now.month - 1, 1);
                  final endOfPrevMonth = DateTime(now.year, now.month, 0); // Day 0 gives last day of previous month
                  _updateDateRangeAndReload(
                    blocContext,
                    prevMonth,
                    endOfPrevMonth,
                  );
                  Navigator.pop(context);
                },
              ),
              OutlinedButton(
                child: const Text("Custom Range"),
                onPressed: () async {
                  Navigator.pop(context); // Close the bottom sheet first
                  final picked = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                    initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
                  );
                  if (picked != null) {
                    if(context.mounted){
                    _updateDateRangeAndReload(blocContext, picked.start, picked.end);
                    }
                  }
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _updateDateRangeAndReload(BuildContext blocContext, DateTime start, DateTime end) {
    setState(() {
      _startDate = start;
      // Set end date to the end of the day for inclusive filtering
      _endDate = DateTime(end.year, end.month, end.day, 23, 59, 59);
    });
    blocContext.read<InventoryItemMovementBloc>().add(LoadItemMovements(
          widget.itemId,
          startDate: _startDate,
          endDate: _endDate,
        ));
  }

  // _buildMobileList and _buildDesktopTable methods remain the same...
  Widget _buildMobileList(List<LedgerEntry> entries) {
    final dateFormat = DateFormat('dd-MMM-yyyy HH:mm');
    return ListView.separated(
      itemCount: entries.length,
      separatorBuilder: (_, _) => const Divider(),
      itemBuilder: (context, i) {
        final e = entries[i];
        final qtyPrefix = e.qtyChange > 0 ? "+" : "";
        final qtyColor = e.qtyChange > 0
            ? Colors.green
            : (e.qtyChange < 0 ? Colors.red : Colors.grey);

        return ListTile(
          title: Text(
            e.type == "carried_forward"
                ? "Opening Balance"
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
        headingRowColor: WidgetStatePropertyAll(Colors.grey.shade200),
        columns: const [
          DataColumn(label: Text("Date & Time")),
          DataColumn(label: Text("Movement Type")),
          DataColumn(label: Text("Qty Change")),
          DataColumn(label: Text("Balance")),
          DataColumn(label: Text("Note")),
        ],
        rows: entries.map((e) {
          final qtyPrefix = e.qtyChange > 0 ? "+" : "";
          final qtyColor = e.qtyChange > 0
              ? Colors.green
              : (e.qtyChange < 0 ? Colors.red : Colors.grey);
          return DataRow(cells: [
            DataCell(Text(dateFormat.format(e.timestamp.toLocal()).toString())),
            DataCell(Text(
                e.type == "carried_forward" ? "Opening Balance" : e.type)),
            DataCell(Text(
              e.type == "carried_forward" ? "-" : "$qtyPrefix${e.qtyChange}",
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