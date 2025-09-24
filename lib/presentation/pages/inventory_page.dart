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

class _InventoryPageState extends State<InventoryPage>
    with TickerProviderStateMixin {
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
    return LayoutBuilder(
      builder: (context, constraints) {
        // Determine if we're on mobile
        final isMobile = constraints.maxWidth < 600;

        return Scaffold(
          appBar: AppBar(
            /* title: Text(
              'Inventory',
              style: TextStyle(fontSize: isMobile ? 18 : 20),
            ), */
            automaticallyImplyLeading: false,
            toolbarHeight: isMobile ? 24 : 36,
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(isMobile ? 36 : 40),
              child: TabBar(
                controller: _tabController,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textSecondary,
                indicatorColor: AppColors.accent,
                indicatorWeight: 2,
                labelStyle: TextStyle(
                  fontSize: isMobile ? 12 : 14,
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: TextStyle(fontSize: isMobile ? 12 : 14),
                tabs: [
                  Tab(
                    height: isMobile ? 56 : 40,
                    child: isMobile
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.warehouse, size: 18),
                              SizedBox(height: 2),
                              Text('Stock', style: TextStyle(fontSize: 11)),
                            ],
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.warehouse, size: 16),
                              SizedBox(width: 4),
                              Text('Stock'),
                            ],
                          ),
                  ),
                  Tab(
                    height: isMobile ? 56 : 40,
                    child: isMobile
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.inventory_2, size: 18),
                              SizedBox(height: 2),
                              Text('Products', style: TextStyle(fontSize: 11)),
                            ],
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.inventory_2, size: 16),
                              SizedBox(width: 4),
                              Text('Products'),
                            ],
                          ),
                  ),
                  Tab(
                    height: isMobile ? 56 : 40,
                    child: isMobile
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.category, size: 18),
                              SizedBox(height: 2),
                              Text(
                                'Categories',
                                style: TextStyle(fontSize: 11),
                              ),
                            ],
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
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
            children: [StockTab(), ProductTab(), CategoryTab()],
          ),
        );
      },
    );
  }
}
