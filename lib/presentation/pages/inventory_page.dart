import 'package:flutter/material.dart';
import '../widgets/inventory/category_tab.dart';
import '../widgets/inventory/product_tab.dart';
import '../widgets/inventory/stock_tab.dart';
import '../../core/constans/app_colors.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> with TickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inventory Management'),
        automaticallyImplyLeading: false,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.accent,
          tabs: [
            Tab(
              icon: Icon(Icons.warehouse),
              text: 'Stock',
            ),
            Tab(
              icon: Icon(Icons.inventory_2),
              text: 'Products',
            ),
            Tab(
              icon: Icon(Icons.category),
              text: 'Categories',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          StockTab(),
          ProductTab(),
          CategoryTab(),
        ],
      ),
    );
  }
}