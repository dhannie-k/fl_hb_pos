import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hb_pos_inv/domain/entities/inventory.dart';
import 'package:hb_pos_inv/presentation/bloc/inventory/inventory_bloc.dart';
import 'package:hb_pos_inv/presentation/bloc/inventory/inventory_event.dart';
import 'package:hb_pos_inv/presentation/bloc/inventory/inventory_state.dart';
import '../../domain/entities/purchase.dart';
import '../bloc/purchase/purchase_bloc.dart';
import '../bloc/purchase/purchase_event.dart';
import '../bloc/purchase/purchase_state.dart';
import 'dart:async';


// Helper class to delay search requests while user is typing
class _Debouncer {
  final int milliseconds;
  Timer? _timer;

  _Debouncer({required this.milliseconds});

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }

  void dispose() {
    _timer?.cancel();
  }
}


class AddPurchasePage extends StatefulWidget {
  const AddPurchasePage({super.key});

  @override
  State<AddPurchasePage> createState() => _AddPurchasePageState();
}

class _AddPurchasePageState extends State<AddPurchasePage> {
  final _formKey = GlobalKey<FormState>();
  final _poNumberController = TextEditingController();
  final _supplierIdController = TextEditingController();
  DateTime _purchaseDate = DateTime.now();
  PaymentMethod _paymentMethod = PaymentMethod.cash;
  final List<PurchaseItem> _items = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _poNumberController.dispose();
    _supplierIdController.dispose();
    super.dispose();
  }

  void _submitPurchase() {
    if (!_formKey.currentState!.validate()) return;
    
    if (_items.isEmpty) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one item to the purchase.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final totalAmount = _items.fold<double>(
        0.0, (sum, item) => sum + (item.quantityOrdered * item.unitCost));

    final newPurchase = Purchase(
      poNumber: _poNumberController.text.trim().isEmpty
          ? null
          : _poNumberController.text.trim(),
      supplierId: int.tryParse(_supplierIdController.text.trim()),
      purchaseDate: _purchaseDate,
      totalAmount: totalAmount,
      paymentMethod: _paymentMethod,
      items: _items,
    );

    context.read<PurchaseBloc>().add(AddPurchase(newPurchase));
  }

  void _showAddItemDialog() async {
    final selectedItem = await showDialog<InventoryItem>(
      context: context,
      // Use the existing InventoryBloc instance
      builder: (_) => BlocProvider.value(
        value: context.read<InventoryBloc>(),
        child: const _ProductSearchDialog(),
      ),
    );

    if (selectedItem != null) {
      _showQuantityCostDialog(selectedItem);
    }
  }

  void _showQuantityCostDialog(InventoryItem item) {
    final quantityController = TextEditingController();
    final unitCostController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add ${item.productName}'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.specification),
              const SizedBox(height: 16),
              TextFormField(
                controller: quantityController,
                autofocus: true,
                decoration: const InputDecoration(labelText: 'Quantity*'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (val) => (val == null ||
                        val.isEmpty ||
                        double.tryParse(val) == null ||
                        double.parse(val) <= 0)
                    ? 'Enter a valid quantity'
                    : null,
              ),
              TextFormField(
                controller: unitCostController,
                decoration: const InputDecoration(labelText: 'Unit Cost*'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (val) => (val == null ||
                        val.isEmpty ||
                        double.tryParse(val) == null ||
                        double.parse(val) < 0)
                    ? 'Enter a valid cost'
                    : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final newItem = PurchaseItem(
                  productItemId: item.itemId,
                  productName: '${item.productName} (${item.specification})',
                  quantityOrdered: double.parse(quantityController.text),
                  unitCost: double.parse(unitCostController.text),
                );
                setState(() => _items.add(newItem));
                Navigator.of(context).pop();
              }
            },
            child: const Text('Add Item'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Purchase')),
      body: BlocListener<PurchaseBloc, PurchaseState>(
        listener: (context, state) {
          setState(() => _isLoading = state is PurchaseLoading);

          if (state is PurchaseOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            context.pop();
          } else if (state is PurchaseError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _poNumberController,
                  decoration: const InputDecoration(
                    labelText: 'PO Number',
                    hintText: 'Optional Purchase Order number',
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _supplierIdController,
                  decoration: const InputDecoration(
                    labelText: 'Supplier ID*',
                    hintText: 'Enter the supplier\'s ID',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (val) => (val == null || val.isEmpty || int.tryParse(val) == null)
                      ? 'Supplier ID is required'
                      : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<PaymentMethod>(
                  initialValue: _paymentMethod,
                  decoration: const InputDecoration(
                    labelText: 'Payment Method',
                    border: OutlineInputBorder(),
                  ),
                  items: PaymentMethod.values
                      .map((method) => DropdownMenuItem(
                            value: method,
                            child: Text(method.name),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _paymentMethod = value);
                    }
                  },
                ),
                const Divider(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Items', style: Theme.of(context).textTheme.titleLarge),
                    IconButton.filled(
                      onPressed: _showAddItemDialog,
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _items.isEmpty
                    ? const Center(child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('No items added yet.'),
                    ))
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _items.length,
                        itemBuilder: (context, index) {
                          final item = _items[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            child: ListTile(
                              title: Text(item.productName ?? 'Item ID: ${item.productItemId}'),
                              subtitle: Text(
                                  '${item.quantityOrdered} x @ ${item.unitCost.toStringAsFixed(2)} = ${(item.quantityOrdered * item.unitCost).toStringAsFixed(2)}'),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.redAccent),
                                onPressed: () {
                                  setState(() => _items.removeAt(index));
                                },
                              ),
                            ),
                          );
                        },
                      ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _submitPurchase,
                    icon: const Icon(Icons.save),
                    label: Text(_isLoading ? 'Saving...' : 'Save Purchase'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// A dedicated stateful widget for the live search dialog
class _ProductSearchDialog extends StatefulWidget {
  const _ProductSearchDialog();

  @override
  State<_ProductSearchDialog> createState() => __ProductSearchDialogState();
}

class __ProductSearchDialogState extends State<_ProductSearchDialog> {
  // Delays the search API call until the user stops typing
  final _debouncer = _Debouncer(milliseconds: 500);
  String _currentQuery = '';

  @override
  void dispose() {
    _debouncer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Search Product Item'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Search by name, brand, spec...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (query) {
                // Only trigger search if the query text has actually changed
                if(query.trim() != _currentQuery) {
                   _currentQuery = query.trim();
                   // Use the debouncer to avoid sending too many requests
                   _debouncer.run(() {
                    if (_currentQuery.isNotEmpty) {
                      context.read<InventoryBloc>().add(SearchProductItems(_currentQuery));
                    }
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: BlocBuilder<InventoryBloc, InventoryState>(
                builder: (context, state) {
                  if (state is InventoryLoaded) {
                    final searchResults = state.searchResults;
                    if (_currentQuery.isEmpty) {
                      return const Center(child: Text('Please enter a search term.'));
                    }
                    // When searchResults is null, it means a search is in progress
                    if (searchResults == null) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (searchResults.isEmpty) {
                      return const Center(child: Text('No matching items found.'));
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: searchResults.length,
                      itemBuilder: (context, index) {
                        final item = searchResults[index];
                        return ListTile(
                          title: Text(item.productName),
                          subtitle: Text(item.specification),
                          // Return the selected item when tapped
                          onTap: () => Navigator.of(context).pop(item),
                        );
                      },
                    );
                  }
                  // Initial state before any search
                  return const Center(child: Text('Start typing to search for items.'));
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        // This button now correctly uses the Navigator to pop the dialog
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close'))
      ],
    );
  }
}
