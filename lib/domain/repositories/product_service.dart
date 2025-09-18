import '../entities/product.dart';
import '../repositories/product_repository.dart';
import 'dart:developer' as developer;

class ProductDisplayItem {
  final int productId;
  final String name;
  final String? description;
  final String? brand;
  final int categoryId;
  final List<ProductItem> items;
  final String? imageUrl;

  const ProductDisplayItem({
    required this.productId,
    required this.name,
    this.description,
    this.brand,
    required this.categoryId,
    required this.items,
    this.imageUrl,
  });

  String get searchableText =>
      '$name ${description ?? ''} ${brand ?? ''}'.toLowerCase();

  /// Combine name and brand for UI
  String get displayName {
    if (brand == null || brand!.trim().isEmpty) {
      return name;
    }
    return '$name, $brand';
  }
}

class ProductService {
  final ProductRepository _repository;

  ProductService(this._repository);

  /// Get all products as display items for UI
  Future<List<ProductDisplayItem>> getProductDisplayItems() async {
    try {
      final productsWithItems = await _repository.getProductsWithItems();
      return _mapToProductDisplayItems(productsWithItems);
    } catch (e) {
      throw Exception('Failed to get product display items: $e');
    }
  }

  Future<ProductDisplayItem?> getProductDisplayItemsById(int productId) async {
    final productsWithItems = await _repository.getProductsWithItems();
    final all = _mapToProductDisplayItems(productsWithItems);
    try {
      return all.firstWhere((p) => p.productId == productId);
    } catch (_) {
      return null;
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
    return productsWithItems.map((productData) {
      final itemsData = productData['items'] as List<dynamic>? ?? [];

      return ProductDisplayItem(
        productId: productData['id'],
        name: productData['name'],
        description: productData['description'],
        brand: productData['brand'],
        categoryId: productData['category_id'],
        items: itemsData.map((i) => ProductItem.fromJson(i)).toList(),
        imageUrl: productData['image_url'],
      );
    }).toList();
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
}
