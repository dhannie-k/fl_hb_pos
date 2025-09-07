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
        toolbarHeight: isMobile ? 56 : 64,
        actions: [
          if (isMobile)
            Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ),
        ],
      ),
      drawer: isMobile ? const Sidebar() : null,
      body: Row(
        children: [
          if (!isMobile) const Sidebar(),
          Expanded(child: child),
        ],
      ),
      bottomNavigationBar: isMobile ? const MobileBottomNavBar() : null,
    );
  }
}