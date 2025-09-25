import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
      create: (_) => StockMovementsBloc(SupabaseDatasource())
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
        body: Column(
          children: [
            // 🔽 Filter row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: BlocBuilder<StockMovementsBloc, StockMovementsState>(
                builder: (context, state) {
                  String? activeFilter;
                  if (state is StockMovementsLoaded) {
                    activeFilter = state.direction;
                  }

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ChoiceChip(
                        label: const Text("All"),
                        selected: activeFilter == null,
                        onSelected: (_) {
                          context
                              .read<StockMovementsBloc>()
                              .add(const LoadStockMovements());
                        },
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Text("In"),
                        selected: activeFilter == "in",
                        onSelected: (_) {
                          context
                              .read<StockMovementsBloc>()
                              .add(const LoadStockMovements(direction: "in"));
                        },
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Text("Out"),
                        selected: activeFilter == "out",
                        onSelected: (_) {
                          context
                              .read<StockMovementsBloc>()
                              .add(const LoadStockMovements(direction: "out"));
                        },
                      ),
                    ],
                  );
                },
              ),
            ),

            // 🔽 The list
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
                      separatorBuilder: (_, __) =>
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
        ),
      ),
    );
  }

  Widget _buildMovementTile(StockMovement movement) {
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
    title: Text(
      title,
      style: const TextStyle(fontWeight: FontWeight.w600),
    ),
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
          "${movement.timestamp} • ${movement.note ?? ''}",
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

