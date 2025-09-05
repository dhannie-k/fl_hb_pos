import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/supabase_datasource.dart';
import '../models/category_model.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final SupabaseDatasource datasource;

  CategoryRepositoryImpl(this.datasource);

  @override
  Future<List<Category>> getAllCategories() async {
    try {
      final response = await datasource.client
          .from('categories')
          .select('*')
          .order('parent_id')
          .order('name');

      return response
          .map<Category>((json) => CategoryModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch categories: $e');
    }
  }

  @override
  Future<List<Category>> getParentCategories() async {
    try {
      final response = await datasource.client
          .from('categories')
          .select('*')
          .isFilter('parent_id', null)
          .order('name');

      return response
          .map<Category>((json) => CategoryModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch parent categories: $e');
    }
  }

  @override
  Future<Category> getCategoryById(int id) async {
    try {
      final response = await datasource.client
          .from('categories')
          .select('*')
          .eq('id', id)
          .single();

      return CategoryModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch category: $e');
    }
  }

  @override
  Future<Category> createCategory(String name, int? parentId) async {
    try {
      final categoryData = {
        'name': name,
        'parent_id': parentId,
      };

      final response = await datasource.client
          .from('categories')
          .insert(categoryData)
          .select()
          .single();

      return CategoryModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create category: $e');
    }
  }

  @override
  Future<Category> updateCategory(int id, String name, int? parentId) async {
    try {
      // Check if trying to set self as parent
      if (parentId == id) {
        throw Exception('Category cannot be its own parent');
      }

      final categoryData = {
        'name': name,
        'parent_id': parentId,
      };

      final response = await datasource.client
          .from('categories')
          .update(categoryData)
          .eq('id', id)
          .select()
          .single();

      return CategoryModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update category: $e');
    }
  }

  @override
  Future<void> deleteCategory(int id) async {
    try {
      // Check if category has subcategories
      final subCategoriesCount = await getSubCategoriesCount(id);
      if (subCategoriesCount > 0) {
        throw Exception('Cannot delete category with subcategories');
      }

      // Check if category has products
      final productsResponse = await datasource.client
          .from('products')
          .select('id')
          .eq('category_id', id)
          .limit(1);

      if (productsResponse.isNotEmpty) {
        throw Exception('Cannot delete category with products');
      }

      await datasource.client
          .from('categories')
          .delete()
          .eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete category: $e');
    }
  }

  @override
  Future<int> getSubCategoriesCount(int categoryId) async {
    try {
      final response = await datasource.client
          .from('categories')
          .select('id')
          .eq('parent_id', categoryId);

      return response.length;
    } catch (e) {
      throw Exception('Failed to count subcategories: $e');
    }
  }
}