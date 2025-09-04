import '../entities/dasboard_stats.dart';

abstract class DashboardRepository {
  Future<double> getTotalSalesCurrentMonth();
  Future<int> getNewOrdersCount();
  Future<int> getPendingOrdersCount();
  Future<List<TopItem>> getTopSellingItems(int limit);
  Future<List<LowStockItem>> getLowStockItems(int threshold);
  Future<Map<String, dynamic>> getDuePaymentsSummary();
}

