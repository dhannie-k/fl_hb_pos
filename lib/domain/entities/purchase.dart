
// Using an enum for payment methods as defined in your SQL schema.
enum PaymentMethod {
  cash,
  banktransfer,
  creditterms,
  deposit;

  String toJson() => name;
  static PaymentMethod fromJson(String json) => values.byName(json);
}

class Purchase {
  final int? id;
  final int? transactionId;
  final String? poNumber;
  final int? supplierId;
  final String? supplierName;
  final DateTime purchaseDate;
  final double totalAmount;
  final PaymentMethod paymentMethod;
  final List<PurchaseItem> items;

  Purchase({
    this.id,
    this.transactionId,
    this.poNumber,
    this.supplierId,
    this.supplierName,
    required this.purchaseDate,
    required this.totalAmount,
    required this.paymentMethod,
    this.items = const [],
  });

  Purchase copyWith({
    int? id,
    int? transactionId,
    String? poNumber,
    int? supplierId,
    String? supplierName,
    DateTime? purchaseDate,
    double? totalAmount,
    PaymentMethod? paymentMethod,
    List<PurchaseItem>? items,
  }) {
    return Purchase(
      id: id ?? this.id,
      transactionId: transactionId ?? this.transactionId,
      poNumber: poNumber ?? this.poNumber,
      supplierId: supplierId ?? this.supplierId,
      supplierName: supplierName ?? this.supplierName,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      totalAmount: totalAmount ?? this.totalAmount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      items: items ?? this.items,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'po_number': poNumber,
      'supplier_id': supplierId,
      'purchase_date': purchaseDate.toIso8601String(),
      'total_amount': totalAmount,
      'payment_method': paymentMethod.toJson(),
    };
  }

  static Purchase fromMap(Map<String, dynamic> map) {
    return Purchase(
      id: map['id'],
      transactionId: map['transaction_id'],
      poNumber: map['po_number'],
      supplierId: map['supplier_id'],
      supplierName: map['supplier_name'],
      purchaseDate: DateTime.parse(map['purchase_date']),
      totalAmount: (map['total_amount'] as num).toDouble(),
      paymentMethod: PaymentMethod.fromJson(map['payment_method']),
      items: map['items'] != null
          ? List<PurchaseItem>.from(
              map['items']?.map((x) => PurchaseItem.fromMap(x)))
          : [],
    );
  }
}

class PurchaseItem {
  final int? id;
  final int? purchaseId;
  final int productItemId;
  final String product;
  final String? brand;
  final String specification;
  final String? itemColor;
  final double quantityOrdered;
  final double unitCost;
  // This can be populated from a join for display purposes
  //final String? productName;

  PurchaseItem({
    this.id,
    this.purchaseId,
    required this.productItemId,
    required this.quantityOrdered,
    required this.unitCost,
    required this.product,
    this.brand,
    required this.specification,
    this.itemColor,
  });

  Map<String, dynamic> toMap() {
    return {
      'purchase_id': purchaseId,
      'product_item_id': productItemId,
      'quantity_ordered': quantityOrdered,
      'unit_cost': unitCost,
    };
  }

  static PurchaseItem fromMap(Map<String, dynamic> map) {
    return PurchaseItem(
      id: map['id'],
      purchaseId: map['purchase_id'],
      productItemId: map['product_item_id'],
      quantityOrdered: (map['quantity_ordered'] as num).toDouble(),
      unitCost: (map['unit_cost'] as num).toDouble(),
      product: map['product_name'],
      brand: map['brand'] ?? '',
      specification: map['product_specification'],
      itemColor: map['item_color'] ?? '',
      // Assuming a potential join to get product name
      //productName: map['product_items']?['products']?['name'],
    );
  }
}
