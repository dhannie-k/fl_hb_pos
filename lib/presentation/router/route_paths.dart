class RoutePaths {
  // Base
  static const String home = '/';
  static const String dashboard = '/dashboard';
  static const String inventory = '/inventory';

  // Product routes
  static const String productAdd = '/inventory/products/add';
  static const String productEdit = '/inventory/products/edit/:id';
  static const String productAddItem = '/inventory/products/:id/add-item';
  static const String productView = '/inventory/products/view/:id';

  // Inventory item routes
  static const String inventoryItemDetail = '/inventory/items/:id';
  static const String inventoryItemMovements = '/inventory/items/:id/movements';

  // Other modules
  static const String sales = '/sales';
  static const String customers = '/customers';
  static const String reports = '/reports';
  static const String settings = '/settings';
}
