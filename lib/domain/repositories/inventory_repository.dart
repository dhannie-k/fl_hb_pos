// domain/repositories/inventory_repository.dart
import '../entities/inventory.dart';

abstract class InventoryRepository {
  Future<List<InventoryItem>> getInventory();
  Future<void> adjustStock(int itemId, int newQuantity);

}
