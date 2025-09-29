import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/product.dart';
import '../bloc/product/product_bloc.dart';
import '../bloc/product/product_event.dart';
import '../bloc/product/product_state.dart';

class EditProductItemPage extends StatefulWidget {
  final ProductItem item;

  const EditProductItemPage({super.key, required this.item});

  @override
  State<EditProductItemPage> createState() => _EditProductItemPageState();
}

class _EditProductItemPageState extends State<EditProductItemPage> {
  final _formKey = GlobalKey<FormState>();

  final _specCtrl = TextEditingController();
  final _uomCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _minStockCtrl = TextEditingController();
  final _colorCtrl = TextEditingController();

  ProductItem? _originalItem;
  bool _hasChanges = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _originalItem = widget.item;
    _specCtrl.text = _originalItem!.specification;
    _uomCtrl.text = _originalItem!.unitOfMeasure;
    _priceCtrl.text = _originalItem!.unitPrice?.toString() ?? '';
    _minStockCtrl.text = _originalItem!.minimumStock?.toString() ?? '';
    _colorCtrl.text = _originalItem!.color ?? '';

    for (final ctrl in [
      _specCtrl,
      _uomCtrl,
      _priceCtrl,
      _minStockCtrl,
      _colorCtrl,
    ]) {
      ctrl.addListener(_trackChanges);
    }
  }

  @override
  void dispose() {
    _specCtrl.dispose();
    _uomCtrl.dispose();
    _priceCtrl.dispose();
    _minStockCtrl.dispose();
    _colorCtrl.dispose();
    super.dispose();
  }

  void _trackChanges() {
    if (_originalItem == null) return;

    final updated = _buildUpdatedItem();
    final hasChanges = updated != _originalItem;
    if (hasChanges != _hasChanges) {
      setState(() => _hasChanges = hasChanges);
    }
  }

  ProductItem _buildUpdatedItem() {
    return _originalItem!.copyWith(
      specification: _specCtrl.text.trim(),
      unitOfMeasure: _uomCtrl.text.trim(),
      unitPrice: double.tryParse(_priceCtrl.text),
      minimumStock: int.tryParse(_minStockCtrl.text),
      color: _colorCtrl.text.trim().isNotEmpty ? _colorCtrl.text.trim() : null,
    );
  }

  void _updateItem() {
    if (!_formKey.currentState!.validate()) return;
    final updated = _buildUpdatedItem();
    context.read<ProductBloc>().add(UpdateProductItem(updated));
  }

  void _resetForm() {
    if (_originalItem == null) return;

    setState(() {
      _specCtrl.text = _originalItem!.specification;
      _uomCtrl.text = _originalItem!.unitOfMeasure;
      _priceCtrl.text = _originalItem!.unitPrice?.toString() ?? '';
      _minStockCtrl.text = _originalItem!.minimumStock?.toString() ?? '';
      _colorCtrl.text = _originalItem!.color ?? '';
      _hasChanges = false;
    });
  }

  Future<bool> _showUnsavedChangesDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Unsaved Changes'),
        content: const Text(
          'You have unsaved changes. Are you sure you want to leave without saving?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Stay'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Leave', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_hasChanges,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop && _hasChanges) {
          final navigator = Navigator.of(context);
          final shouldLeave = await _showUnsavedChangesDialog();
          if (shouldLeave && mounted) navigator.pop(result);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Edit Item"),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () async {
              if (_hasChanges) {
                final shouldLeave = await _showUnsavedChangesDialog();

                if (shouldLeave && context.mounted) context.pop();
              } else {
                context.pop();
              }
            },
          ),
          actions: [
            TextButton(
              onPressed: _isLoading ? null : (_hasChanges ? _updateItem : null),
              child: _isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      'Save',
                      style: TextStyle(color: _hasChanges ? null : Colors.grey),
                    ),
            ),
          ],
        ),
        body: BlocListener<ProductBloc, ProductState>(
          listener: (context, state) {
            if (state is ProductLoading) {
              setState(() => _isLoading = true);
            } else {
              setState(() => _isLoading = false);
            }

            if (state is ProductOperationSuccess) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
              context.pop();
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
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_hasChanges) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.edit,
                            color: Colors.orange.shade700,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'You have unsaved changes',
                            style: TextStyle(
                              color: Colors.orange.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  TextFormField(
                    controller: _specCtrl,
                    decoration: const InputDecoration(
                      labelText: "Specification *",
                      prefixIcon: Icon(Icons.settings),
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? "Specification is required"
                        : null,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _uomCtrl,
                    decoration: const InputDecoration(
                      labelText: "Unit of Measure *",
                      prefixIcon: Icon(Icons.straighten),
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? "Unit of Measure is required"
                        : null,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _priceCtrl,
                    decoration: const InputDecoration(
                      labelText: "Unit Price *",
                      prefixIcon: Icon(Icons.attach_money),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      final value = double.tryParse(v ?? '');
                      if (value == null || value < 0) {
                        return "Enter a valid price";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _minStockCtrl,
                    decoration: const InputDecoration(
                      labelText: "Minimum Stock",
                      prefixIcon: Icon(Icons.storage),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _colorCtrl,
                    decoration: const InputDecoration(
                      labelText: "Color",
                      prefixIcon: Icon(Icons.color_lens),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 32),

                  ElevatedButton.icon(
                    onPressed: _isLoading
                        ? null
                        : (_hasChanges ? _updateItem : null),
                    icon: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save),
                    label: Text(_isLoading ? 'Updating...' : 'Update Item'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      backgroundColor: _hasChanges
                          ? null
                          : Colors.grey.shade300,
                    ),
                  ),
                  const SizedBox(height: 16),

                  OutlinedButton.icon(
                    onPressed: _hasChanges ? _resetForm : null,
                    icon: const Icon(Icons.restore),
                    label: const Text('Reset Changes'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
