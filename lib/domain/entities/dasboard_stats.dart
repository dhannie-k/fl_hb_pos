class DashboardStats {
  final double totalSales;
  final int newOrders;
  final int pendingOrders;
  final List<TopItem> topItems;
  final List<LowStockItem> lowStockItems;
  final int duePaymentsCount;
  final double duePaymentsAmount;

  DashboardStats({
    required this.totalSales,
    required this.newOrders,
    required this.pendingOrders,
    required this.topItems,
    required this.lowStockItems,
    required this.duePaymentsCount,
    required this.duePaymentsAmount,
  });
}

class TopItem {
  final int productId;
  final String name;
  final String specification;
  final double totalSold;

  TopItem({
    required this.productId,
    required this.name,
    required this.specification,
    required this.totalSold,
  });
}

class LowStockItem {
  final int productItemId;
  final String name;
  final String specification;
  final double stock;

  LowStockItem({
    required this.productItemId,
    required this.name,
    required this.specification,
    required this.stock,
  });
}