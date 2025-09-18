
abstract class InventoryEvent {
  const InventoryEvent();
}


class LoadInventory extends InventoryEvent {
  const LoadInventory();
}

class RefreshInventory extends InventoryEvent {
  const RefreshInventory();
}

class SearchInventory extends InventoryEvent {
  final String query;
  const SearchInventory(this.query);
}

class AdjustStock extends InventoryEvent {
  final int itemId;
  final int newQuantity;
  const AdjustStock(this.itemId, this.newQuantity);

  List<Object?> get props => [itemId, newQuantity];
}

class LoadInventoryItem extends InventoryEvent {
  final int itemId;
  const LoadInventoryItem(this.itemId);

  List<Object?> get props => [itemId];
}




// TODO() implement inventory event later if stock movement is implemented
class UpdateStock extends InventoryEvent { }
class DeleteStockItem extends InventoryEvent { }

