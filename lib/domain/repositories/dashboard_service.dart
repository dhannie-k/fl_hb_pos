import 'dashboard_repository.dart';
import '../entities/dasboard_stats.dart';

class DashboardService {
  final DashboardRepository repository;

  DashboardService(this.repository);

  Future<DashboardStats> getDashboardStats() async {
    try {
      // Execute all repository calls in parallel
      final results = await Future.wait([
        repository.getTotalSalesCurrentMonth(),
        repository.getNewOrdersCount(), 
        repository.getPendingOrdersCount(),
        repository.getTopSellingItems(5),
        repository.getLowStockItems(10),
        repository.getDuePaymentsSummary(),
      ]);

      // Extract results with proper types
      final totalSales = results[0] as double;
      final newOrders = results[1] as int;
      final pendingOrders = results[2] as int;
      final topItems = results[3] as List<TopItem>;
      final lowStockItems = results[4] as List<LowStockItem>;
      final duePayments = results[5] as Map<String, dynamic>;

      return DashboardStats(
        totalSales: totalSales,
        newOrders: newOrders,
        pendingOrders: pendingOrders,
        topItems: topItems,
        lowStockItems: lowStockItems,
        duePaymentsCount: duePayments['due_count'] ?? 0,
        duePaymentsAmount: (duePayments['total_due'] ?? 0.0).toDouble(),
      );
    } catch (e) {
      // In production, you'd use a proper logging framework like logger package
      // For now, we'll let the error bubble up to be handled by the BLoC
      rethrow;
    }
  }
}