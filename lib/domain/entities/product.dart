// product.dart
import 'package:equatable/equatable.dart';
import 'dart:developer' as developer;

class Product extends Equatable {
  final int? id;
  final String name;
  final String? description;
  final String? brand;
  final int? categoryId;

  const Product({
    this.id,
    required this.name,
    this.description,
    this.brand,
    this.categoryId,
  });

  // Factory constructor for creating new products
  factory Product.createNew({
    required String name,
    String? description,
    String? brand,
    int? categoryId,
  }) {
    return Product(
      id: null, // Always null for new products
      name: name,
      description: description,
      brand: brand,
      categoryId: categoryId,
    );
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    try {
      developer.log('Creating Product from JSON: $json');

      // Check required fields first
      if (json['id'] == null) throw ArgumentError('id is required');
      if (json['name'] == null) throw ArgumentError('name is required');

      final id = json['id'] is int
          ? json['id'] as int
          : int.parse(json['id'].toString());
      final name = json['name'] as String;

      // Handle optional fields safely
      final description = json['description']?.toString();
      final brand = json['brand']?.toString();
      final categoryId = json['category_id'] != null
          ? (json['category_id'] is int
                ? json['category_id'] as int
                : int.parse(json['category_id'].toString()))
          : null;

      final product = Product(
        id: id,
        name: name,
        description: description,
        brand: brand,
        categoryId: categoryId,
      );

      developer.log('Product created successfully: ${product.name}');
      return product;
    } catch (e, stackTrace) {
      developer.log('Error in Product.fromJson: $e');
      developer.log('JSON data: $json');
      developer.log('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      //'id': id,
      'name': name,
      'description': description,
      'brand': brand,
      'category_id': categoryId,
    };
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'name': name,
      'description': description,
      'brand': brand,
      'category_id': categoryId,
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'name': name,
      'description': description,
      'brand': brand,
      'category_id': categoryId,
    };
  }

  Product copyWith({
    int? id,
    String? name,
    String? description,
    String? brand,
    int? categoryId,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      brand: brand ?? this.brand,
      categoryId: categoryId ?? this.categoryId,
    );
  }

  @override
  List<Object?> get props => [id, name, description, brand, categoryId];
}

// product_item.dart
class ProductItem extends Equatable {
  final int? id;
  final int productId;
  final String? sku;
  final String? barcode;
  final String specification;
  final double? unitPrice;
  final String unitOfMeasure;
  final String? color;
  final int? supplierId;
  final int? minimumStock;
  final DateTime? createdAt;
  final DateTime? updatedAt;

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
    this.createdAt,
    this.updatedAt,
  });

  factory ProductItem.createNew({
    required int productId,
    String? sku,
    String? barcode,
    required String specification,
    double? unitPrice = 0.0,
    required String unitOfMeasure,
    String? color,
    int? supplierId,
    int? minimumStock = 0,    
  }) {
    return ProductItem(
      id: null,
      productId: productId,
      specification: specification,
      unitPrice: unitPrice,
      unitOfMeasure: unitOfMeasure,
      sku: sku,
      barcode: barcode,
      color: color,
      minimumStock: minimumStock,
      createdAt: null,
      updatedAt: null,
    );
  }

 
  factory ProductItem.fromJson(Map<String, dynamic> json) {
    try {
      developer.log('Creating ProductItem from JSON: $json');

      // Check required fields first
      if (json['id'] == null) throw ArgumentError('id is required');
      if (json['product_id'] == null) {
        throw ArgumentError('product_id is required');
      }
      if (json['specification'] == null) {
        throw ArgumentError('specification is required');
      }
      if (json['unit_price'] == null) {
        throw ArgumentError('unit_price is required');
      }
      if (json['unit_of_measure'] == null) {
        throw ArgumentError('unit_of_measure is required');
      }

      final id = json['id'] is int
          ? json['id'] as int
          : int.parse(json['id'].toString());
      final productId = json['product_id'] is int
          ? json['product_id'] as int
          : int.parse(json['product_id'].toString());
      final specification = json['specification'] as String;
      final unitPrice = (json['unit_price'] as num).toDouble();
      final unitOfMeasure = json['unit_of_measure'] as String;

      // Handle optional fields safely
      final sku = json['sku']?.toString();
      final barcode = json['barcode']?.toString();
      final color = json['color']?.toString();
      final supplierId = json['supplier_id'] != null
          ? (json['supplier_id'] is int
                ? json['supplier_id'] as int
                : int.parse(json['supplier_id'].toString()))
          : null;
      final minimumStock = json['minimum_stock'] != null
          ? (json['minimum_stock'] is int
                ? json['minimum_stock'] as int
                : int.parse(json['minimum_stock'].toString()))
          : null;

      // Handle timestamps - check if they exist
      DateTime? createdAt;
      DateTime? updatedAt;

      if (json['created_at'] != null) {
        try {
          createdAt = DateTime.parse(json['created_at'] as String);
        } catch (e) {
          developer.log(
            'Error parsing created_at: ${json['created_at']}, error: $e',
          );
          createdAt = DateTime.now(); // fallback
        }
      } else {
        createdAt = DateTime.now(); // fallback
      }

      if (json['updated_at'] != null) {
        try {
          updatedAt = DateTime.parse(json['updated_at'] as String);
        } catch (e) {
          developer.log(
            'Error parsing updated_at: ${json['updated_at']}, error: $e',
          );
          updatedAt = DateTime.now(); // fallback
        }
      } else {
        updatedAt = DateTime.now(); // fallback
      }

      final productItem = ProductItem(
        id: id,
        productId: productId,
        sku: sku,
        barcode: barcode,
        specification: specification,
        unitPrice: unitPrice,
        unitOfMeasure: unitOfMeasure,
        color: color,
        supplierId: supplierId,
        minimumStock: minimumStock,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

      developer.log(
        'ProductItem created successfully: ${productItem.specification}',
      );
      return productItem;
    } catch (e, stackTrace) {
      developer.log('Error in ProductItem.fromJson: $e');
      developer.log('JSON data: $json');
      developer.log('Stack trace: $stackTrace');
      rethrow;
    }
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
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
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
    id,
    productId,
    sku,
    barcode,
    specification,
    unitPrice,
    unitOfMeasure,
    color,
    supplierId,
    minimumStock,
  ];
}
