// domain/repositories/inventory_repository.dart
import '../entities/inventory.dart';

abstract class InventoryRepository {
  Future<List<InventoryItem>> getInventory();
}
