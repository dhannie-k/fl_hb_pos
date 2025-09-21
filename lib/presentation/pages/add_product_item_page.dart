import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/product/product_bloc.dart';
import '../bloc/product/product_state.dart';
import '../bloc/product/product_event.dart';
import '../../domain/entities/product.dart';

class AddProductItemPage extends StatefulWidget {
  final int productId;
  final String productName;

  const AddProductItemPage({
    super.key,
    required this.productId,
    required this.productName,
  });

  @override
  State<AddProductItemPage> createState() => _AddProductItemPageState();
}

class _AddProductItemPageState extends State<AddProductItemPage> {
  final _formKey = GlobalKey<FormState>();
  final _specificationController = TextEditingController();
  final _skuController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _unitOfMeasureController = TextEditingController();
  final _minimumStockController = TextEditingController();
  final _colorController = TextEditingController();
  final _unitPriceController = TextEditingController();
  final _initialQuantity = TextEditingController();
  final _specfocusNode = FocusNode();

  bool _isLoading = false;

  @override
  void dispose() {
    _specificationController.dispose();
    _skuController.dispose();
    _barcodeController.dispose();
    _unitOfMeasureController.dispose();
    _colorController.dispose();
    _unitPriceController.dispose();
    _initialQuantity.dispose();
    _specfocusNode.dispose();
    super.dispose();
  }

  void _addProductItem({required bool stayOnPage}) {
    if (!_formKey.currentState!.validate()) return;

    final item = ProductItem.createNew(
      productId: widget.productId,
      specification: _specificationController.text.trim(),
      unitOfMeasure: _unitOfMeasureController.text.trim(),
      unitPrice: double.tryParse(_unitPriceController.text.trim()) ?? 0.0,
      sku: _skuController.text.trim().isEmpty
          ? null
          : _skuController.text.trim(),
      barcode: _barcodeController.text.trim().isEmpty
          ? null
          : _barcodeController.text.trim(),
      color: _colorController.text.trim().isEmpty
          ? null
          : _colorController.text.trim(),
      minimumStock: int.tryParse(_minimumStockController.text.trim()) ?? 0,
    );

    final qty = int.tryParse(_initialQuantity.text.trim()) ?? 0;

    context.read<ProductBloc>().add(AddProductItem(item, initialQuantity: qty, stayOnPage: stayOnPage));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Product Item for ${widget.productName}')),
      body: BlocListener<ProductBloc, ProductState>(
        listener: (context, state) {
          if (state is ProductLoading) {
            setState(() => _isLoading = true);
          } else {
            setState(() => _isLoading = false);
          }
          if (state is ProductOperationError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
          if (state is ProductOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.blue,
              ),
            );
            if (state.stayOnPage) {
              // Clear form for another entry
              _specificationController.clear();
              _skuController.clear();
              _barcodeController.clear();
              _unitOfMeasureController.clear();
              _colorController.clear();
              _unitPriceController.clear();
              _minimumStockController.clear();
              _initialQuantity.clear();
              FocusScope.of(context).requestFocus(_specfocusNode);
            } else {
              context.pop(); // back to product edit
            }
          } else if (state is ProductError) {
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
              children: [
                TextFormField(
                  controller: _specificationController,
                  focusNode: _specfocusNode,
                  decoration: const InputDecoration(
                    labelText: 'Specification *',
                    hintText: 'e.g., 12mm, Red, Large',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'Specification is required'
                      : null,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _skuController,
                  decoration: const InputDecoration(
                    labelText: 'SKU',
                    hintText: 'Optional: Stock Keeping Unit',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _barcodeController,
                  decoration: const InputDecoration(
                    labelText: 'Barcode',
                    hintText: 'Optional: Barcode number',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _unitOfMeasureController,
                  decoration: const InputDecoration(
                    labelText: 'Unit of Measure *',
                    hintText: 'e.g., pc, box, pack',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'Unit of measure is required'
                      : null,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _colorController,
                  decoration: const InputDecoration(
                    labelText: 'Color',
                    hintText: 'Optional: e.g., Red, Blue',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _unitPriceController,
                  decoration: const InputDecoration(
                    labelText: 'Unit Price *',
                    hintText: 'e.g., 15000',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Unit price is required';
                    }
                    final parsed = double.tryParse(value);
                    if (parsed == null || parsed < 0) {
                      return 'Enter a valid positive number';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _minimumStockController,
                  decoration: const InputDecoration(
                    labelText: 'Minimum Stock',
                    hintText: 'Optional, default 0',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    // store in state
                  },
                ),
                Text("Add initial quantity:"),
                TextFormField(
                  controller: _initialQuantity,
                  decoration: const InputDecoration(
                    labelText: 'initial quantity',
                    hintText: 'initial stock quantity',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    // store in state
                  },
                ),
                const SizedBox(height: 32),

                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isLoading
                            ? null
                            : () {
                                _addProductItem(stayOnPage: true);
                              },
                        icon: const Icon(Icons.add_circle_outline),
                        label: Text(
                          _isLoading ? 'Saving...' : 'Save & Add Another',
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isLoading
                            ? null
                            : () {
                                _addProductItem(stayOnPage: false);
                              },
                        icon: const Icon(Icons.check),
                        label: Text(_isLoading ? 'Saving...' : 'Save & Exit'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
