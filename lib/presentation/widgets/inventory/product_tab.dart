import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../bloc/product/product_bloc.dart';
import '../../bloc/product/product_event.dart';
import '../../bloc/product/product_state.dart';
import '../../bloc/category/category_bloc.dart';
import '../../bloc/category/category_state.dart';
import '../common/loading_widget.dart';
import '../../../domain/repositories/product_service.dart';

class ProductTab extends StatefulWidget {
  const ProductTab({super.key});

  @override
  State<ProductTab> createState() => _ProductTabState();
}

class _ProductTabState extends State<ProductTab> {
  int? selectedCategoryId;
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  List<ProductDisplayItem> _allProducts = [];
  List<ProductDisplayItem> _filteredProducts = [];

  @override
  void initState() {
    super.initState();
    context.read<ProductBloc>().add(const LoadProducts());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        _buildFilters(),
        Expanded(
          child: BlocConsumer<ProductBloc, ProductState>(
            listener: (context, state) {
              if (state is ProductOperationSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
              }
            },
            builder: (context, state) {
              if (state is ProductLoading) {
                return const LoadingWidget();
              }
              
              if (state is ProductError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error, size: 64, color: Colors.red.shade300),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading products',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        state.message,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => context.read<ProductBloc>().add(const LoadProducts()),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }
              
              if (state is ProductLoaded) {
                _allProducts = state.products;
                _applyFilters();
                return _buildProductGrid(_filteredProducts);
              }
              
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inventory_2, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('No products available'),
                    Text('Start by adding some products to your inventory'),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _applyFilters() {
    _filteredProducts = _allProducts.where((product) {
      // Apply category filter
      if (selectedCategoryId != null) {
        // Note: We would need to add categoryId to ProductDisplayItem or fetch it separately
        // For now, we'll skip category filtering in the display item
      }
      
      // Apply search filter
      if (searchQuery.isNotEmpty) {
        return product.searchableText.contains(searchQuery.toLowerCase());
      }
      
      return true;
    }).toList();
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Products',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          ElevatedButton.icon(
            onPressed: () => context.go('/inventory/products/add'),
            icon: const Icon(Icons.add),
            label: const Text('Add Product'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Category Filter
          Expanded(
            flex: 1,
            child: BlocBuilder<CategoryBloc, CategoryState>(
              builder: (context, state) {
                if (state is CategoriesLoaded) {
                  return DropdownButtonFormField<int>(
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      prefixIcon: Icon(Icons.category),
                      border: OutlineInputBorder(),
                    ),
                    initialValue: selectedCategoryId,
                    items: [
                      const DropdownMenuItem<int>(
                        value: null,
                        child: Text('All Categories'),
                      ),
                      ...state.categories.map((category) => DropdownMenuItem<int>(
                        value: category.id,
                        child: Text(category.name),
                      )),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedCategoryId = value;
                      });
                      _applyFilters();
                    },
                  );
                }
                return const SizedBox();
              },
            ),
          ),
          const SizedBox(width: 16),
          // Search Field
          Expanded(
            flex: 2,
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search products...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
                if (value.isEmpty) {
                  _applyFilters();
                } else {
                  // Use the BLoC search for better performance on large datasets
                  context.read<ProductBloc>().add(SearchProducts(value));
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductGrid(List<ProductDisplayItem> products) {
    if (products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              searchQuery.isEmpty ? 'No products found' : 'No products match your search',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              searchQuery.isEmpty 
                  ? 'Add some products to get started'
                  : 'Try adjusting your search terms or filters',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            if (searchQuery.isEmpty) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => context.go('/inventory/products/add'),
                icon: const Icon(Icons.add),
                label: const Text('Add Product'),
              ),
            ],
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return _buildProductCard(product);
      },
    );
  }

  Widget _buildProductCard(ProductDisplayItem product) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () => context.go('/inventory/products/view/${product.productItemId}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product image placeholder
              Container(
                height: 100,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.inventory_2,
                  size: 40, 
                  color: Colors.grey.shade400,
                ),
              ),
              const SizedBox(height: 8),
              
              // Product name
              Text(
                product.displayName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              // SKU
              if (product.sku != null) ...[
                const SizedBox(height: 4),
                Text(
                  'SKU: ${product.sku}',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
              
              // Specification
              if (product.specification.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  product.specification,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              
              const Spacer(),
              
              // Price and actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '\$${product.unitPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'per ${product.unitOfMeasure}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'view',
                        child: Row(
                          children: [
                            Icon(Icons.visibility, size: 16),
                            SizedBox(width: 8),
                            Text('View'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 16),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 16, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) {
                      switch (value) {
                        case 'view':
                          context.go('/inventory/products/view/${product.productItemId}');
                          break;
                        case 'edit':
                          context.go('/inventory/products/edit/${product.productItemId}');
                          break;
                        case 'delete':
                          _showDeleteDialog(product);
                          break;
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(ProductDisplayItem product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product Item'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to delete this product item?'),
            const SizedBox(height: 8),
            Text(
              product.displayName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            if (product.sku != null) Text('SKU: ${product.sku}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<ProductBloc>().add(DeleteProductItem(product.productItemId));
              Navigator.pop(context);
            },
            child: const Text(
              'Delete', 
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}