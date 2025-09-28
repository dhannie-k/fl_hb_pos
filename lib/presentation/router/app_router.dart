import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hb_pos_inv/domain/entities/inventory.dart';
import 'package:hb_pos_inv/domain/repositories/product_service.dart';
import 'package:hb_pos_inv/presentation/pages/product_detail_page.dart';
import '../pages/main_layout.dart';
import '../pages/dashboard_page.dart';
import '../pages/inventory_page.dart';
import '../pages/add_product_page.dart';
import '../pages/edit_product_page.dart';
import '../pages/add_product_item_page.dart';
import '../pages/inventory_item_detail_page.dart';
import '../pages/inventory_item_movement_page.dart';
import '../pages/stock_movements_page.dart';
import 'route_names.dart';
import 'route_paths.dart';

class AppRouter {
  static final GoRouter _router = GoRouter(
    initialLocation: RoutePaths.dashboard,
    routes: [
      ShellRoute(
        builder: (context, state, child) => MainLayout(child: child),
        routes: [
          GoRoute(
            path: RoutePaths.dashboard,
            name: RouteNames.dashboard,
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const DashboardPage(),
            ),
          ),
          GoRoute(
            path: RoutePaths.inventory,
            name: RouteNames.inventory,
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const InventoryPage(),
            ),
          ),
          GoRoute(
            path: RoutePaths.productAdd,
            name: RouteNames.addProduct,
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: AddProductPage(
                preselectedCategoryId:
                    state.uri.queryParameters['categoryId'] != null
                    ? int.tryParse(state.uri.queryParameters['categoryId']!)
                    : null,
              ),
            ),
          ),
          GoRoute(
            path: RoutePaths.productEdit,
            builder: (context, state) => EditProductPage(
              productId: int.parse(state.pathParameters['id']!),
            ),
          ),
          GoRoute(
            path: RoutePaths.productAddItem,
            builder: (context, state) {
              final product = state.extra as ProductDisplayItem;
              return AddProductItemPage(
                productId: int.parse(state.pathParameters['id']!),
                productName: product.name,
              );
            },
          ),
          GoRoute(
            path: RoutePaths.inventoryItemDetail,
            name: 'inventoryItemDetail',
            builder: (context, state) {
              final itemId = int.parse(state.pathParameters['id']!);
              return InventoryItemDetailPage(itemId: itemId);
            },
          ),
          GoRoute(
            path: RoutePaths.productView,
            builder: (context, state) {
              final productId = int.parse(state.pathParameters['id']!);
              return ProductDetailPage(productId: productId);
            },
          ),
          GoRoute(
            path: RoutePaths.inventoryItemMovements,
            name: 'inventoryItemMovements',
            builder: (context, state) {
              final itemId = int.parse(state.pathParameters['id']!);
               final item = state.extra as InventoryItem;
              return InventoryItemMovementsPage(itemId: itemId, productName: item.productName, itemSpec: item.specification,);
            },
          ),
          GoRoute(
            path: RoutePaths.stockMovements,
            name: RouteNames.stockMovements,
            builder: (context, state) => const StockMovementsPage(),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) =>
        Scaffold(body: Center(child: Text('Page not found: ${state.error}'))),
  );

  static GoRouter get router => _router;

  /* static String getPageTitle(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();

    switch (location) {
      case RoutePaths.dashboard:
        return 'Dashboard';
      case RoutePaths.inventory:
        return 'Inventory';
      case RoutePaths.productAdd:
        return 'Add Product';
      default:
        return 'Dashboard';
    }
  } */
}
