import '../entities/product.dart';
import '../repositories/product_repository.dart';
import 'dart:developer' as developer;

class ProductDisplayItem {
  final int productId;
  final int productItemId;
  final String displayName;
  final String? description;
  final String specification;
  final double unitPrice;
  final String unitOfMeasure;
  final String? sku;
  final String? barcode;
  final String? color;
  final int? minimumStock;

  const ProductDisplayItem({
    required this.productId,
    required this.productItemId,
    required this.displayName,
    this.description,
    required this.specification,
    required this.unitPrice,
    required this.unitOfMeasure,
    this.sku,
    this.barcode,
    this.color,
    this.minimumStock,
  });

  @override
  String toString() => displayName;

  String get searchableText =>
      '$displayName $specification ${sku ?? ''} ${barcode ?? ''} ${description ?? ''}'
          .toLowerCase();
}

class ProductService {
  final ProductRepository _repository;

  ProductService(this._repository);

  /// Get all products as display items for UI
  Future<List<ProductDisplayItem>> getProductDisplayItems() async {
    try {
      developer.log('Starting getProductDisplayItems()');

      final productsWithItems = await _repository.getProductsWithItems();

      developer.log('Raw data received: ${productsWithItems.length} products');

      // Debug: Print first product data structure
      if (productsWithItems.isNotEmpty) {
        developer.log('First product raw data: ${productsWithItems.first}');
      }

      final result = _mapToProductDisplayItems(productsWithItems);
      developer.log('Mapped to ${result.length} display items');

      return result;
    } catch (e, stackTrace) {
      developer.log('Error in getProductDisplayItems: $e');
      developer.log('Stack trace: $stackTrace');
      throw Exception('Failed to get product display items: $e');
    }
  }

  /// Search products by query string
  Future<List<ProductDisplayItem>> searchProductDisplayItems(
    String query,
  ) async {
    try {
      developer.log('Searching products with query: "$query"');

      if (query.trim().isEmpty) {
        return await getProductDisplayItems();
      }

      final productsWithItems = await _repository.searchProductsWithItems(
        query,
      );
      developer.log('Search returned ${productsWithItems.length} products');

      return _mapToProductDisplayItems(productsWithItems);
    } catch (e, stackTrace) {
      developer.log('Error in searchProductDisplayItems: $e');
      developer.log('Stack trace: $stackTrace');
      throw Exception('Failed to search products: $e');
    }
  }

  /// Helper method to map raw data to display items
  List<ProductDisplayItem> _mapToProductDisplayItems(
    List<Map<String, dynamic>> productsWithItems,
  ) {
    developer.log(
      'Starting _mapToProductDisplayItems with ${productsWithItems.length} products',
    );
    final List<ProductDisplayItem> displayItems = [];

    for (int i = 0; i < productsWithItems.length; i++) {
      try {
        final productData = productsWithItems[i];
        developer.log('Processing product $i: ${productData.keys}');

        // Debug: Check each field before creating Product
        developer.log('Product data fields:');
        developer.log(
          '  - id: ${productData['id']} (${productData['id'].runtimeType})',
        );
        developer.log(
          '  - name: ${productData['name']} (${productData['name'].runtimeType})',
        );
        developer.log(
          '  - description: ${productData['description']} (${productData['description'].runtimeType})',
        );
        developer.log(
          '  - brand: ${productData['brand']} (${productData['brand'].runtimeType})',
        );
        developer.log(
          '  - category_id: ${productData['category_id']} (${productData['category_id'].runtimeType})',
        );
        developer.log(
          '  - created_at: ${productData['created_at']} (${productData['created_at']?.runtimeType})',
        );
        developer.log(
          '  - updated_at: ${productData['updated_at']} (${productData['updated_at']?.runtimeType})',
        );

        final product = Product.fromJson(productData);
        developer.log('Product created successfully: ${product.name}');

        final productItems = productData['product_items'] as List<dynamic>?;
        developer.log('Product items: ${productItems?.length ?? 0} items');

        if (productItems != null && productItems.isNotEmpty) {
          for (int j = 0; j < productItems.length; j++) {
            try {
              final itemData = productItems[j] as Map<String, dynamic>;
              developer.log('Processing item $j: ${itemData.keys}');

              // Debug: Check each field before creating ProductItem
              developer.log('Item data fields:');
              developer.log(
                '  - id: ${itemData['id']} (${itemData['id'].runtimeType})',
              );
              developer.log(
                '  - product_id: ${itemData['product_id']} (${itemData['product_id'].runtimeType})',
              );
              developer.log(
                '  - specification: ${itemData['specification']} (${itemData['specification'].runtimeType})',
              );
              developer.log(
                '  - sku: ${itemData['sku']} (${itemData['sku']?.runtimeType})',
              );
              developer.log(
                '  - barcode: ${itemData['barcode']} (${itemData['barcode']?.runtimeType})',
              );
              developer.log(
                '  - unit_price: ${itemData['unit_price']} (${itemData['unit_price'].runtimeType})',
              );
              developer.log(
                '  - unit_of_measure: ${itemData['unit_of_measure']} (${itemData['unit_of_measure'].runtimeType})',
              );
              developer.log(
                '  - color: ${itemData['color']} (${itemData['color']?.runtimeType})',
              );
              developer.log(
                '  - supplier_id: ${itemData['supplier_id']} (${itemData['supplier_id']?.runtimeType})',
              );
              developer.log(
                '  - minimum_stock: ${itemData['minimum_stock']} (${itemData['minimum_stock']?.runtimeType})',
              );
              developer.log(
                '  - created_at: ${itemData['created_at']} (${itemData['created_at']?.runtimeType})',
              );
              developer.log(
                '  - updated_at: ${itemData['updated_at']} (${itemData['updated_at']?.runtimeType})',
              );

              final productItem = ProductItem.fromJson(itemData);
              developer.log(
                'ProductItem created successfully: ${productItem.specification}',
              );

              final displayName = _generateDisplayName(product, productItem);
              developer.log('Display name generated: $displayName');

              displayItems.add(
                ProductDisplayItem(
                  productId: product.id!,
                  productItemId: productItem.id!,
                  displayName: displayName,
                  description: product.description,
                  specification: productItem.specification,
                  unitPrice: productItem.unitPrice!,
                  unitOfMeasure: productItem.unitOfMeasure,
                  sku: productItem.sku,
                  barcode: productItem.barcode,
                  color: productItem.color,
                  minimumStock: productItem.minimumStock,
                ),
              );

              developer.log('ProductDisplayItem added successfully');
            } catch (e, stackTrace) {
              developer.log('Error processing product item $j: $e');
              developer.log('Stack trace: $stackTrace');
              developer.log('Item data: ${productItems[j]}');
              rethrow;
            }
          }
        } else {
          // Product without items - show product only
          try {
            final displayName = _generateDisplayNameForProductOnly(product);
            developer.log('Display name for product only: $displayName');

            displayItems.add(
              ProductDisplayItem(
                productId: product.id!,
                productItemId: 0, // No item ID
                displayName: displayName,
                description: product.description,
                specification: 'No specifications',
                unitPrice: 0.0,
                unitOfMeasure: 'pc',
                sku: null,
                barcode: null,
                color: null,
                minimumStock: null,
              ),
            );

            developer.log('Product-only display item added successfully');
          } catch (e, stackTrace) {
            developer.log('Error creating product-only display item: $e');
            developer.log('Stack trace: $stackTrace');
            rethrow;
          }
        }
      } catch (e, stackTrace) {
        developer.log('Error processing product $i: $e');
        developer.log('Stack trace: $stackTrace');
        developer.log('Product data: ${productsWithItems[i]}');
        rethrow;
      }
    }

    developer.log('Successfully created ${displayItems.length} display items');
    return displayItems;
  }

  /// Generate display name combining product and item info
  String _generateDisplayName(Product product, ProductItem productItem) {
    try {
      developer.log(
        'Generating display name for: ${product.name} - ${productItem.specification}',
      );

      final parts = <String>[];

      // Start with product name
      if (product.name.isEmpty) {
        developer.log('Warning: Product name is empty');
      }
      parts.add(product.name);

      // Add brand if available
      if (product.brand != null && product.brand!.isNotEmpty) {
        parts.add(product.brand!);
        developer.log('Added brand: ${product.brand}');
      }

      final result = parts.join(', ');
      developer.log('Final display name: $result');
      return result;
    } catch (e, stackTrace) {
      developer.log('Error in _generateDisplayName: $e');
      developer.log('Stack trace: $stackTrace');
      developer.log('Product: ${product.toString()}');
      developer.log('ProductItem: ${productItem.toString()}');
      rethrow;
    }
  }

  // Generate display name for product without items
  String _generateDisplayNameForProductOnly(Product product) {
    try {
      developer.log(
        'Generating display name for product only: ${product.name}',
      );

      final parts = <String>[];

      if (product.name.isEmpty) {
        developer.log('Warning: Product name is empty');
      }
      parts.add(product.name);

      if (product.brand != null && product.brand!.isNotEmpty) {
        parts.add(product.brand!);
        developer.log('Added brand: ${product.brand}');
      }

      final result = parts.join(', ');
      developer.log('Final display name (product only): $result');
      return result;
    } catch (e, stackTrace) {
      developer.log('Error in _generateDisplayNameForProductOnly: $e');
      developer.log('Stack trace: $stackTrace');
      developer.log('Product: ${product.toString()}');
      rethrow;
    }
  }

  /// Get display items for a specific product
  Future<List<ProductDisplayItem>> getProductDisplayItemsByProductId(
    int productId,
  ) async {
    try {
      final product = await _repository.getProducts().then(
        (products) => products.firstWhere((p) => p.id == productId),
      );

      final productItems = await _repository.getProductItemsByProductId(
        productId,
      );

      return productItems
          .map(
            (item) => ProductDisplayItem(
              //TODO() refactor this null field
              productId: product.id!,
              productItemId: item.id!,
              displayName: _generateDisplayName(product, item),
              description: product.description,
              specification: item.specification,
              unitPrice: item.unitPrice!,
              unitOfMeasure: item.unitOfMeasure,
              sku: item.sku,
              barcode: item.barcode,
              color: item.color,
              minimumStock: item.minimumStock,
            ),
          )
          .toList();
    } catch (e) {
      throw Exception(
        'Failed to get product display items for product $productId: $e',
      );
    }
  }

  /// Get product by ID
  Future<Product?> getProductById(int id) async {
    try {
      final products = await _repository.getProducts();
      return products.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get product item by ID
  Future<ProductItem?> getProductItemById(int id) async {
    try {
      final productItems = await _repository.getProductItems();
      return productItems.firstWhere((pi) => pi.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Create a new product
  Future<Product> createProduct(Product product) async {
    try {
      return await _repository.createProduct(product);
    } catch (e) {
      throw Exception('Failed to create product: $e');
    }
  }

  /// Create a new product item
  Future<ProductItem> createProductItem(ProductItem productItem) async {
    try {
      return await _repository.createProductItem(productItem);
    } catch (e) {
      throw Exception('Failed to create product item: $e');
    }
  }

  Future<ProductItem> createProductItemWithInitialQuantity(
    ProductItem productItem,
    int initialQuantity,
  ) async {
    try {
      return await _repository.createProductItemWithInitialQuantity(
        productItem,
        initialQuantity,
      );
    } catch (e) {
      throw Exception(
        'Failed to create product item with initial quantity: $e',
      );
    }
  }

  /// Update existing product
  Future<Product> updateProduct(Product product) async {
    try {
      return await _repository.updateProduct(product);
    } catch (e) {
      throw Exception('Failed to update product: $e');
    }
  }

  /// Update existing product item
  Future<ProductItem> updateProductItem(ProductItem productItem) async {
    try {
      return await _repository.updateProductItem(productItem);
    } catch (e) {
      throw Exception('Failed to update product item: $e');
    }
  }

  /// Delete product and all its items
  Future<void> deleteProduct(int id) async {
    try {
      await _repository.deleteProduct(id);
    } catch (e) {
      throw Exception('Failed to delete product: $e');
    }
  }

  /// Delete specific product item
  Future<void> deleteProductItem(int id) async {
    try {
      await _repository.deleteProductItem(id);
    } catch (e) {
      throw Exception('Failed to delete product item: $e');
    }
  }

  /// Helper method to map raw data to display items
  /* List<ProductDisplayItem> _mapToProductDisplayItems(List<Map<String, dynamic>> productsWithItems) {
    final List<ProductDisplayItem> displayItems = [];

    for (final productData in productsWithItems) {
      final product = Product.fromJson(productData);
      final productItems = productData['product_items'] as List<dynamic>?;

      if (productItems != null && productItems.isNotEmpty) {
        for (final itemData in productItems) {
          final productItem = ProductItem.fromJson(itemData);
          displayItems.add(ProductDisplayItem(
            productId: product.id,
            productItemId: productItem.id,
            displayName: _generateDisplayName(product, productItem),
            specification: productItem.specification,
            unitPrice: productItem.unitPrice,
            unitOfMeasure: productItem.unitOfMeasure,
            sku: productItem.sku,
            barcode: productItem.barcode,
            color: productItem.color,
            minimumStock: productItem.minimumStock,
          ));
        }
      } else {
        // Product without items - show product only
        displayItems.add(ProductDisplayItem(
          productId: product.id,
          productItemId: 0, // No item ID
          displayName: _generateDisplayNameForProductOnly(product),
          specification: 'No specifications',
          unitPrice: 0.0,
          unitOfMeasure: 'pc',
          sku: null,
          barcode: null,
          color: null,
          minimumStock: null,
        ));
      }
    }

    return displayItems;
  }

  /// Generate display name combining product and item info
  String _generateDisplayName(Product product, ProductItem productItem) {
    final parts = <String>[];
    
    // Start with product name
    parts.add(product.name);
    
    // Add brand if available
    if (product.brand != null && product.brand!.isNotEmpty) {
      parts.add(product.brand!);
    }
    
    // Add specification
    parts.add(productItem.specification);
    
    // Add color if available and different from specification
    if (productItem.color != null && 
        productItem.color!.isNotEmpty && 
        !productItem.specification.toLowerCase().contains(productItem.color!.toLowerCase())) {
      parts.add(productItem.color!);
    }
    
    return parts.join(' ');
  }

  /// Generate display name for product without items
  String _generateDisplayNameForProductOnly(Product product) {
    final parts = <String>[];
    
    parts.add(product.name);
    
    if (product.brand != null && product.brand!.isNotEmpty) {
      parts.add(product.brand!);
    }
    
    return parts.join(' ');
  } */
}
