import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hb_pos_inv/domain/entities/supplier.dart';
import 'package:hb_pos_inv/presentation/bloc/supplier/supplier_bloc.dart';
import 'package:intl/intl.dart'; // Import for date formatting
import 'package:hb_pos_inv/domain/entities/inventory.dart';
import 'package:hb_pos_inv/presentation/bloc/inventory/inventory_bloc.dart';
import 'package:hb_pos_inv/presentation/bloc/inventory/inventory_event.dart';
import 'package:hb_pos_inv/presentation/bloc/inventory/inventory_state.dart';
import '../../domain/entities/purchase.dart';
import '../bloc/purchase/purchase_bloc.dart';
import '../bloc/purchase/purchase_event.dart';
import '../bloc/purchase/purchase_state.dart';

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
  final _supplierNameController = TextEditingController();
  Supplier? _selectedSupplier;
  //final _supplierIdController = TextEditingController();
  DateTime _purchaseDate = DateTime.now(); // State for the selected date
  PaymentMethod _paymentMethod = PaymentMethod.cash;
  final List<PurchaseItem> _items = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _poNumberController.dispose();
    //_supplierIdController.dispose();
    _supplierNameController.dispose();
    super.dispose();
  }

  // Function to show the date picker dialog
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _purchaseDate,
      firstDate: DateTime(2020), // Set a reasonable earliest date
      lastDate: DateTime.now(),   // Prevent selecting future dates
    );
    if (picked != null && picked != _purchaseDate) {
      setState(() {
        _purchaseDate = picked;
      });
    }
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
      supplierId: _selectedSupplier!.id, //int.tryParse(_supplierIdController.text.trim()),
      purchaseDate: _purchaseDate, // Use the selected date
      totalAmount: totalAmount,
      paymentMethod: _paymentMethod,
      items: _items,
    );

    context.read<PurchaseBloc>().add(AddPurchase(newPurchase));
  }

  void _showSupplierSearchDialog() async {
    // Show the search dialog and wait for it to return a Supplier
    final supplier = await showDialog<Supplier>(
      context: context,
      builder: (_) => BlocProvider.value(
        // Provide the existing SupplierBloc to the dialog
        value: context.read<SupplierBloc>()..add(LoadSuppliers()),
        child: const _SupplierSearchDialog(),
      ),
    );

    // If a supplier was selected or created, update the state
    if (supplier != null) {
      setState(() {
        _selectedSupplier = supplier;
        _supplierNameController.text = supplier.name;
      });
    }
  }

  void _showAddItemDialog() async {
    final selectedItem = await showDialog<InventoryItem>(
      context: context,
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
                  product: item.productName,
                  //brand: item.brand,
                  specification: item.specification,
                  //productName: '${item.productName} (${item.specification})',
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
            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            // Navigate back to the previous page
            if (context.mounted) {
              context.pop();
            }
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
                // === DATE PICKER WIDGET ===
                TextFormField(
                  readOnly: true,
                  controller: TextEditingController(
                    text: DateFormat.yMMMd().format(_purchaseDate),
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Purchase Date*',
                    suffixIcon: Icon(Icons.calendar_today),
                     border: OutlineInputBorder(),
                  ),
                  onTap: () => _selectDate(context),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _poNumberController,
                  decoration: const InputDecoration(
                    labelText: 'PO Number',
                    hintText: 'Optional Purchase Order number',
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _supplierNameController,
                  decoration: const InputDecoration(
                    labelText: 'Supplier*',
                    hintText: 'Tap to Search for a supplier',
                    suffixIcon: Icon(Icons.search),
                  ),
                  onTap: _showSupplierSearchDialog,
                  //keyboardType: TextInputType.number,
                  validator: (val) {
                    if(_selectedSupplier == null){
                      return 'Please selec a supplier';
                    }
                    return null;
                  }
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
                              title: Text(item.product),
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
                if(query.trim() != _currentQuery) {
                   _currentQuery = query.trim();
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
                          title: Text('${item.productName} ${item.brand ?? ''}'),
                          subtitle: Text('${item.specification} ${item.color ??''}'),
                          onTap: () => Navigator.of(context).pop(item),
                        );
                      },
                    );
                  }
                  return const Center(child: Text('Start typing to search for items.'));
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close'))
      ],
    );
  }
}

// ===== DIALOG FOR SUPPLIER SEARCH AND CREATION =====
class _SupplierSearchDialog extends StatefulWidget {
  const _SupplierSearchDialog();

  @override
  State<_SupplierSearchDialog> createState() => __SupplierSearchDialogState();
}

class __SupplierSearchDialogState extends State<_SupplierSearchDialog> {
  final _debouncer = _Debouncer(milliseconds: 500);
  String _currentQuery = '';

  void _addNewSupplier(String name) async {
    final newSupplier = await showDialog<Supplier>(
      context: context,
      builder: (dialogContext) => _AddSupplierDialog(
        initialName: name,
        // Pass the BLoC instance to the new dialog
        bloc: context.read<SupplierBloc>(),
      ),
    );

    // If the add dialog returns a new supplier, pop the search dialog with that supplier
    if (newSupplier != null && mounted) {
      Navigator.of(context).pop(newSupplier);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Search Supplier'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              autofocus: true,
              decoration: const InputDecoration(hintText: 'Type supplier name...'),
              onChanged: (query) {
                _currentQuery = query.trim();
                _debouncer.run(() {
                  if (_currentQuery.isNotEmpty) {
                    context.read<SupplierBloc>().add(SearchSuppliers(_currentQuery));
                  }
                });
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: BlocBuilder<SupplierBloc, SupplierState>(
                builder: (context, state) {
                  if (state is SuppliersLoaded && state.searchResults != null) {
                    final results = state.searchResults!;
                    if (results.isEmpty && _currentQuery.isNotEmpty) {
                      return Center(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.add),
                          label: Text("Create '$_currentQuery'"),
                          onPressed: () => _addNewSupplier(_currentQuery),
                        ),
                      );
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: results.length,
                      itemBuilder: (context, index) {
                        final supplier = results[index];
                        return ListTile(
                          title: Text(supplier.name),
                          onTap: () => Navigator.of(context).pop(supplier),
                        );
                      },
                    );
                  }
                  return const Center(child: Text('Start typing to search.'));
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close'))
      ],
    );
  }
}

// ===== DIALOG FOR QUICKLY ADDING A NEW SUPPLIER =====
class _AddSupplierDialog extends StatelessWidget {
  final String initialName;
  final SupplierBloc bloc;
  const _AddSupplierDialog({required this.initialName, required this.bloc});

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController(text: initialName);
    
    return BlocListener<SupplierBloc, SupplierState>(
      bloc: bloc,
      listener: (context, state) {
        // Listen for the specific success state that carries the new supplier
        if (state is SupplierOperationSuccess && state.newSupplier != null) {
          // When the BLoC confirms success, pop this dialog and return the new data
          Navigator.of(context).pop(state.newSupplier);
        }
      },
      child: AlertDialog(
        title: const Text('Add New Supplier'),
        content: TextFormField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'Supplier Name*'),
          // You could add more fields here (address, phone) if desired
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                // Dispatch the event to add the supplier
                bloc.add(AddSupplier(name: nameController.text.trim()));
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

