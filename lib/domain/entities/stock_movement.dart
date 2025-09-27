class StockMovement {
  final int id;
  final DateTime timestamp;
  final String transactionType;
  final String direction;
  final int productItemId; // <- new
  final String productName;
  final String? brand;
  final String? specification;
  final String? color;
  final String? sku;
  final double quantity;
  final String? note;

  StockMovement({
    required this.id,
    required this.timestamp,
    required this.transactionType,
    required this.direction,
    required this.productItemId,
    required this.productName,
    this.brand,
    this.specification,
    this.color,
    this.sku,
    required this.quantity,
    this.note,
  });

  factory StockMovement.fromJson(Map<String, dynamic> json) {
    return StockMovement(
      id: json['id'] as int,
      timestamp: DateTime.parse(json['movement_timestamp']),
      transactionType: json['transaction_type'] as String,
      direction: json['direction'] as String,
      productItemId: json['product_item_id'] as int,
      productName: json['product_name'] as String,
      brand: json['brand'] as String?,
      specification: json['specification'] as String?,
      color: json['color'] as String?,
      sku: json['sku'] as String?,
      quantity: (json['quantity'] as num).toDouble(),
      note: json['note'] as String?,
    );
  }
}
