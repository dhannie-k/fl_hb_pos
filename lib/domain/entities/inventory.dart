import 'package:equatable/equatable.dart';

class InventoryItem extends Equatable {
  final int productItemId;
  final int stock;
  final DateTime updatedAt;

  const InventoryItem({
    required this.productItemId,
    required this.stock,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [productItemId, stock, updatedAt];
}