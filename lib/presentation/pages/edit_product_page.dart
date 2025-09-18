import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../domain/entities/product.dart';
import '../bloc/product/product_state.dart';
import '../bloc/product/product_bloc.dart';
import '../bloc/product/product_event.dart';
import '../bloc/category/category_bloc.dart';
import '../bloc/category/category_state.dart';
import '../bloc/category/category_event.dart';
import '../widgets/common/loading_widget.dart';

class EditProductPage extends StatefulWidget {
  final int productId;

  const EditProductPage({super.key, required this.productId});

  @override
  State<EditProductPage> createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _brandController = TextEditingController();
  final _imageUrlController = TextEditingController();
  
  int? _selectedCategoryId;
  bool _isLoading = false;
  Product? _originalProduct;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    // Load both categories and the specific product
    context.read<CategoryBloc>().add(const LoadCategories());
    _loadProduct();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _brandController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _loadProduct() async {
    try {
      setState(() => _isLoading = true);
      
      // Get the product from ProductService
      final productService = context.read<ProductBloc>().productService;
      final product = await productService.getProductById(widget.productId);
      
      if (product != null) {
        setState(() {
          _originalProduct = product;
          _nameController.text = product.name;
          _descriptionController.text = product.description ?? '';
          _brandController.text = product.brand ?? '';
          _imageUrlController.text = product.imageUrl ?? ''; // You might want to add imageUrl to Product entity
          _selectedCategoryId = product.categoryId;
          _hasChanges = false;
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Product not found'),
              backgroundColor: Colors.red,
            ),
          );
          context.pop();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading product: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _trackChanges() {
    if (_originalProduct == null) return;
    
    final hasChanges = _nameController.text != _originalProduct!.name ||
                      _descriptionController.text != (_originalProduct!.description ?? '') ||
                      _brandController.text != (_originalProduct!.brand ?? '') || _imageUrlController.text != (_originalProduct!.imageUrl ?? '') ||
                      _selectedCategoryId != _originalProduct!.categoryId;
    
    if (hasChanges != _hasChanges) {
      setState(() => _hasChanges = hasChanges);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _originalProduct == null) {
      return const Scaffold(
        body: LoadingWidget(),
      );
    }

   return PopScope(
  canPop: !_hasChanges,
  onPopInvokedWithResult: (didPop, result) async {
    if (!didPop && _hasChanges) {
      // capture context before async
      final navigator = Navigator.of(context);

      final shouldLeave = await _showUnsavedChangesDialog();
      if (shouldLeave && mounted) {
        navigator.pop(result); // use local navigator, not State.context
      }
    }
  },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit Product'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => _handleBackPressed(),
          ),
          actions: [
            TextButton(
              onPressed: _isLoading ? null : (_hasChanges ? _updateProduct : null),
              child: _isLoading 
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      'Save',
                      style: TextStyle(
                        color: _hasChanges ? null : Colors.grey,
                      ),
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
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
              context.pop(); // Go back to products list
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
                  // Changes indicator
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
                          Icon(Icons.edit, color: Colors.orange.shade700, size: 20),
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
                  
                  // Product Image Preview
                  _buildImagePreview(),
                  const SizedBox(height: 24),
                  
                  // Product Name
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Product Name *',
                      hintText: 'e.g., Cat FTALIT',
                      prefixIcon: Icon(Icons.inventory_2),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Product name is required';
                      }
                      return null;
                    },
                    onChanged: (_) => _trackChanges(),
                  ),
                  const SizedBox(height: 16),
                  
                  // Brand
                  TextFormField(
                    controller: _brandController,
                    decoration: const InputDecoration(
                      labelText: 'Brand',
                      hintText: 'e.g., Kansai Paint',
                      prefixIcon: Icon(Icons.branding_watermark),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (_) => _trackChanges(),
                  ),
                  const SizedBox(height: 16),
                  
                  // Description
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      hintText: 'Brief description of the product',
                      prefixIcon: Icon(Icons.description),
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    onChanged: (_) => _trackChanges(),
                  ),
                  const SizedBox(height: 16),
                  
                  // Category
                  BlocBuilder<CategoryBloc, CategoryState>(
                    builder: (context, state) {
                      if (state is CategoryLoading) {
                        return DropdownButtonFormField<int>(
                          decoration: const InputDecoration(
                            labelText: 'Category',
                            prefixIcon: Icon(Icons.category),
                            border: OutlineInputBorder(),
                          ),
                          items: const [],
                          onChanged: null,
                          hint: const Text('Loading categories...'),
                        );
                      } else if (state is CategoriesLoaded) {
                        return DropdownButtonFormField<int>(
                          decoration: const InputDecoration(
                            labelText: 'Category',
                            prefixIcon: Icon(Icons.category),
                            border: OutlineInputBorder(),
                          ),
                          initialValue: _selectedCategoryId,
                          items: [
                            const DropdownMenuItem<int>(
                              value: null,
                              child: Text('Select a category'),
                            ),
                            ...state.categories.map((category) => DropdownMenuItem<int>(
                              value: category.id,
                              child: Text(category.name),
                            )),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedCategoryId = value;
                            });
                            _trackChanges();
                          },
                        );
                      } else if (state is CategoryError) {
                        return Column(
                          children: [
                            DropdownButtonFormField<int>(
                              decoration: const InputDecoration(
                                labelText: 'Category',
                                prefixIcon: Icon(Icons.category),
                                border: OutlineInputBorder(),
                                errorText: 'Failed to load categories',
                              ),
                              items: const [],
                              onChanged: null,
                            ),
                            const SizedBox(height: 8),
                            TextButton.icon(
                              onPressed: () => context.read<CategoryBloc>().add(const LoadCategories()),
                              icon: const Icon(Icons.refresh, size: 16),
                              label: const Text('Retry loading categories'),
                            ),
                          ],
                        );
                      }
                      // Initial state - show loading
                      return DropdownButtonFormField<int>(
                        decoration: const InputDecoration(
                          labelText: 'Category',
                          prefixIcon: Icon(Icons.category),
                          border: OutlineInputBorder(),
                        ),
                        items: const [],
                        onChanged: null,
                        hint: const Text('Loading categories...'),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Image URL
                  TextFormField(
                    controller: _imageUrlController,
                    decoration: const InputDecoration(
                      labelText: 'Image URL',
                      hintText: 'https://example.com/image.jpg',
                      prefixIcon: Icon(Icons.link),
                      border: OutlineInputBorder(),
                      helperText: 'Optional: Link to product image',
                    ),
                    onChanged: (value) {
                      setState(() {}); // Rebuild to update image preview
                      _trackChanges();
                    },
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final uri = Uri.tryParse(value);
                        if (uri == null || !uri.hasAbsolutePath) {
                          return 'Please enter a valid URL';
                        }
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  
                  // Update Button
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : (_hasChanges ? _updateProduct : null),
                    icon: _isLoading 
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save),
                    label: Text(_isLoading ? 'Updating...' : 'Update Product'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      backgroundColor: _hasChanges ? null : Colors.grey.shade300,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Reset Button
                  OutlinedButton.icon(
                    onPressed: _hasChanges ? _resetForm : null,
                    icon: const Icon(Icons.restore),
                    label: const Text('Reset Changes'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                  
                  const SizedBox(height: 32),                
                  
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    final imageUrl = _imageUrlController.text.trim();
    
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: imageUrl.isNotEmpty
          ? ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.broken_image, 
                           size: 48, color: Colors.grey.shade400),
                      const SizedBox(height: 8),
                      Text(
                        'Failed to load image',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(child: CircularProgressIndicator());
                },
              ),
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.image, size: 48, color: Colors.grey.shade400),
                const SizedBox(height: 8),
                Text(
                  'Product Image Preview',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                Text(
                  'Enter an image URL to see preview',
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
    );
  }

  void _updateProduct() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final updatedProduct = Product(
      id: widget.productId,
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim().isEmpty 
          ? null 
          : _descriptionController.text.trim(),
      brand: _brandController.text.trim().isEmpty 
          ? null 
          : _brandController.text.trim(),
      categoryId: _selectedCategoryId,
      imageUrl: _imageUrlController.text.trim().isEmpty? _originalProduct!.imageUrl : _imageUrlController.text.trim(),     
    );

    context.read<ProductBloc>().add(UpdateProduct(updatedProduct));
  }

  void _resetForm() {
    if (_originalProduct != null) {
      setState(() {
        _nameController.text = _originalProduct!.name;
        _descriptionController.text = _originalProduct!.description ?? '';
        _brandController.text = _originalProduct!.brand ?? '';
        _imageUrlController.text = _originalProduct!.imageUrl ?? '';
        _selectedCategoryId = _originalProduct!.categoryId;
        _hasChanges = false;
      });
    }
  }

  void _handleBackPressed() async {
  if (_hasChanges) {
    // capture navigator before async
    final navigator = Navigator.of(context);

    final shouldLeave = await _showUnsavedChangesDialog();
    if (shouldLeave && mounted) {
      navigator.pop();
    }
  } else {
    if (mounted) {
      Navigator.of(context).pop(); // no async gap here, safe to use directly
    }
  }
}

  Future<bool> _showUnsavedChangesDialog() async {
  // keep a local context ref
  final dialogContext = context;

  final result = await showDialog<bool>(
    context: dialogContext,
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
          child: const Text(
            'Leave',
            style: TextStyle(color: Colors.red),
          ),
        ),
      ],
    ),
  );

  return result ?? false;
}

}