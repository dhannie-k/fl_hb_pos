import 'package:hb_pos_inv/data/datasources/supabase_datasource.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  final SupabaseDatasource datasource;

  ProductRepositoryImpl(this.datasource);

  @override
  Future<List<Product>> getProducts() async {
    try {
      final response = await datasource.client
          .from('products')
          .select()
          .order('name');

      return response.map<Product>((json) => Product.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch products: $e');
    }
  }

  @override
  Future<List<ProductItem>> getProductItems() async {
    try {
      final response = await datasource.client
          .from('product_items')
          .select()
          .order('specification');

      return response.map<ProductItem>((json) => ProductItem.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch product items: $e');
    }
  }

  @override
  Future<List<ProductItem>> getProductItemsByProductId(int productId) async {
    try {
      final response = await datasource.client
          .from('product_items')
          .select()
          .eq('product_id', productId)
          .order('specification');

      return response.map<ProductItem>((json) => ProductItem.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch product items for product $productId: $e');
    }
  }

  @override
  Future<Product> createProduct(Product product) async {
    try {
      final response = await datasource.client
          .from('products')
          .insert(product.toJson())
          .select()
          .single();

      return Product.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create product: $e');
    }
  }

  @override
  Future<ProductItem> createProductItem(ProductItem productItem) async {
    try {
      final response = await datasource.client
          .from('product_items')
          .insert(productItem.toJson())
          .select()
          .single();

      return ProductItem.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create product item: $e');
    }
  }

  @override
  Future<Product> updateProduct(Product product) async {
    try {
      final response = await datasource.client
          .from('products')
          .update(product.toJson())
          .eq('id', product.id!)
          .select()
          .single();

      return Product.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update product: $e');
    }
  }

  @override
  Future<ProductItem> updateProductItem(ProductItem productItem) async {
    try {
      final response = await datasource.client
          .from('product_items')
          .update(productItem.toJson())
          .eq('id', productItem.id)
          .select()
          .single();

      return ProductItem.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update product item: $e');
    }
  }

  @override
  Future<void> deleteProduct(int id) async {
    try {
      await datasource.client
          .from('products')
          .delete()
          .eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete product: $e');
    }
  }

  @override
  Future<void> deleteProductItem(int id) async {
    try {
      await datasource.client
          .from('product_items')
          .delete()
          .eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete product item: $e');
    }
  }

  @override
Future<List<Map<String, dynamic>>> getProductsWithItems() async {
  try {
    final response = await datasource.client
        .from('products')
        .select('''
          id,
          name,
          description,
          brand,
          category_id,
          product_items (
            id,
            product_id,
            specification,
            sku,
            barcode,
            unit_of_measure,
            color,
            unit_price,
            supplier_id,
            minimum_stock,
            created_at,
            updated_at
          )
        ''')
        .order('name');

    return List<Map<String, dynamic>>.from(response);
  } catch (e) {
    throw Exception('Failed to fetch products with items: $e');
  }
}

  @override
  Future<List<Map<String, dynamic>>> searchProductsWithItems(String query) async {
    try {
      // Fix the search query syntax - use individual or conditions
      final response = await datasource.client
          .from('products')
          .select('''
            id,
            name,
            description,
            brand,
            category_id,
            product_items (
              id,
              product_id,
              specification,
              sku,
              barcode,
              unit_of_measure,
              color,
              unit_price,
              supplier_id,
              minimum_stock,
              created_at,
              updated_at
            )
          ''')
          .or('name.ilike.%$query%,description.ilike.%$query%,brand.ilike.%$query%')
          .order('name');

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to search products: $e');
    }
  }
}