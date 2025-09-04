import 'package:equatable/equatable.dart';

class Category extends Equatable {
  final int id;
  final String name;
  final int? parentId;

  const Category({
    required this.id,
    required this.name,
    this.parentId,
  });

  @override
  List<Object?> get props => [id, name, parentId];
}