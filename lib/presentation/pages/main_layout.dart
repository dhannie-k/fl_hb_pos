import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hb_pos_inv/presentation/widgets/mobile_drawer.dart';
import '../router/route_paths.dart';
import '../widgets/sidebar.dart';
import '../widgets/responisve/bottom_navigation_bar.dart';

class MainLayout extends StatelessWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  bool _isBreadcrumbPage(String location) {
    return location == RoutePaths.dashboard || location == RoutePaths.inventory;
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 768;
    // Read the location ONCE here, in a stable context.
    final String location = GoRouterState.of(context).uri.path;

    if (isMobile) {
      if (_isBreadcrumbPage(location)) {
        final pageTitle =
            location == RoutePaths.dashboard ? "Dashboard" : "Inventory";

        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Row(
              children: [
                const Text('Hidup Baru'),
                const Icon(Icons.chevron_right, size: 16),
                const SizedBox(width: 4),
                Text(pageTitle),
              ],
            ),
            actions: [
              Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
            ],
          ),
          // *** CHANGED HERE ***
          // Pass the location string as a parameter.
          drawer: MobileDrawer(currentLocation: location),
          body: child,
          bottomNavigationBar: const MobileBottomNavBar(),
        );
      } else {
        return child;
      }
    } else {
      // Desktop/Tablet logic remains unchanged
      return Scaffold(
        body: Row(
          children: [
            const Sidebar(),
            Expanded(child: child),
          ],
        ),
      );
    }
  }
}
