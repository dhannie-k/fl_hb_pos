import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../bloc/inventory/inventory_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/inventory/inventory_state.dart';
import '../bloc/inventory/inventory_event.dart';


class InventoryItemDetailPage extends StatelessWidget {
  final int itemId;
  const InventoryItemDetailPage({super.key, required this.itemId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: context.read<InventoryBloc>()..add(LoadInventoryItem(itemId)),
      child: Scaffold(
        appBar: AppBar(title: const Text("Item Details")),
        body: BlocBuilder<InventoryBloc, InventoryState>(
          builder: (context, state) {
            if (state is InventoryLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is InventoryItemLoaded) {
              final item = state.item;
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.productName, style: Theme.of(context).textTheme.headlineSmall),
                    Text('Spec: ${item.specification}'),
                    Text('Stock: ${item.stock}'),
                    const Divider(),
                    ElevatedButton.icon(
                      onPressed: () => context.push('/inventory/items/${item.itemId}/movements'),
                      icon: const Icon(Icons.history),
                      label: const Text("View Movements"),
                    ),
                  ],
                ),
              );
            }
            return const Center(child: Text("Item not found"));
          },
        ),
      ),
    );
  }
}
