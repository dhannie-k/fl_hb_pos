import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
    final String location = GoRouterState.of(context).uri.path;

    if (isMobile) {
      if (_isBreadcrumbPage(location)) {
        // Dashboard & Inventory get breadcrumb + drawer + bottom nav
        final pageTitle =
            location == RoutePaths.dashboard ? "Dashboard" : "Inventory";

        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Row(
              children: [
                const Text('HIDUP BARU'),
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
          drawer: const Sidebar(),
          body: child,
          bottomNavigationBar: const MobileBottomNavBar(),
        );
      } else {
        // All other pages → just return the page itself
        return child;
      }
    } else {
      // Desktop/Tablet always show sidebar
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
