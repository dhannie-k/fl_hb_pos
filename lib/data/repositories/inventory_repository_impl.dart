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
  Future<void> adjustStock(int itemId, int newQuantity) async {
  await datasource.client.from('inventory')
      .update({'stock': newQuantity})
      .eq('product_item_id', itemId);
}

}
