
abstract class InventoryEvent {
  const InventoryEvent();
}


class LoadInventory extends InventoryEvent {
  const LoadInventory();
}

class RefreshInventory extends InventoryEvent {
  const RefreshInventory();
}

// TODO() implement inventory event later if stock movement is implemented
class UpdateStock extends InventoryEvent { }
class DeleteStockItem extends InventoryEvent { }

