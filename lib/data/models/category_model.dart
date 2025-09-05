import '../../domain/entities/category.dart';

class CategoryModel extends Category {
  const CategoryModel({
    required super.id,
    required super.name,
    super.parentId,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as int,
      name: json['name'] as String,
      parentId: json['parent_id'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'parent_id': parentId,
    };
  }

  // For creating new categories (without ID)
  Map<String, dynamic> toJsonForCreate() {
    return {
      'name': name,
      'parent_id': parentId,
    };
  }

  // Convert entity to model
  factory CategoryModel.fromEntity(Category category) {
    return CategoryModel(
      id: category.id,
      name: category.name,
      parentId: category.parentId,
    );
  }

  // Create copy with updated fields
  CategoryModel copyWith({
    int? id,
    String? name,
    int? parentId,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      parentId: parentId ?? this.parentId,
    );
  }
}