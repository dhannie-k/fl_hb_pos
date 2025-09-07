import 'package:flutter/material.dart';
import '../router/app_router.dart';
import '../widgets/sidebar.dart';
import '../widgets/responisve/bottom_navigation_bar.dart';

class MainLayout extends StatelessWidget {
  final Widget child;
  
  const MainLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 768;
    final pageTitle = AppRouter.getPageTitle(context);
    
    if (isMobile) {
      // Mobile Layout: App bar + drawer + bottom nav
      return Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              const Text('HIDUP BARU'),
              const Icon(Icons.chevron_right, size: 16),
              const SizedBox(width: 4),
              Text(pageTitle),
            ],
          ),
          automaticallyImplyLeading: false,
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
      // Desktop/Tablet Layout: Just sidebar + content (no app bar)
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