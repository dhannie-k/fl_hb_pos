class DashboardStatsModel {
  final double totalSales;
  final int newOrders;
  final int pendingOrders;
  final List<TopItemModel> topItems;
  final List<LowStockItemModel> lowStockItems;
  final int duePaymentsCount;
  final double duePaymentsAmount;

  DashboardStatsModel({
    required this.totalSales,
    required this.newOrders,
    required this.pendingOrders,
    required this.topItems,
    required this.lowStockItems,
    required this.duePaymentsCount,
    required this.duePaymentsAmount,
  });

  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) {
    return DashboardStatsModel(
      totalSales: (json['total_sales'] as num).toDouble(),
      newOrders: json['new_orders'] as int,
      pendingOrders: json['pending_orders'] as int,
      topItems: (json['top_items'] as List)
          .map((item) => TopItemModel.fromJson(item))
          .toList(),
      lowStockItems: (json['low_stock_items'] as List)
          .map((item) => LowStockItemModel.fromJson(item))
          .toList(),
      duePaymentsCount: json['due_payments_count'] as int,
      duePaymentsAmount: (json['due_payments_amount'] as num).toDouble(),
    );
  }
}

class TopItemModel {
  final int productId;
  final String name;
  final String specification;
  final int totalSold;

  TopItemModel({
    required this.productId,
    required this.name,
    required this.specification,
    required this.totalSold,
  });

  factory TopItemModel.fromJson(Map<String, dynamic> json) {
    return TopItemModel(
      productId: json['product_id'] as int,
      name: json['name'] as String,
      specification: json['specification'] as String,
      totalSold: json['total_sold'] as int,
    );
  }
}

class LowStockItemModel {
  final int productItemId;
  final String name;
  final String specification;
  final int stock;

  LowStockItemModel({
    required this.productItemId,
    required this.name,
    required this.specification,
    required this.stock,
  });

  factory LowStockItemModel.fromJson(Map<String, dynamic> json) {
    return LowStockItemModel(
      productItemId: json['product_item_id'] as int,
      name: json['name'] as String,
      specification: json['specification'] as String,
      stock: json['stock'] as int,
    );
  }
}