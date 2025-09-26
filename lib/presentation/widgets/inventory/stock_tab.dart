import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../domain/entities/inventory.dart';
import '../../bloc/inventory/inventory_bloc.dart';
import '../../bloc/inventory/inventory_state.dart';
import '../../bloc/inventory/inventory_event.dart';
import '../../pages/inventory_item_detail_page.dart';
import '../../router/route_paths.dart';

class StockTab extends StatefulWidget {
  const StockTab({super.key});

  @override
  State<StockTab> createState() => _StockTabState();
}

class _StockTabState extends State<StockTab> {
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  List<InventoryItem> _allItems = [];
  List<InventoryItem> _filteredItems = [];
  @override
  void initState() {
    super.initState();
    context.read<InventoryBloc>().add(const LoadInventory());
  }

  void _applyFilters() {
    _filteredItems = _allItems.where((item) {
      if (searchQuery.isNotEmpty) {
        final q = searchQuery.toLowerCase();
        return item.productName.toLowerCase().contains(q) ||
            (item.brand?.toLowerCase().contains(q) ?? false) ||
            item.specification.toLowerCase().contains(q) ||
            (item.color?.toLowerCase().contains(q) ?? false);
      }
      return true;
    }).toList();
  }

  void _showAdjustStockDialog(InventoryItem item) {
    final qtyController = TextEditingController();
    final noteController = TextEditingController();
    String direction = 'out';
    final blocContext = context;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Adjust Stock'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: qtyController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Quantity'),
            ),
            DropdownButtonFormField<String>(
              initialValue: direction,
              onChanged: (val) => direction = val!,
              items: const [
                DropdownMenuItem(value: 'out', child: Text('Deduct Stock')),
                DropdownMenuItem(value: 'in', child: Text('Add Stock')),
              ],
            ),
            TextField(
              controller: noteController,
              decoration: const InputDecoration(labelText: 'Note (optional)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final qty = double.tryParse(qtyController.text);
              if (qty != null && qty > 0) {
                blocContext.read<InventoryBloc>().add(
                  AdjustStock(
                    item.itemId,
                    qty,
                    direction,
                    note: noteController.text,
                  ),
                );
              }
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(context),
        Expanded(
          child: BlocConsumer<InventoryBloc, InventoryState>(
            listener: (context, state) {
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
                _allItems = state.items;
                _applyFilters(); // Apply local filter
                final products = _groupByProduct(_filteredItems);
                if (products.isEmpty) {
                  return _buildEmptyState(context);
                }
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

  Widget _buildHeader(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 768;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Inventory Stock",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              isMobile
                  ? IconButton(
                      onPressed: () {
                        context.push(RoutePaths.stockMovements);
                      },
                      icon: const Icon(Icons.history),
                    )
                  : TextButton.icon(
                      onPressed: () {
                        context.push(RoutePaths.stockMovements);
                      },
                      icon: const Icon(Icons.history),
                      label: const Text("Movements"),
                    ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search stock...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 0,
                      horizontal: 8,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                      _applyFilters();
                    });
                  },
                ),
              ),
              const SizedBox(width: 8),
              if (!isMobile)
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    context.read<InventoryBloc>().add(const RefreshInventory());
                  },
                ),
            ],
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
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
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
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              ),
            ],
          ),
          const SizedBox(width: 8),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'adjust':
                  _showAdjustStockDialog(item);
                  break;
                case 'movements':
                  //context.push('/inventory/items/${item.itemId}/movements');
                  context.push(
                    RoutePaths.inventoryItemMovements.replaceFirst(
                      ':id',
                      item.itemId.toString(),
                    ),
                  );

                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'adjust',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 16),
                    SizedBox(width: 8),
                    Text('Adjust Stock'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'movements',
                child: Row(
                  children: [
                    Icon(Icons.history, size: 16),
                    SizedBox(width: 8),
                    Text('View Movements'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      onTap: () {
        // Open item detail page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => InventoryItemDetailPage(itemId: item.itemId),
          ),
        );
      },
    );
  }

  Color _getStockColor(double stock, int? minStock) {
    if (minStock != null && stock <= minStock.toDouble()) {
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
