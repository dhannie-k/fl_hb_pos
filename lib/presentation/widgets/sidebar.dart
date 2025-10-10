import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hb_pos_inv/presentation/bloc/auth/auth_bloc.dart';
import 'package:hb_pos_inv/presentation/bloc/auth/auth_event.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../router/route_paths.dart';

// 1. Converted to a StatefulWidget
class Sidebar extends StatefulWidget {
  const Sidebar({super.key});

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  bool _isCollapsed = false;

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 768;
    final currentLocation = GoRouterState.of(context).uri.toString();

    if (isMobile) {
      return Drawer(
        child: _buildSidebarContent(context, currentLocation, isMobile, false),
      );
    } else {
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
        child: _buildSidebarContent(context, currentLocation, isMobile, _isCollapsed),
      );
    }
  }

  // This parent widget now just provides structure
  Widget _buildSidebarContent(
    BuildContext context,
    String currentLocation,
    bool isMobile,
    bool isCollapsed,
  ) {
    return Column(
      children: [
        // Pass the state down to the new, rebuilt header
        _buildHeader(isMobile, isCollapsed),

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
                isCollapsed: isCollapsed,
              ),
              _buildNavItem(
                context: context,
                icon: Icons.inventory,
                title: 'Inventory',
                path: RoutePaths.inventory,
                isActive: currentLocation.startsWith('/inventory'),
                isCollapsed: isCollapsed,
              ),
              _buildNavItem(
                context: context,
                icon: Icons.shopping_cart,
                title: 'Sales Orders',
                path: RoutePaths.sales,
                isActive: currentLocation.startsWith('/sales'),
                //isMobile: isMobile,
                isCollapsed: isCollapsed, // Pass state
              ),
              _buildNavItem(
                context: context,
                icon: Icons.people,
                title: 'Customers',
                path: RoutePaths.customers,
                isActive: currentLocation.startsWith('/customers'),
                //isMobile: isMobile,
                isCollapsed: isCollapsed, // Pass state
              ),
              _buildNavItem(
                context: context,
                icon: Icons.shopping_bag,
                title: 'Purchase',
                path: RoutePaths.purchases,
                isActive: currentLocation.startsWith('/purchases'),
                //isMobile: isMobile,
                isCollapsed: isCollapsed, // Pass state
              ),
              _buildNavItem(
                context: context,
                icon: Icons.store,
                title: 'Suppliers',
                path: RoutePaths.suppliers,
                isActive: currentLocation.startsWith('/suppliers'),
                //isMobile: isMobile,
                isCollapsed: isCollapsed, // Pass state
              ),
              const Divider(color: Colors.white24, height: 32),
              _buildNavItem(
                context: context,
                icon: Icons.settings,
                title: 'Settings',
                path: RoutePaths.settings,
                isActive: currentLocation.startsWith('/settings'),
                //isMobile: isMobile,
                isCollapsed: isCollapsed, // Pass state
              ),
              const SizedBox(height: 6),
              // Logout button
              isCollapsed
                  ? IconButton(
                      onPressed: () => context.read<AuthBloc>().add(AuthSignOutRequested()),
                      icon: const Icon(Icons.logout_outlined, color: Colors.white70),
                    )
                  : _buildNavItem(
                      context: context,
                      icon: Icons.logout_outlined,
                      title: 'Logout',
                      path: '', // No path needed, handled by onTap
                      onTap: () => context.read<AuthBloc>().add(AuthSignOutRequested()),
                      isActive: false,
                      //isMobile: isMobile,
                      isCollapsed: isCollapsed,
                    ),
              // ... add all your other _buildNavItem calls here
            ],
          ),
        ),
      ],
    );
  }

  // === HEADER: REBUILT WITH STACK FOR FLAWLESS ANIMATION ===
  Widget _buildHeader(bool isMobile, bool isCollapsed) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      // Header logo section
      Container(
        height: 80,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Stack(
          children: [
            // Logo
            AnimatedAlign(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOutCubic,
              alignment: isCollapsed ? Alignment.center : Alignment.centerLeft,
              child: Image.asset('images/logo4.png', width: 40),
            ),

            // Title text
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOutCubic,
              left: isCollapsed ? 90 : 60,
              top: 0,
              bottom: 0,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: isCollapsed ? 0.0 : 1.0,
                child: IgnorePointer(
                  ignoring: isCollapsed,
                  child: Center(
                    child: Text(
                      'Hidup Baru',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      // Chevron toggle section
      if (!isMobile)
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOutCubic,
          height: isCollapsed ? 40 : 0, // visible only when collapsed
          child: isCollapsed
              ? IconButton(
                  onPressed: () {
                    setState(() {
                      _isCollapsed = !_isCollapsed;
                    });
                  },
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder: (child, animation) =>
                        ScaleTransition(scale: animation, child: child),
                    child: Icon(
                      isCollapsed ? Icons.chevron_right : Icons.chevron_left,
                      key: ValueKey<bool>(isCollapsed),
                      color: Colors.white70,
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),

      // Chevron for expanded state (stays aligned right)
      if (!isMobile && !isCollapsed)
        Align(
          alignment: Alignment.centerRight,
          child: IconButton(
            onPressed: () {
              setState(() {
                _isCollapsed = !_isCollapsed;
              });
            },
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, animation) =>
                  ScaleTransition(scale: animation, child: child),
              child: Icon(
                isCollapsed ? Icons.chevron_right : Icons.chevron_left,
                key: ValueKey<bool>(isCollapsed),
                color: Colors.white70,
              ),
            ),
          ),
        ),
    ],
  );
}

  // === NAV ITEM: REBUILT WITH CLIPRECT FOR ANIMATION-SAFE LAYOUT ===
  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String path,
    required bool isActive,
    required bool isCollapsed,
    VoidCallback? onTap,
  }) {
    final Color color = isActive ? Colors.white : Colors.white70;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: isActive ? Colors.white.withValues(alpha: 0.15) : null,
      ),
      child: Tooltip(
        message: isCollapsed ? title : '',
        child: InkWell(
          onTap: onTap ?? () => context.go(path),
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            height: 48,
            child: Row(
              mainAxisAlignment: isCollapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
              children: [
                // Use padding to control icon position instead of changing the whole Row alignment
                SizedBox(width: isCollapsed ? 0 : 16),
                Icon(icon, color: color, size: 22),
                const SizedBox(width: 16),
                // 1. Expanded, ClipRect, and AnimatedOpacity work together
                if (!isCollapsed)
                  Expanded(
                    child: ClipRect( // The key to preventing overflow during animation
                      child: AnimatedOpacity(
                        opacity: isCollapsed ? 0.0 : 1.0,
                        duration: const Duration(milliseconds: 200),
                        child: Text(
                          title,
                          style: TextStyle(
                            color: color,
                            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.clip, // Must be clip
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
