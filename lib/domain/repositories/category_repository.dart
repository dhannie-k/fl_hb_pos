import '../entities/category.dart';

abstract class CategoryRepository {
  Future<List<Category>> getAllCategories();
  Future<List<Category>> getParentCategories();
  Future<Category> getCategoryById(int id);
  Future<Category> createCategory(String name, int? parentId);
  Future<Category> updateCategory(int id, String name, int? parentId);
  Future<void> deleteCategory(int id);
  Future<int> getSubCategoriesCount(int categoryId);
}