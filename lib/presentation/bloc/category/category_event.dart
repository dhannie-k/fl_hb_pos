import 'package:equatable/equatable.dart';

abstract class CategoryEvent extends Equatable {
  const CategoryEvent();

  @override
  List<Object?> get props => [];
}

class LoadCategories extends CategoryEvent {
  const LoadCategories();
}

class LoadParentCategories extends CategoryEvent {}

class CreateCategory extends CategoryEvent {
  final String name;
  final int? parentId;

  const CreateCategory({
    required this.name,
    this.parentId,
  });

  @override
  List<Object?> get props => [name, parentId];
}

class UpdateCategory extends CategoryEvent {
  final int id;
  final String name;
  final int? parentId;

  const UpdateCategory({
    required this.id,
    required this.name,
    this.parentId,
  });

  @override
  List<Object?> get props => [id, name, parentId];
}

class DeleteCategory extends CategoryEvent {
  final int id;

  const DeleteCategory(this.id);

  @override
  List<Object?> get props => [id];
}

class RefreshCategories extends CategoryEvent {}