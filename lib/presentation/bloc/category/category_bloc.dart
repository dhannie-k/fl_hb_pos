import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/category_repository.dart';
import 'category_event.dart';
import 'category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final CategoryRepository repository;

  CategoryBloc(this.repository) : super(CategoryInitial()) {
    on<LoadCategories>(_onLoadCategories);
    on<LoadParentCategories>(_onLoadParentCategories);
    on<CreateCategory>(_onCreateCategory);
    on<UpdateCategory>(_onUpdateCategory);
    on<DeleteCategory>(_onDeleteCategory);
    on<RefreshCategories>(_onRefreshCategories);
  }

  Future<void> _onLoadCategories(
    LoadCategories event,
    Emitter<CategoryState> emit,
  ) async {
    emit(CategoryLoading());
    try {
      final categories = await repository.getAllCategories();
      final parentCategories = await repository.getParentCategories();
      
      emit(CategoriesLoaded(
        categories: categories,
        parentCategories: parentCategories,
      ));
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }

  Future<void> _onLoadParentCategories(
    LoadParentCategories event,
    Emitter<CategoryState> emit,
  ) async {
    try {
      final parentCategories = await repository.getParentCategories();
      
      if (state is CategoriesLoaded) {
        final currentState = state as CategoriesLoaded;
        emit(CategoriesLoaded(
          categories: currentState.categories,
          parentCategories: parentCategories,
        ));
      }
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }

  Future<void> _onCreateCategory(
    CreateCategory event,
    Emitter<CategoryState> emit,
  ) async {
    emit(CategoryCreating());
    try {
      await repository.createCategory(event.name, event.parentId);
      
      // Reload all categories after successful creation
      final categories = await repository.getAllCategories();
      final parentCategories = await repository.getParentCategories();
      
      emit(CategoryOperationSuccess(
        message: 'Category "${event.name}" created successfully',
        categories: categories,
        parentCategories: parentCategories,
      ));
    } catch (e) {
      emit(CategoryError(_extractErrorMessage(e.toString())));
    }
  }

  Future<void> _onUpdateCategory(
    UpdateCategory event,
    Emitter<CategoryState> emit,
  ) async {
    emit(CategoryUpdating());
    try {
      await repository.updateCategory(event.id, event.name, event.parentId);
      
      // Reload all categories after successful update
      final categories = await repository.getAllCategories();
      final parentCategories = await repository.getParentCategories();
      
      emit(CategoryOperationSuccess(
        message: 'Category "${event.name}" updated successfully',
        categories: categories,
        parentCategories: parentCategories,
      ));
    } catch (e) {
      emit(CategoryError(_extractErrorMessage(e.toString())));
    }
  }

  Future<void> _onDeleteCategory(
    DeleteCategory event,
    Emitter<CategoryState> emit,
  ) async {
    emit(CategoryDeleting());
    try {
      await repository.deleteCategory(event.id);
      
      // Reload all categories after successful deletion
      final categories = await repository.getAllCategories();
      final parentCategories = await repository.getParentCategories();
      
      emit(CategoryOperationSuccess(
        message: 'Category deleted successfully',
        categories: categories,
        parentCategories: parentCategories,
      ));
    } catch (e) {
      emit(CategoryError(_extractErrorMessage(e.toString())));
    }
  }

  Future<void> _onRefreshCategories(
    RefreshCategories event,
    Emitter<CategoryState> emit,
  ) async {
    try {
      final categories = await repository.getAllCategories();
      final parentCategories = await repository.getParentCategories();
      
      emit(CategoriesLoaded(
        categories: categories,
        parentCategories: parentCategories,
      ));
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }

  // Helper method to extract meaningful error messages
  String _extractErrorMessage(String error) {
    if (error.contains('Failed to create category:')) {
      return error.replaceFirst('Exception: Failed to create category: ', '');
    }
    if (error.contains('Failed to update category:')) {
      return error.replaceFirst('Exception: Failed to update category: ', '');
    }
    if (error.contains('Failed to delete category:')) {
      return error.replaceFirst('Exception: Failed to delete category: ', '');
    }
    if (error.contains('Cannot delete category')) {
      return error.replaceFirst('Exception: ', '');
    }
    
    return 'An unexpected error occurred. Please try again.';
  }
}