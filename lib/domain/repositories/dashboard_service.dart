import 'dashboard_repository.dart';
import '../entities/dasboard_stats.dart';

class DashboardService {
  final DashboardRepository repository;

  DashboardService(this.repository);

  Future<DashboardStats> getDashboardStats() async {
    // Compose the dashboard stats by calling individual repository methods
    final results = await Future.wait([
      repository.getTotalSalesCurrentMonth(),
      repository.getNewOrdersCount(),
      repository.getPendingOrdersCount(),
      repository.getTopSellingItems(5),
      repository.getLowStockItems(10),
      repository.getDuePaymentsSummary(),
    ]);

    final duePayments = results[5] as (int, double);

    return DashboardStats(
      totalSales: results[0] as double,
      newOrders: results[1] as int,
      pendingOrders: results[2] as int,
      topItems: results[3] as List<TopItem>,
      lowStockItems: results[4] as List<LowStockItem>,
      duePaymentsCount: duePayments.$1,
      duePaymentsAmount: duePayments.$2,
    );
  }
}
