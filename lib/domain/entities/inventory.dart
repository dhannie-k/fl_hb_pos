// domain/entities/inventory_item.dart
import 'package:equatable/equatable.dart';

class InventoryItem extends Equatable {
  final int productId;
  final String productName;
  final String? brand;
  final String? description;
  final String? imageUrl;
  final int? categoryId;
  final String? categoryName;
  final int itemId;
  final String specification;
  final String? sku;
  final String? barcode;
  final String unitOfMeasure;
  final String? color;
  final double? unitPrice;
  final int? minimumStock;
  final double stock;
  final DateTime? updatedAt;

  const InventoryItem({
    required this.productId,
    required this.productName,
    this.brand,
    this.description,
    this.imageUrl,
    this.categoryId,
    this.categoryName,
    required this.itemId,
    required this.specification,
    this.sku,
    this.barcode,
    required this.unitOfMeasure,
    this.color,
    this.unitPrice,
    this.minimumStock,
    required this.stock,
    this.updatedAt,
  });

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(
      productId: json['product_id'],
      productName: json['product_name'],
      brand: json['brand'],
      description: json['description'],
      imageUrl: json['image_url'],
      categoryId: json['category_id'],
      categoryName: json['category_name'],
      itemId: json['item_id'],
      specification: json['specification'],
      sku: json['sku'],
      barcode: json['barcode'],
      unitOfMeasure: json['unit_of_measure'],
      color: json['color'],
      unitPrice: (json['unit_price'] as num?)?.toDouble(),
      minimumStock: json['minimum_stock'],
      stock: json['stock'] ?? 0.0,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  @override
  List<Object?> get props => [
        productId,
        productName,
        brand,
        description,
        imageUrl,
        categoryId,
        categoryName,
        itemId,
        specification,
        sku,
        barcode,
        unitOfMeasure,
        color,
        unitPrice,
        minimumStock,
        stock,
        updatedAt,
      ];

  InventoryItem copyWith({
    int? productId,
    String? productName,
    String? brand,
    String? description,
    String? imageUrl,
    int? categoryId,
    String? categoryName,
    int? itemId,
    String? specification,
    String? sku,
    String? barcode,
    String? unitOfMeasure,
    String? color,
    double? unitPrice,
    int? minimumStock,
    double? stock,
    DateTime? updatedAt,
  }) {
    return InventoryItem(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      brand: brand ?? this.brand,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      itemId: itemId ?? this.itemId,
      specification: specification ?? this.specification,
      sku: sku ?? this.sku,
      barcode: barcode ?? this.barcode,
      unitOfMeasure: unitOfMeasure ?? this.unitOfMeasure,
      color: color ?? this.color,
      unitPrice: unitPrice ?? this.unitPrice,
      minimumStock: minimumStock ?? this.minimumStock,
      stock: stock ?? this.stock,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
