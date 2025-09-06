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
        title: Text(
          'Inventory',
          style: TextStyle(fontSize: 20), // Reduced font size
        ),
        automaticallyImplyLeading: false,
        toolbarHeight: 48, // Reduced toolbar height
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(40), // Reduced tab bar height
          child: TabBar(
            controller: _tabController,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.accent,
            indicatorWeight: 2,
            labelStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w600), // Smaller font
            unselectedLabelStyle: TextStyle(fontSize: 14),
            tabs: [
              Tab(
                height: 40, // Reduced tab height
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.warehouse, size: 16), // Smaller icon
                    SizedBox(width: 4),
                    Text('Stock'),
                  ],
                ),
              ),
              Tab(
                height: 40,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.inventory_2, size: 16),
                    SizedBox(width: 4),
                    Text('Products'),
                  ],
                ),
              ),
              Tab(
                height: 40,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.category, size: 16),
                    SizedBox(width: 4),
                    Text('Categories'),
                  ],
                ),
              ),
            ],
          ),
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