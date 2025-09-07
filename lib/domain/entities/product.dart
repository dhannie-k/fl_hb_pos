// product.dart
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

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      brand: json['brand'] as String?,
      categoryId: json['category_id'] as int?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'brand': brand,
      'category_id': categoryId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toCreateJson() {
    // For creating new products, exclude id and timestamps
    return {
      'name': name,
      'description': description,
      'brand': brand,
      'category_id': categoryId,
    };
  }

  Map<String, dynamic> toUpdateJson() {
    // For updating products, exclude id and created_at
    return {
      'name': name,
      'description': description,
      'brand': brand,
      'category_id': categoryId,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  Product copyWith({
    int? id,
    String? name,
    String? description,
    String? brand,
    int? categoryId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      brand: brand ?? this.brand,
      categoryId: categoryId ?? this.categoryId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [id, name, description, brand, categoryId];
}

// product_item.dart
class ProductItem extends Equatable {
  final int id;
  final int productId;
  final String? sku;
  final String? barcode;
  final String specification;
  final double unitPrice;
  final String unitOfMeasure;
  final String? color;
  final int? supplierId;
  final int? minimumStock;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ProductItem({
    required this.id,
    required this.productId,
    this.sku,
    this.barcode,
    required this.specification,
    required this.unitPrice,
    required this.unitOfMeasure,
    this.color,
    this.supplierId,
    this.minimumStock,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProductItem.fromJson(Map<String, dynamic> json) {
    return ProductItem(
      id: json['id'] as int,
      productId: json['product_id'] as int,
      sku: json['sku'] as String?,
      barcode: json['barcode'] as String?,
      specification: json['specification'] as String,
      unitPrice: (json['unit_price'] as num).toDouble(),
      unitOfMeasure: json['unit_of_measure'] as String,
      color: json['color'] as String?,
      supplierId: json['supplier_id'] as int?,
      minimumStock: json['minimum_stock'] as int?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'sku': sku,
      'barcode': barcode,
      'specification': specification,
      'unit_price': unitPrice,
      'unit_of_measure': unitOfMeasure,
      'color': color,
      'supplier_id': supplierId,
      'minimum_stock': minimumStock,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toCreateJson() {
    // For creating new product items, exclude id and timestamps
    return {
      'product_id': productId,
      'sku': sku,
      'barcode': barcode,
      'specification': specification,
      'unit_price': unitPrice,
      'unit_of_measure': unitOfMeasure,
      'color': color,
      'supplier_id': supplierId,
      'minimum_stock': minimumStock ?? 0,
    };
  }

  Map<String, dynamic> toUpdateJson() {
    // For updating product items, exclude id and created_at
    return {
      'product_id': productId,
      'sku': sku,
      'barcode': barcode,
      'specification': specification,
      'unit_price': unitPrice,
      'unit_of_measure': unitOfMeasure,
      'color': color,
      'supplier_id': supplierId,
      'minimum_stock': minimumStock ?? 0,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  ProductItem copyWith({
    int? id,
    int? productId,
    String? sku,
    String? barcode,
    String? specification,
    double? unitPrice,
    String? unitOfMeasure,
    String? color,
    int? supplierId,
    int? minimumStock,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      sku: sku ?? this.sku,
      barcode: barcode ?? this.barcode,
      specification: specification ?? this.specification,
      unitPrice: unitPrice ?? this.unitPrice,
      unitOfMeasure: unitOfMeasure ?? this.unitOfMeasure,
      color: color ?? this.color,
      supplierId: supplierId ?? this.supplierId,
      minimumStock: minimumStock ?? this.minimumStock,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id, productId, sku, barcode, specification, unitPrice, 
    unitOfMeasure, color, supplierId, minimumStock
  ];
}