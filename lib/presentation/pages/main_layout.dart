import 'package:flutter/material.dart';
import '../widgets/sidebar.dart';
import 'dashboard_page.dart';
import 'inventory_page.dart';
import 'sales_order_page.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  MainLayoutState createState() => MainLayoutState();
}

class MainLayoutState extends State<MainLayout> {
  bool isExpanded = true;
  int selectedIndex = 0;

  final List<Widget> pages = [
    DashboardPage(),
    InventoryPage(),
    SalesOrderPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Sidebar(
            isExpanded: isExpanded,
            selectedIndex: selectedIndex,
            onToggle: () => setState(() => isExpanded = !isExpanded),
            onIndexChanged: (index) => setState(() => selectedIndex = index),
          ),
          Expanded(
            child: pages[selectedIndex],
          ),
        ],
      ),
    );
  }
}