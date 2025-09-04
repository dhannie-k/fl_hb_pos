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

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
      ),
      body: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          if (state is DashboardLoading) {
            return Center(child: CircularProgressIndicator());
          }
          
          if (state is DashboardError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 64, color: Colors.red[300]),
                  SizedBox(height: 16),
                  Text('Error: ${state.message}'),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<DashboardBloc>().add(LoadDashboard());
                    },
                    child: Text('Retry'),
                  ),
                ],
              ),
            );
          }
          
          if (state is DashboardLoaded) {
            return _buildDashboardContent(context, state.stats);
          }
          
          return SizedBox();
        },
      ),
    );
  }

  Widget _buildDashboardContent(BuildContext context, DashboardStats stats) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats Cards Row
          Row(
            children: [
              Expanded(
                child: DashboardCard(
                  title: 'Sales',
                  value: '\$${NumberFormat('#,##0.00').format(stats.totalSales)}',
                  icon: Icons.trending_up,
                  color: Colors.green,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: DashboardCard(
                  title: 'New Orders',
                  value: '${stats.newOrders}',
                  icon: Icons.shopping_cart,
                  color: Colors.blue,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: DashboardCard(
                  title: 'Pending Orders',
                  value: '${stats.pendingOrders}',
                  icon: Icons.pending,
                  color: Colors.orange,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: DashboardCard(
                  title: 'Inventory Alert',
                  value: '${stats.lowStockItems.length}',
                  icon: Icons.warning,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          
          SizedBox(height: 24),
          
          // Content Cards Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TopItemsCard(items: stats.topItems),
              ),
              SizedBox(width: 16),
              Expanded(
                child: LowStockCard(items: stats.lowStockItems),
              ),
            ],
          ),
          
          SizedBox(height: 24),
          
          // Additional Cards Row
          Row(
            children: [
              Expanded(
                child: Card(
                  elevation: 2,
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sales Report',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 16),
                        SizedBox(
                          height: 200,
                          child: Center(
                            child: Text(
                              'Chart placeholder\n(integrate with fl_chart)',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Card(
                  elevation: 2,
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Due Payments',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
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
                                  color: Colors.red[600],
                                ),
                              ),
                              Text('Overdue Payments'),
                              SizedBox(height: 8),
                              Text(
                                '\$${NumberFormat('#,##0.00').format(stats.duePaymentsAmount)}',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text('Total Amount'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
