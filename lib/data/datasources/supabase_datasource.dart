import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/stock_movement.dart';

class SupabaseDatasource {
  final SupabaseClient client = Supabase.instance.client;

  // Dashboard queries
  Future<double> getTotalSalesCurrentMonth() async {
    try {
      final response = await client
          .from('sales_order')
          .select('total_amount')
          .gte('created_at', DateTime(DateTime.now().year, DateTime.now().month, 1).toIso8601String())
          .lt('created_at', DateTime(DateTime.now().year, DateTime.now().month + 1, 1).toIso8601String());

      if (response.isEmpty) return 0.0;

      double total = 0.0;
      for (var record in response) {
        total += (record['total_amount'] as num).toDouble();
      }
      return total;
    } catch (e) {
      throw Exception('Failed to fetch total sales: $e');
    }
  }

  Future<int> getNewOrdersCount() async {
    try {
      final response = await client
          .from('sales_order')
          .select('id')
          .eq('status', 'new');

      return response.length;
    } catch (e) {
      throw Exception('Failed to fetch new orders count: $e');
    }
  }

  Future<int> getPendingOrdersCount() async {
    try {
      final response = await client
          .from('sales_order')
          .select('id')
          .inFilter('status', ['processed', 'partiallydelivered']);

      return response.length;
    } catch (e) {
      throw Exception('Failed to fetch pending orders count: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getTopSellingItems(int limit) async {
    try {
      final response = await client.rpc('get_top_selling_items', params: {
        'item_limit': limit,
      });

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      // Fallback if RPC doesn't exist - use regular query
      try {
        final response = await client
            .from('sales_order_items')
            .select('''
              quantity_ordered,
              product_items!inner(
                id,
                specification,
                products!inner(
                  id,
                  name
                )
              )
            ''')
            .limit(limit);

        // Group by product and sum quantities
        Map<String, Map<String, dynamic>> grouped = {};
        
        for (var item in response) {
          final productId = item['product_items']['products']['id'].toString();
          final productName = item['product_items']['products']['name'];
          final specification = item['product_items']['specification'];
          final quantity = (item['quantity_ordered'] as num).toInt();

          final key = '$productId-$specification';
          if (grouped.containsKey(key)) {
            grouped[key]!['total_sold'] += quantity;
          } else {
            grouped[key] = {
              'product_id': int.parse(productId),
              'name': productName,
              'specification': specification,
              'total_sold': quantity,
            };
          }
        }

        // Sort by total_sold and take top items
        final sortedItems = grouped.values.toList()
          ..sort((a, b) => (b['total_sold'] as int).compareTo(a['total_sold'] as int));

        return sortedItems.take(limit).toList();
      } catch (e2) {
        throw Exception('Failed to fetch top selling items: $e2');
      }
    }
  }

  Future<List<Map<String, dynamic>>> getLowStockItems(int threshold) async {
    try {
      final response = await client
          .from('inventory')
          .select('''
            product_item_id,
            stock,
            product_items!inner(
              id,
              specification,
              products!inner(
                id,
                name
              )
            )
          ''')
          .lte('stock', threshold)
          .order('stock', ascending: true);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to fetch low stock items: $e');
    }
  }

  Future<Map<String, dynamic>> getDuePaymentsSummary() async {
    try {
      // This is a simplified version - you might need to adjust based on your payment tracking
      final response = await client.rpc('get_due_payments_summary');

      if (response != null) {
        return Map<String, dynamic>.from(response);
      }

      // Fallback - get all sales orders without corresponding payments
      final unpaidOrders = await client
          .from('sales_order')
          .select('id, total_amount')
          .eq('payment_method', 'creditterms'); // Assuming credit terms need payment tracking

      double totalDue = 0.0;
      for (var order in unpaidOrders) {
        totalDue += (order['total_amount'] as num).toDouble();
      }

      return {
        'due_count': unpaidOrders.length,
        'total_due': totalDue,
      };
    } catch (e) {
      throw Exception('Failed to fetch due payments summary: $e');
    }
  }

  Future<List<StockMovement>> getStockMovements({
  DateTime? startDate,
  DateTime? endDate,
  String? direction,
  String? type,
}) async {
  final data = await client.rpc(
    'get_stock_movements',
    params: {
      'p_start_date': startDate?.toIso8601String(),
      'p_end_date': endDate?.toIso8601String(),
      'p_direction': direction,
      'p_type': type,
    },
  );

  // data is already a List<dynamic>
  final list = data as List<dynamic>;
  return list.map((e) => StockMovement.fromJson(e as Map<String, dynamic>)).toList();
}

Future<double> getCurrentStock(int itemId) async {
  final response = await client
      .from('inventory')
      .select('stock')
      .eq('product_item_id', itemId)
      .maybeSingle();

  if (response == null) throw Exception("Item not found");
  return (response['stock'] as num).toDouble();
}

}