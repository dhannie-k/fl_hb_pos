import 'package:equatable/equatable.dart';
import '../../../domain/entities/category.dart';

abstract class CategoryState extends Equatable {
  const CategoryState();

  @override
  List<Object?> get props => [];
}

class CategoryInitial extends CategoryState {}

class CategoryLoading extends CategoryState {}

class CategoriesLoaded extends CategoryState {
  final List<Category> categories;
  final List<Category> parentCategories;

  const CategoriesLoaded({
    required this.categories,
    required this.parentCategories,
  });

  @override
  List<Object?> get props => [categories, parentCategories];
}

class CategoryOperationSuccess extends CategoryState {
  final String message;
  final List<Category> categories;
  final List<Category> parentCategories;

  const CategoryOperationSuccess({
    required this.message,
    required this.categories,
    required this.parentCategories,
  });

  @override
  List<Object?> get props => [message, categories, parentCategories];
}

class CategoryError extends CategoryState {
  final String message;

  const CategoryError(this.message);

  @override
  List<Object?> get props => [message];
}

// For specific operations that need loading states
class CategoryCreating extends CategoryState {}

class CategoryUpdating extends CategoryState {}

class CategoryDeleting extends CategoryState {}