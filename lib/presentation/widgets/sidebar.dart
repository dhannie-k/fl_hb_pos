import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../router/route_paths.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 768;
    final currentLocation = GoRouterState.of(context).uri.toString(); // Fixed
    
    return Container(
      width: isMobile ? 280 : 250,
      child: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: const Center(
                child: Text(
                  'HIDUP BARU',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero, // Add this to prevent extra padding
                children: [
                  _buildNavItem(
                    context,
                    icon: Icons.dashboard,
                    title: 'Dashboard',
                    path: RoutePaths.dashboard,
                    isActive: currentLocation == RoutePaths.dashboard,
                  ),
                  _buildNavItem(
                    context,
                    icon: Icons.inventory,
                    title: 'Inventory',
                    path: RoutePaths.inventory,
                    isActive: currentLocation.startsWith('/inventory'),
                  ),
                  // Add other nav items
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String path,
    required bool isActive,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: isActive ? Theme.of(context).primaryColor.withValues(alpha: 0.1) : null,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16), // Fixed padding
        leading: Icon(
          icon,
          color: isActive ? Theme.of(context).primaryColor : null,
        ),
        title: Text( // Removed Flexible wrapper - ListTile handles overflow
          title,
          style: TextStyle(
            color: isActive ? Theme.of(context).primaryColor : null,
            fontWeight: isActive ? FontWeight.w600 : null,
          ),
        ),
        onTap: () {
          context.go(path);
          if (MediaQuery.of(context).size.width < 768) {
            Navigator.pop(context);
          }
        },
      ),
    );
  }
}