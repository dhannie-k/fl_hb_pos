import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/inventory.dart';
import '../../bloc/inventory/inventory_bloc.dart';
import '../../bloc/inventory/inventory_state.dart';
import '../../bloc/inventory/inventory_event.dart';

class StockTab extends StatefulWidget {
  const StockTab({super.key});

  @override
  State<StockTab> createState() => _StockTabState();
}

class _StockTabState extends State<StockTab> {
  @override
  void initState() {
    super.initState();
    context.read<InventoryBloc>().add(const LoadInventory());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: BlocConsumer<InventoryBloc, InventoryState>(
            listener: (context, state) {
              if (state is InventoryOperationSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.green,
                  ),
                );
              }
              if (state is InventoryLoaded && state.message != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message!),
                    backgroundColor: Colors.green,
                  ),
                );
              }
              if (state is InventoryError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            builder: (context, state) {
              if (state is InventoryLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is InventoryError) {
                return _buildErrorState(context, state.message);
              }

              if (state is InventoryLoaded) {
                final products = _groupByProduct(state.items);
                if (products.isEmpty) {
                  return _buildEmptyState(context);
                }
                return RefreshIndicator(
                  onRefresh: () async {
                    context.read<InventoryBloc>().add(const RefreshInventory());
                  },
                  child: _buildList(products),
                );
              }

              return _buildEmptyState(context);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Stock', style: Theme.of(context).textTheme.headlineSmall),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<InventoryBloc>().add(const RefreshInventory());
            },
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error, size: 64, color: Colors.red.shade300),
          const SizedBox(height: 16),
          Text(
            'Error loading stock',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () =>
                context.read<InventoryBloc>().add(const LoadInventory()),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.warehouse, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No inventory items available',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Start by adding products and items',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildList(List<_ProductGroup> products) {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(8),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return Card(
          elevation: 1,
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 4,
            ),
            title: Text(
              '${product.name} ${product.brand ?? ""}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              'Category: ${product.categoryName ?? "Uncategorized"}',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
            trailing: Icon(Icons.chevron_right, color: Colors.grey.shade600),
            children: product.items.map((item) {
              final stockColor = _getStockColor(item.stock, item.minimumStock);
              return _buildItemRow(item, stockColor);
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildItemRow(InventoryItem item, Color stockColor) {
    return ListTile(
      dense: true,
      title: Text('${item.specification} ${item.color ?? ""}'),
      subtitle: Text('UoM: ${item.unitOfMeasure}'),
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            'Qty: ${item.stock}',
            style: TextStyle(fontWeight: FontWeight.bold, color: stockColor),
          ),
          Text(
            'Min: ${item.minimumStock ?? 0}',
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
          ),
        ],
      ),
      onTap: () {
        // TODO: open detail or stock movement
      },
    );
  }

  Color _getStockColor(int stock, int? minStock) {
    if (minStock != null && stock <= minStock) {
      return Colors.red;
    } else if (minStock != null && stock <= (minStock * 2)) {
      return Colors.orange;
    }
    return Colors.green;
  }

  List<_ProductGroup> _groupByProduct(List<InventoryItem> items) {
    final Map<int, _ProductGroup> grouped = {};
    for (var item in items) {
      grouped.putIfAbsent(
        item.productId,
        () => _ProductGroup(
          id: item.productId,
          name: item.productName,
          brand: item.brand,
          categoryName: item.categoryName,
          items: [],
        ),
      );
      grouped[item.productId]!.items.add(item);
    }
    return grouped.values.toList();
  }
}

class _ProductGroup {
  final int id;
  final String name;
  final String? brand;
  final String? categoryName;
  final List<InventoryItem> items;

  _ProductGroup({
    required this.id,
    required this.name,
    this.brand,
    this.categoryName,
    required this.items,
  });
}
