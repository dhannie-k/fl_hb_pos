import 'package:flutter/material.dart';
import '../../../core/constans/app_colors.dart';

class StockTab extends StatelessWidget {
  const StockTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.warehouse_outlined,
            size: 64,
            color: AppColors.warning,
          ),
          SizedBox(height: 16),
          Text(
            'Stock Management',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Coming Soon - Monitor and adjust stock levels',
            style: TextStyle(
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Stock management will be implemented later!')),
              );
            },
            icon: Icon(Icons.inventory),
            label: Text('Manage Stock'),
          ),
        ],
      ),
    );
  }
}