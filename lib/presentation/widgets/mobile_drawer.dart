import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hb_pos_inv/presentation/bloc/auth/auth_bloc.dart';
import 'package:hb_pos_inv/presentation/bloc/auth/auth_event.dart';
import '../router/route_paths.dart';

class MobileDrawer extends StatelessWidget {
  // 1. Add a final variable to hold the location string.
  final String currentLocation;

  // 2. Add it to the constructor.
  const MobileDrawer({super.key, required this.currentLocation});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
            color: const Color(0xFF364A63),
            child: Row(
              children: [
                Image.asset('assets/images/logo4.png', width: 40),
                const SizedBox(width: 12),
                const Text(
                  'Hidup Baru',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          // Navigation List
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildMobileNavItem(
                  context,
                  icon: Icons.dashboard,
                  title: 'Dashboard',
                  path: RoutePaths.dashboard,
                  isActive: currentLocation == RoutePaths.dashboard,
                ),
                _buildMobileNavItem(
                  context,
                  icon: Icons.inventory,
                  title: 'Inventory',
                  path: RoutePaths.inventory,
                  isActive: currentLocation.startsWith('/inventory'),
                ),
                _buildMobileNavItem(
                context,
                icon: Icons.shopping_cart,
                title: 'Sales Orders',
                path: RoutePaths.sales,
                isActive: currentLocation.startsWith('/sales'),
              ),
              _buildMobileNavItem(
                context,
                icon: Icons.people,
                title: 'Customers',
                path: RoutePaths.customers,
                isActive: currentLocation.startsWith('/customers'),
              ),
              _buildMobileNavItem(
                context,
                icon: Icons.shopping_bag,
                title: 'Purchase',
                path: RoutePaths.purchases,
                isActive: currentLocation.startsWith('/purchases'),
              ),
              _buildMobileNavItem(
                context,
                icon: Icons.store,
                title: 'Suppliers',
                path: RoutePaths.suppliers,
                isActive: currentLocation.startsWith('/suppliers'),
              ),
              const Divider(color: Colors.white24, height: 32),              
                // Add your other nav items here...
                _buildMobileNavItem(
                context,
                icon: Icons.settings,
                title: 'Settings',
                path: RoutePaths.settings,
                isActive: currentLocation.startsWith('/settings'),
              ),
                _buildMobileNavItem(
                  context,
                  icon: Icons.logout_outlined,
                  title: 'Logout',
                  onTap: () {
                    context.read<AuthBloc>().add(AuthSignOutRequested());
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // A simple, performant ListTile for mobile navigation.
  Widget _buildMobileNavItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? path,
    bool isActive = false,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: isActive ? Theme.of(context).primaryColor : Colors.grey.shade700),
      title: Text(
        title,
        style: TextStyle(
          color: isActive ? Theme.of(context).primaryColor : Colors.grey.shade900,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onTap: onTap ?? () {
        if (path != null) {
          context.go(path);
          Navigator.pop(context); // Close drawer
        }
      },
      selected: isActive,
      selectedTileColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
    );
  }
}