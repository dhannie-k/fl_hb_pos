import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../router/route_paths.dart';

class MobileBottomNavBar extends StatelessWidget {
  const MobileBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final currentLocation = GoRouterState.of(context).uri.toString(); // Fixed
    
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: _getCurrentIndex(currentLocation),
      onTap: (index) => _onItemTapped(context, index),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.inventory),
          label: 'Inventory',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.point_of_sale),
          label: 'Sales',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_bag),
          label: 'Purchase',
        ),
      ],
    );
  }

  int _getCurrentIndex(String location) {
    if (location.startsWith('/inventory')) return 1;
    if (location.startsWith('/sales')) return 2;
    if (location.startsWith('/purchase')) return 3;
    return 0; // dashboard
  }

  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(RoutePaths.dashboard);
        break;
      case 1:
        context.go(RoutePaths.inventory);
        break;
      case 2:
        context.go(RoutePaths.sales);
        break;
      case 3:
        context.go(RoutePaths.purchaseAdd);
        break;
    }
  }
}