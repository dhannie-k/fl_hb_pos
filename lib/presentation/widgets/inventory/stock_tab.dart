import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/inventory.dart';
import '../../bloc/inventory/inventory_bloc.dart';
import '../../bloc/inventory/inventory_state.dart';

class StockTab extends StatelessWidget {
  const StockTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InventoryBloc, InventoryState>(
      builder: (context, state) {
        if (state is InventoryLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is InventoryLoaded) {
          final products = _groupByProduct(state.items);
          if (products.isEmpty) {
            return const Center(child: Text('No inventory items available'));
          }
          return _buildList(products);
        } else if (state is InventoryError) {
          return Center(child: Text('Error: ${state.message}'));
        }
        return const Center(child: Text('No inventory data'));
      },
    );
  }

  Widget _buildList(List<_ProductGroup> products) {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return Card(
          elevation: 1,
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ExpansionTile(
            tilePadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            title: Text(
              '${product.name}, ${product.brand ?? "-"}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              'Category: ${product.categoryName ?? "Uncategorized"}',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
            trailing: Icon(Icons.chevron_right, color: Colors.grey.shade600),
            children: product.items.map((item) {
              final stockColor = _getStockColor(item.stock, item.minimumStock);

              return ListTile(
                dense: true,
                title: Text(item.specification),
                subtitle: Text(
                    'SKU: ${item.sku ?? "-"} | UoM: ${item.unitOfMeasure}'),
                trailing: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Qty: ${item.stock}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: stockColor,
                      ),
                    ),
                    Text(
                      'Min: ${item.minimumStock ?? 0}',
                      style: TextStyle(
                          fontSize: 11, color: Colors.grey.shade600),
                    ),
                  ],
                ),
                onTap: () {
                  // TODO: maybe open item detail or movement history
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  /// Color code based on stock levels
  Color _getStockColor(int stock, int? minStock) {
    if (minStock != null && stock <= minStock) {
      return Colors.red; // critical low
    } else if (minStock != null && stock <= (minStock * 2)) {
      return Colors.orange; // warning
    }
    return Colors.green; // safe
  }

  /// Group inventory items by product
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

/// Helper class for grouping
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
