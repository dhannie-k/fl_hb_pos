// data/repositories/inventory_repository_impl.dart
import 'package:hb_pos_inv/data/datasources/supabase_datasource.dart';
import '../../domain/entities/inventory.dart';
import '../../domain/repositories/inventory_repository.dart';

class InventoryRepositoryImpl implements InventoryRepository {
  final SupabaseDatasource datasource;

  InventoryRepositoryImpl(this.datasource);

  @override
  Future<List<InventoryItem>> getInventory() async {
    try {
      final response = await datasource.client.rpc('get_inventory');

      if (response == null) {
        throw Exception('No data returned from get_inventory');
      }

      final data = response as List<dynamic>;
      return data
          .map((json) => InventoryItem.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch inventory: $e');
    }
  }

  @override
  Future<void> adjustStock(
    int itemId,
    double qty,
    String direction, {
    String? note,
  }) async {
    await datasource.client.rpc(
      'quick_adjust_stock',
      params: {
        'p_product_item_id': itemId,
        'p_quantity': qty,
        'p_direction': direction,
        'p_note': note,
      },
    );
  }

  @override
  Future<List<InventoryItem>> searchProductItems(String query) async {
    final response = await datasource.client.rpc(
      'search_product_items',
      params: {'search_term': query},
    );
    final data = response as List<dynamic>;
    return data.map((json) => InventoryItem.fromJson(json)).toList();
  }
}
