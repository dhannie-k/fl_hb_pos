import '../../domain/entities/dasboard_stats.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/supabase_datasource.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final SupabaseDatasource datasource;

  DashboardRepositoryImpl(this.datasource);

  @override
  Future<double> getTotalSalesCurrentMonth() async {
    return await datasource.getTotalSalesCurrentMonth();
  }

  @override
  Future<int> getNewOrdersCount() async {
    return await datasource.getNewOrdersCount();
  }

  @override
  Future<int> getPendingOrdersCount() async {
    return await datasource.getPendingOrdersCount();
  }

  @override
  Future<List<TopItem>> getTopSellingItems(int limit) async {
    final data = await datasource.getTopSellingItems(limit);
    return data.map((item) => TopItem(
      productId: item['product_id'],
      name: item['name'],
      specification: item['specification'],
      totalSold: item['total_sold'],
    )).toList();
  }

  @override
  Future<List<LowStockItem>> getLowStockItems(int threshold) async {
    final data = await datasource.getLowStockItems(threshold);
    return data.map((item) => LowStockItem(
      productItemId: item['product_item_id'],
      name: item['product_items']['products']['name'],
      specification: item['product_items']['specification'],
      stock: item['stock'],
    )).toList();
  }

  @override
  Future<Map<String, dynamic>> getDuePaymentsSummary() async {
    return await datasource.getDuePaymentsSummary();
  }
}
