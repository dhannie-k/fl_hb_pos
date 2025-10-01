import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hb_pos_inv/presentation/bloc/auth/auth_bloc.dart';
import 'package:hb_pos_inv/presentation/bloc/auth/auth_event.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../router/route_paths.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 768;
    final currentLocation = GoRouterState.of(context).uri.toString();
    
    if (isMobile) {
      // Mobile drawer
      return Drawer(
        child: _buildSidebarContent(context, currentLocation, isMobile),
      );
    } else {
      // Desktop/Tablet fixed sidebar
      return Container(
        width: 280,
        decoration: BoxDecoration(
          color: const Color(0xFF364A63), // Your blue background color
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(2, 0),
            ),
          ],
        ),
        child: _buildSidebarContent(context, currentLocation, isMobile),
      );
    }
  }

  Widget _buildSidebarContent(BuildContext context, String currentLocation, bool isMobile) {
    return Column(
      children: [
        // Header section
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isMobile ? Theme.of(context).primaryColor : const Color(0xFF364A63),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Store icon
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.store,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'HIDUP BARU',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        
        // Navigation items
        Expanded(
          child: Container(
            color: isMobile ? null : const Color(0xFF364A63),
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _buildNavItem(
                  context,
                  icon: Icons.dashboard,
                  title: 'Dashboard',
                  path: RoutePaths.dashboard,
                  isActive: currentLocation == RoutePaths.dashboard,
                  isMobile: isMobile,
                ),
                _buildNavItem(
                  context,
                  icon: Icons.inventory,
                  title: 'Inventory',
                  path: RoutePaths.inventory,
                  isActive: currentLocation.startsWith('/inventory'),
                  isMobile: isMobile,
                ),
                _buildNavItem(
                  context,
                  icon: Icons.shopping_cart,
                  title: 'Sales Orders',
                  path: RoutePaths.sales,
                  isActive: currentLocation.startsWith('/sales'),
                  isMobile: isMobile,
                ),
                _buildNavItem(
                  context,
                  icon: Icons.people,
                  title: 'Customers',
                  path: RoutePaths.customers,
                  isActive: currentLocation.startsWith('/customers'),
                  isMobile: isMobile,
                ),
                _buildNavItem(
                  context,
                  icon: Icons.shopping_bag,
                  title: 'Purchase',
                  path: RoutePaths.purchaseAdd,
                  isActive: currentLocation.startsWith('/Purchase'),
                  isMobile: isMobile,
                ),
                const Divider(color: Colors.white24, height: 32),
                _buildNavItem(
                  context,
                  icon: Icons.settings,
                  title: 'Settings',
                  path: RoutePaths.settings,
                  isActive: currentLocation.startsWith('/settings'),
                  isMobile: isMobile,
                ),
                SizedBox(height: 12,),
                IconButton(onPressed: () {
                  context.read<AuthBloc>().add(AuthSignOutRequested());
                  
                }, icon: Icon(Icons.logout_outlined))
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String path,
    required bool isActive,
    required bool isMobile,
  }) {
    final Color activeColor = isMobile ? Theme.of(context).primaryColor : Colors.white;
    final Color? inactiveColor = isMobile ? null : Colors.white70;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: isActive 
            ? (isMobile ? Theme.of(context).primaryColor.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.1))
            : null,
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isActive ? activeColor : inactiveColor,
          size: 20,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isActive ? activeColor : inactiveColor,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            fontSize: 14,
          ),
        ),
        onTap: () {
          context.go(path);
          if (isMobile) {
            Navigator.pop(context);
          }
        },
      ),
    );
  }
}