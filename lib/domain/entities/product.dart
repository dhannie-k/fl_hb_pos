import 'package:equatable/equatable.dart';

class Product extends Equatable {
  final int id;
  final String name;
  final String? description;
  final String? brand;
  final int? categoryId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Product({
    required this.id,
    required this.name,
    this.description,
    this.brand,
    this.categoryId,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [id, name, description, brand, categoryId];
}

class ProductItem extends Equatable {
  final int id;
  final int productId;
  final String? sku;
  final String specification;
  final double unitPrice;
  final String unitOfMeasure;
  final String? color;
  final int? supplierId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ProductItem({
    required this.id,
    required this.productId,
    this.sku,
    required this.specification,
    required this.unitPrice,
    required this.unitOfMeasure,
    this.color,
    this.supplierId,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id, productId, sku, specification, unitPrice, 
    unitOfMeasure, color, supplierId
  ];
}