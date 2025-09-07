import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../pages/main_layout.dart';
import '../pages/dashboard_page.dart';
import '../pages/inventory_page.dart';
import 'route_names.dart';
import 'route_paths.dart';

class AppRouter {
  static final GoRouter _router = GoRouter(
    initialLocation: RoutePaths.dashboard,
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return MainLayout(child: child);
        },
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
          // Add other routes as needed
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.error}'),
      ),
    ),
  );

  static GoRouter get router => _router;

  static String getPageTitle(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString(); // Fixed: use GoRouter.of(context)
    
    switch (location) {
      case RoutePaths.dashboard:
        return 'Dashboard';
      case RoutePaths.inventory:
        return 'Inventory';
      default:
        return 'Dashboard';
    }
  }
}