import 'package:flutter/material.dart';
import '../../../core/constans/app_colors.dart';

// Product Tab Widget
class ProductTab extends StatelessWidget {
  const ProductTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 64,
            color: AppColors.accent,
          ),
          SizedBox(height: 16),
          Text(
            'Product Management',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Coming Soon - Add and manage your products',
            style: TextStyle(
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Product management will be implemented next!')),
              );
            },
            icon: Icon(Icons.add),
            label: Text('Add Product'),
          ),
        ],
      ),
    );
  }
}