import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/dashboard/dashboard_bloc.dart';
import '../bloc/dashboard/dashboard_event.dart';
import '../bloc/dashboard/dashboard_state.dart';
import '../../domain/entities/dasboard_stats.dart';
import '../widgets/dashboard_card.dart';
import '../widgets/top_items_card.dart';
import '../widgets/low_stock_card.dart';
import '../../core/constans/app_colors.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 768;
    return Scaffold(
      appBar: !isMobile
          ? AppBar(
              title: Text('Dashboard'),
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  icon: Icon(Icons.refresh),
                  onPressed: () {
                    context.read<DashboardBloc>().add(RefreshDashboard());
                  },
                ),
                SizedBox(width: 16),
              ],
            )
          : null,
      body: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          if (state is DashboardLoading) {
            return _buildLoadingState();
          }

          if (state is DashboardError) {
            return _buildErrorState(context, state.message);
          }

          if (state is DashboardLoaded) {
            return _buildDashboardContent(context, state.stats);
          }

          // Initial state
          return _buildInitialState(context);
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primary),
          SizedBox(height: 16),
          Text(
            'Loading dashboard data...',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: AppColors.error),
          SizedBox(height: 16),
          Text(
            'Oops! Something went wrong',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              context.read<DashboardBloc>().add(LoadDashboard());
            },
            icon: Icon(Icons.refresh),
            label: Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInitialState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.dashboard, size: 64, color: AppColors.textMuted),
          SizedBox(height: 16),
          Text(
            'Welcome to Hidup Baru POS',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Loading your dashboard...',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardContent(BuildContext context, DashboardStats stats) {
    final bool isMobile = MediaQuery.of(context).size.width < 768;
    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Check if we have any data at all
          if (_hasAnyData(stats)) ...[
            // Stats Cards Row
            _buildStatsGrid(context, stats, isMobile: isMobile),
            SizedBox(height: 24),
            // Content Cards Row
            _buildContentCards(stats, isMobile: isMobile),
            SizedBox(height: 24),
            // Additional Cards Row
            _buildAdditionalCards(stats, isMobile: isMobile),
          ] else ...[
            _buildEmptyDataState(context),
          ],
        ],
      ),
    );
  }

  bool _hasAnyData(DashboardStats stats) {
    return stats.totalSales > 0 ||
        stats.newOrders > 0 ||
        stats.pendingOrders > 0 ||
        stats.topItems.isNotEmpty ||
        stats.lowStockItems.isNotEmpty;
  }

  Widget _buildEmptyDataState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(48),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  size: 80,
                  color: AppColors.accent,
                ),
                SizedBox(height: 24),
                Text(
                  'Your Store is Ready!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'Database connected successfully.\nStart by adding products to your inventory.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 32),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Inventory page coming soon!'),
                          ),
                        );
                      },
                      icon: Icon(Icons.add),
                      label: Text('Add Products'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    SizedBox(width: 16),
                    OutlinedButton.icon(
                      onPressed: () {
                        context.read<DashboardBloc>().add(RefreshDashboard());
                      },
                      icon: Icon(Icons.refresh),
                      label: Text('Refresh'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Replace the old _buildStatsCards method with this new one
  Widget _buildStatsGrid(
    BuildContext context,
    DashboardStats stats, {
    bool isMobile = false,
  }) {
    // Determine the number of columns and the aspect ratio based on screen size
    final int crossAxisCount = isMobile ? 2 : 4;
    final double childAspectRatio = isMobile ? 1.4 : 1.2;

    return GridView.count(
      crossAxisCount: crossAxisCount,
      childAspectRatio: childAspectRatio,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      shrinkWrap: true, // Important to use inside a SingleChildScrollView
      physics:
          const NeverScrollableScrollPhysics(), // Disable GridView's own scrolling
      children: [
        DashboardCard(
          title: 'Sales This Month',
          value: '\$${NumberFormat('#,##0.00').format(stats.totalSales)}',
          icon: Icons.trending_up,
          color: AppColors.success,
        ),
        DashboardCard(
          title: 'New Orders',
          value: '${stats.newOrders}',
          icon: Icons.shopping_cart,
          color: AppColors.secondary,
        ),
        DashboardCard(
          title: 'Pending Orders',
          value: '${stats.pendingOrders}',
          icon: Icons.pending,
          color: AppColors.warning,
        ),
        DashboardCard(
          title: 'Inventory Alert',
          value: '${stats.lowStockItems.length}',
          icon: Icons.warning,
          color: AppColors.error,
        ),
      ],
    );
  }

  Widget _buildContentCards(DashboardStats stats, {bool isMobile = false}) {
    final cardChildren = [
      stats.topItems.isNotEmpty
          ? TopItemsCard(items: stats.topItems)
          : _buildEmptyCard(
              'Top Selling Items',
              'No sales data yet',
              Icons.trending_up,
            ),
      SizedBox(width: isMobile ? 0 : 16, height: isMobile ? 16 : 0),
      stats.lowStockItems.isNotEmpty
          ? LowStockCard(items: stats.lowStockItems)
          : _buildEmptyCard(
              'Low Stock Alert',
              'All items in stock',
              Icons.check_circle,
              color: AppColors.success,
            ),
    ];

    return isMobile
        ? Column(mainAxisSize: MainAxisSize.min, children: cardChildren)
        : Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: cardChildren[0]),
          cardChildren[1],
          Expanded(child: cardChildren[2]),
        ]);
  }
}

Widget _buildAdditionalCards(DashboardStats stats, {bool isMobile = false}) {
  final cardChildren = [
    Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sales Report',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.bar_chart,
                      size: 48,
                      color: AppColors.textMuted,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Chart coming soon',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
    SizedBox(width: isMobile ? 0 : 16, height: isMobile ? 16 : 0),
    Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Due Payments',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${stats.duePaymentsCount}',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: stats.duePaymentsCount > 0
                          ? AppColors.error
                          : AppColors.success,
                    ),
                  ),
                  Text(
                    stats.duePaymentsCount > 0
                        ? 'Overdue Payments'
                        : 'No Overdue Payments',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  if (stats.duePaymentsAmount > 0) ...[
                    SizedBox(height: 8),
                    Text(
                      '\$${NumberFormat('#,##0.00').format(stats.duePaymentsAmount)}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.error,
                      ),
                    ),
                    Text(
                      'Total Amount',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  ];

  return isMobile
      ? Column(mainAxisSize: MainAxisSize.min, children: cardChildren)
      : Row(children: [
        Expanded(child: cardChildren[0]),
        cardChildren[1], // SizedBox
        Expanded(child: cardChildren[2]),
      ]);
}

Widget _buildEmptyCard(
  String title,
  String message,
  IconData icon, {
  Color? color,
}) {
  return Card(
    elevation: 2,
    child: Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 48, color: color ?? AppColors.textMuted),
                  SizedBox(height: 12),
                  Text(
                    message,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
