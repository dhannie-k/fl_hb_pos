import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_event.dart';
import '../router/route_paths.dart';

class Sidebar extends StatefulWidget {
  const Sidebar({super.key});

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  bool _isCollapsed = false;

  @override
  Widget build(BuildContext context) {
    // No more isMobile check needed here. This widget is desktop-only.
    final currentLocation = GoRouterState.of(context).uri.toString();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOutCubic,
      width: _isCollapsed ? 90 : 280,
      decoration: BoxDecoration(
        color: const Color(0xFF364A63),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          _buildHeader(),
          const Divider(color: Colors.white24, height: 1),
          // Navigation items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              children: [
                _buildNavItem(
              context: context,
              icon: Icons.dashboard,
              title: 'Dashboard',
              path: RoutePaths.dashboard,
              isActive: currentLocation == RoutePaths.dashboard,
            ),
            _buildNavItem(
              context: context,
              icon: Icons.inventory,
              title: 'Inventory',
              path: RoutePaths.inventory,
              isActive: currentLocation.startsWith('/inventory'),
            ),
            _buildNavItem(
              context: context,
              icon: Icons.shopping_cart,
              title: 'Sales Orders',
              path: RoutePaths.sales,
              isActive: currentLocation.startsWith('/sales'),
            ),
            _buildNavItem(
              context: context,
              icon: Icons.people,
              title: 'Customers',
              path: RoutePaths.customers,
              isActive: currentLocation.startsWith('/customers'),
            ),
            _buildNavItem(
              context: context,
              icon: Icons.shopping_bag,
              title: 'Purchase',
              path: RoutePaths.purchases,
              isActive: currentLocation.startsWith('/purchases'),
            ),
            _buildNavItem(
              context: context,
              icon: Icons.store,
              title: 'Suppliers',
              path: RoutePaths.suppliers,
              isActive: currentLocation.startsWith('/suppliers'),
            ),
            const Divider(color: Colors.white24, height: 32),
            _buildNavItem(
              context: context,
              icon: Icons.settings,
              title: 'Settings',
              path: RoutePaths.settings,
              isActive: currentLocation.startsWith('/settings'),
            ),
            const SizedBox(height: 6),
            // Logout button
            _isCollapsed
                ? IconButton(
                    onPressed: () =>
                        context.read<AuthBloc>().add(AuthSignOutRequested()),
                    icon: const Icon(
                      Icons.logout_outlined,
                      color: Colors.white70,
                    ),
                  )
                : _buildNavItem(
                    context: context,
                    icon: Icons.logout_outlined,
                    title: 'Logout',
                    path: '', // No path needed, handled by onTap
                    onTap: () =>
                        context.read<AuthBloc>().add(AuthSignOutRequested()),
                    isActive: false,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ** HEADER FIX: Use AnimatedSwitcher for clean layout swapping **
  Widget _buildHeader() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
      child: _isCollapsed
          // COLLAPSED: A Column to place the icon underneath
          ? Container(
              key: const ValueKey('collapsed'),
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                children: [
                  Image.asset('assets/images/logo4.png', width: 40),
                  const SizedBox(height: 12),
                  IconButton(
                    onPressed: () => setState(() => _isCollapsed = false),
                    icon: const Icon(Icons.chevron_right, color: Colors.white70),
                  ),
                ],
              ),
            )
          // EXPANDED: A Row for the full header
          : Container(
              key: const ValueKey('expanded'),
              padding: const EdgeInsets.fromLTRB(16, 20, 8, 20),
              child: Row(
                children: [
                  Image.asset('images/logo4.png', width: 40),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'HIDUP BARU',
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
                      maxLines: 1,
                    ),
                  ),
                  IconButton(
                    onPressed: () => setState(() => _isCollapsed = true),
                    icon: const Icon(Icons.chevron_left, color: Colors.white70),
                  ),
                ],
              ),
            ),
    );
  }

  // ** NAV ITEM: Simplified for desktop only **
  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    String? path,
    required bool isActive,
    VoidCallback? onTap,
  }) {
    final color = isActive ? Colors.white : Colors.white70;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: isActive ? Colors.white.withValues(alpha:0.15) : null,
      ),
      child: Tooltip(
        message: _isCollapsed ? title : '',
        child: InkWell(
          onTap: onTap ?? () => context.go(path!),
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            height: 48,
            child: Row(
              mainAxisAlignment: _isCollapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
              children: [
                SizedBox(width: _isCollapsed ? 0 : 16),
                Icon(icon, color: color, size: 22),
                if (!_isCollapsed) ...[
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        color: color,
                        fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                      ),
                      maxLines: 1,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}


