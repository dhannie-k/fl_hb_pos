// domain/services/inventory_service.dart
import '../entities/inventory.dart';
import '../repositories/inventory_repository.dart';

class InventoryService {
  final InventoryRepository _repository;

  InventoryService(this._repository);

  Future<List<InventoryItem>> getInventoryItems() async {
    try {
      return await _repository.getInventory();
    } catch (e) {
      throw Exception('Failed to get inventory items: $e');
    }
  }
}
