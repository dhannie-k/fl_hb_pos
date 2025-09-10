import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../bloc/product/product_bloc.dart';
import '../../bloc/product/product_event.dart';
import '../../bloc/product/product_state.dart';
import '../common/loading_widget.dart';
import '../../../domain/repositories/product_service.dart';

class ProductTab extends StatefulWidget {
  const ProductTab({super.key});

  @override
  State<ProductTab> createState() => _ProductTabState();
}

class _ProductTabState extends State<ProductTab> {
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  List<ProductDisplayItem> _allProducts = [];
  List<ProductDisplayItem> _filteredProducts = [];

  @override
  void initState() {
    super.initState();
    // Only load products in ProductTab - don't load categories here
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
        _buildSearchSection(), // Separate search section
        Expanded(
          child: BlocConsumer<ProductBloc, ProductState>(
            listener: (context, state) {
              if (state is ProductOperationSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.green,
                  ),
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
      // Only apply search filter - no category filter in ProductTab
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
            onPressed: () => context.push('/inventory/products/add'),
            icon: const Icon(Icons.add),
            label: const Text('Add Product'),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: _searchController,
        decoration: const InputDecoration(
          labelText: 'Search products...',
          hintText: 'Enter product name or description',
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
                  : 'Try adjusting your search terms',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            if (searchQuery.isEmpty) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => context.push('/inventory/products/add'),
                icon: const Icon(Icons.add),
                label: const Text('Add Product'),
              ),
            ],
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate cross axis count based on screen width
        int crossAxisCount;
        double childAspectRatio;
        
        if (constraints.maxWidth > 1200) {
          crossAxisCount = 4;
          childAspectRatio = 0.8;
        } else if (constraints.maxWidth > 800) {
          crossAxisCount = 3;
          childAspectRatio = 0.75;
        } else if (constraints.maxWidth > 600) {
          crossAxisCount = 2;
          childAspectRatio = 0.75;
        } else {
          crossAxisCount = 2;
          childAspectRatio = 0.7;
        }

        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16), // Remove top padding
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: childAspectRatio,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return _buildProductCard(product);
          },
        );
      },
    );
  }

  Widget _buildProductCard(ProductDisplayItem product) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () => context.push('/inventory/products/view/${product.productId}'), 
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product image placeholder
              Container(
                height: 60, // Reduced height to prevent overflow
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.inventory_2,
                  size: 28, 
                  color: Colors.grey.shade400,
                ),
              ),
              const SizedBox(height: 8),
              
              // Product name (main title)
              Text(
                product.displayName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              // Product description (subtitle)
              if (product.description != null && product.description!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  product.description!,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              
              const Spacer(),
              
              // Show item count or "No items" status
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: product.productItemId == 0 
                      ? Colors.orange.shade100 
                      : Colors.green.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  product.productItemId == 0 
                      ? 'No items'
                      : 'Has items',
                  style: TextStyle(
                    color: product.productItemId == 0 
                        ? Colors.orange.shade700 
                        : Colors.green.shade700,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              
              const SizedBox(height: 6),
              
              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, size: 18),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'view',
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.visibility, size: 16),
                            SizedBox(width: 8),
                            Text('View', style: TextStyle(fontSize: 12)),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.edit, size: 16),
                            SizedBox(width: 8),
                            Text('Edit', style: TextStyle(fontSize: 12)),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'add_item',
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.add_box, size: 16),
                            SizedBox(width: 8),
                            Text('Add Item', style: TextStyle(fontSize: 12)),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.delete, size: 16, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete', 
                                 style: TextStyle(color: Colors.red, fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) {
                      switch (value) {
                        case 'view':
                          context.push('/inventory/products/view/${product.productId}');
                          break;
                        case 'edit':
                          context.push('/inventory/products/edit/${product.productId}');
                          break;
                        case 'add_item':
                          context.push('/inventory/products/${product.productId}/add-item');
                          break;
                        case 'delete':
                          _showDeleteProductDialog(product);
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

  void _showDeleteProductDialog(ProductDisplayItem product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Are you sure you want to delete this product?'),
            const SizedBox(height: 8),
            Text(
              product.displayName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            if (product.description != null && product.description!.isNotEmpty)
              Text(product.description!),
            const SizedBox(height: 8),
            const Text(
              'Warning: This will delete the product and all its items permanently.',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<ProductBloc>().add(DeleteProduct(product.productId));
              Navigator.pop(context);
            },
            child: const Text(
              'Delete Product', 
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}