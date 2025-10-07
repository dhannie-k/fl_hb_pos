class RoutePaths {
  // Base
  static const String home = '/';
  static const String dashboard = '/dashboard';
  static const String inventory = '/inventory';

  // Product routes
  static const String productAdd = '/inventory/products/add';
  static const String productEdit = '/inventory/products/edit/:id';
  static const String productAddItem = '/inventory/products/:id/add-item';
  static const String productEditItem = '/products/items/edit';
  static const String productView = '/inventory/products/view/:id';

  // Inventory item routes
  static const String inventoryItemDetail = '/inventory/items/:id';
  static const String inventoryItemMovements = '/inventory/items/:id/movements';
  static const String stockMovements = '/inventory/stock-movements';

  // purchase
  static const String purchases = '/purchases';
  static const String purchaseItemDetails = '/purchases/purchase-item-details';
  static const String purchaseAdd = '/purchases/add';

  // supplier
  static const String suppliers = '/suppliers';

  // Other modules
  static const String sales = '/sales';
  static const String customers = '/customers';
  static const String reports = '/reports';
  static const String settings = '/settings';


}
