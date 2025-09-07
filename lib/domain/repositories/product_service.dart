import '../entities/product.dart';
import '../repositories/product_repository.dart';

class ProductDisplayItem {
  final int productId;
  final int productItemId;
  final String displayName;
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
      '$displayName $specification ${sku ?? ''} ${barcode ?? ''}'.toLowerCase();
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

  /// Search products by query string
  Future<List<ProductDisplayItem>> searchProductDisplayItems(String query) async {
    try {
      if (query.trim().isEmpty) {
        return await getProductDisplayItems();
      }

      final productsWithItems = await _repository.searchProductsWithItems(query);
      return _mapToProductDisplayItems(productsWithItems);
    } catch (e) {
      throw Exception('Failed to search products: $e');
    }
  }

  /// Get display items for a specific product
  Future<List<ProductDisplayItem>> getProductDisplayItemsByProductId(int productId) async {
    try {
      final product = await _repository.getProducts()
          .then((products) => products.firstWhere((p) => p.id == productId));
      
      final productItems = await _repository.getProductItemsByProductId(productId);
      
      return productItems.map((item) => ProductDisplayItem(
        productId: product.id,
        productItemId: item.id,
        displayName: _generateDisplayName(product, item),
        specification: item.specification,
        unitPrice: item.unitPrice,
        unitOfMeasure: item.unitOfMeasure,
        sku: item.sku,
        barcode: item.barcode,
        color: item.color,
        minimumStock: item.minimumStock,
      )).toList();
    } catch (e) {
      throw Exception('Failed to get product display items for product $productId: $e');
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
  List<ProductDisplayItem> _mapToProductDisplayItems(List<Map<String, dynamic>> productsWithItems) {
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
  }
}