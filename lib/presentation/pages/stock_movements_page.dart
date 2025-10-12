import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/constans/app_colors.dart';
import '../bloc/stock_movements/stock_movements_bloc.dart';
import '../bloc/stock_movements/stock_movements_event.dart';
import '../bloc/stock_movements/stock_movements_state.dart';
import '../../domain/entities/stock_movement.dart';
import '../../data/datasources/supabase_datasource.dart';

class StockMovementsPage extends StatelessWidget {
  const StockMovementsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          StockMovementsBloc(SupabaseDatasource())
            ..add(const LoadStockMovements()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Stock Movements"),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                context.read<StockMovementsBloc>().add(RefreshStockMovements());
              },
            ),
          ],
        ),
        body: const _StockMovementsBody(),
      ),
    );
  }
}

class _StockMovementsBody extends StatelessWidget {
  const _StockMovementsBody();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _FiltersBar(),
        Expanded(
          child: BlocBuilder<StockMovementsBloc, StockMovementsState>(
            builder: (context, state) {
              if (state is StockMovementsLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is StockMovementsError) {
                return Center(
                  child: Text(
                    "Error: ${state.message}",
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              } else if (state is StockMovementsLoaded) {
                if (state.movements.isEmpty) {
                  return const Center(child: Text("No stock movements found."));
                }
                return ListView.separated(
                  itemCount: state.movements.length,
                  separatorBuilder: (_, _) =>
                      Divider(color: AppColors.divider),
                  itemBuilder: (context, index) {
                    final movement = state.movements[index];
                    return _buildMovementTile(movement);
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMovementTile(StockMovement movement) {
    final dateFormat = DateFormat('dd-MMM-yyyy HH:mm');
    final isIn = movement.direction.toLowerCase() == "in";
    final qtyColor = isIn ? Colors.green : Colors.red;
    final qtyPrefix = isIn ? "+" : "";

    final title = [
      movement.productName,
      if (movement.specification != null && movement.specification!.isNotEmpty)
        movement.specification!,
      if (movement.color != null && movement.color!.isNotEmpty)
        "- ${movement.color!}",
    ].join(" ");

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (movement.brand != null)
            Text(
              movement.brand!,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          const SizedBox(height: 2),
          Text(
            "${dateFormat.format(movement.timestamp.toLocal())} • ${movement.note ?? ''}",
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
        ],
      ),
      trailing: Text(
        "$qtyPrefix${movement.quantity}",
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: qtyColor,
        ),
      ),
    );
  }
}

class _FiltersBar extends StatelessWidget {
  const _FiltersBar();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 🔽 Filters
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: BlocBuilder<StockMovementsBloc, StockMovementsState>(
            builder: (context, state) {
              String? activeDirection;
              String? activeType;
              DateTimeRange? activeRange;

              if (state is StockMovementsLoaded) {
                activeDirection = state.direction;
                activeType = state.type;
                if (state.startDate != null && state.endDate != null) {
                  activeRange = DateTimeRange(
                    start: state.startDate!,
                    end: state.endDate!,
                  );
                }
              }

              return Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  // Direction filter
                  ChoiceChip(
                    label: const Text("All"),
                    selected: activeDirection == null,
                    onSelected: (_) {
                      context.read<StockMovementsBloc>().add(
                        const LoadStockMovements(),
                      );
                    },
                  ),
                  ChoiceChip(
                    label: const Text("In"),
                    selected: activeDirection == "in",
                    onSelected: (_) {
                      context.read<StockMovementsBloc>().add(
                        const LoadStockMovements(direction: "in"),
                      );
                    },
                  ),
                  ChoiceChip(
                    label: const Text("Out"),
                    selected: activeDirection == "out",
                    onSelected: (_) {
                      context.read<StockMovementsBloc>().add(
                        const LoadStockMovements(direction: "out"),
                      );
                    },
                  ),

                  // Transaction type filter
                  DropdownButton<String>(
                    value: activeType,
                    hint: const Text("Type"),
                    items: const [
                      DropdownMenuItem(
                        value: "purchase",
                        child: Text("Purchase"),
                      ),
                      DropdownMenuItem(value: "sale", child: Text("Sale")),
                      DropdownMenuItem(
                        value: "adjustment",
                        child: Text("Adjustment"),
                      ),
                      DropdownMenuItem(
                        value: "salereturn",
                        child: Text("Sale Return"),
                      ),
                      DropdownMenuItem(
                        value: "purchasereturn",
                        child: Text("Purchase Return"),
                      ),
                      DropdownMenuItem(
                        value: "initialquantity",
                        child: Text("Initial Stock"),
                      ),
                    ],
                    onChanged: (value) {
                      context.read<StockMovementsBloc>().add(
                        LoadStockMovements(type: value),
                      );
                    },
                  ),

                  // Date range filter
                  TextButton.icon(
                    icon: const Icon(Icons.date_range),
                    label: Text(
                      activeRange == null
                          ? "Select Date Range"
                          : "${activeRange.start.toLocal().toString().split(' ')[0]} - ${activeRange.end.toLocal().toString().split(' ')[0]}",
                    ),
                    onPressed: () async {
                      final picked = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                        initialDateRange: activeRange,
                      );
                      if (picked != null) {
                        if (!context.mounted) return;
                        context.read<StockMovementsBloc>().add(
                          LoadStockMovements(
                            startDate: picked.start,
                            endDate: picked.end,
                            direction: activeDirection,
                            type: activeType,
                          ),
                        );
                      }
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
