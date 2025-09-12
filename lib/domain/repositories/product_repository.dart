import '../../domain/entities/product.dart';

abstract class ProductRepository {
  // Product operations
  Future<List<Product>> getProducts();
  Future<Product> createProduct(Product product);
  Future<Product> updateProduct(Product product);
  Future<void> deleteProduct(int id);
  
  // Product item operations
  Future<List<ProductItem>> getProductItems();
  Future<List<ProductItem>> getProductItemsByProductId(int productId);
  Future<ProductItem> createProductItem(ProductItem productItem);
  Future<ProductItem> createProductItemWithInitialQuantity(
    ProductItem productItem,
    int initialQuantity,
  );
  Future<ProductItem> updateProductItem(ProductItem productItem);
  Future<void> deleteProductItem(int id);
  
  // Combined operations for efficient queries
  Future<List<Map<String, dynamic>>> getProductsWithItems();
  Future<List<Map<String, dynamic>>> searchProductsWithItems(String query);
}