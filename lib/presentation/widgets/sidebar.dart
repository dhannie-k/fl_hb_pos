import 'package:flutter/material.dart';

class Sidebar extends StatelessWidget {
  final bool isExpanded;
  final int selectedIndex;
  final VoidCallback onToggle;
  final ValueChanged<int> onIndexChanged;

  const Sidebar({
    super.key,
    required this.isExpanded,
    required this.selectedIndex,
    required this.onToggle,
    required this.onIndexChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      width: isExpanded ? 250 : 70,
      child: Container(
        color: Color(0xFF2D3748),
        child: Column(
          children: [
            Container(
              height: 135,
              padding: EdgeInsets.all(12),
              child: Column(
                children: [
                  IconButton(
                    icon: Icon(
                      isExpanded ? Icons.menu_open : Icons.menu,
                      color: Colors.white,
                    ),
                    onPressed: onToggle,
                  ),
                  Icon(Icons.store, color: Colors.white, size: 32),
                  if (isExpanded) ...[
                    Flexible( // Changed from Expanded to Flexible to prevent overflow
                      child: Text(
                        'HIDUP BARU',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16, // Reduced font size
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis, // Handle overflow gracefully
                      ),
                    ),
                  ],
                  SizedBox(width: 8), // Add some spacing
                  
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildNavItem(
                    icon: Icons.dashboard,
                    title: 'Dashboard',
                    index: 0,
                  ),
                  _buildNavItem(
                    icon: Icons.inventory,
                    title: 'Inventory',
                    index: 1,
                  ),
                  _buildNavItem(
                    icon: Icons.shopping_cart,
                    title: 'Sales Orders',
                    index: 2,
                  ),
                  _buildNavItem(
                    icon: Icons.people,
                    title: 'Customers',
                    index: 3,
                  ),
                  _buildNavItem(
                    icon: Icons.assessment,
                    title: 'Reports',
                    index: 4,
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(0),
              child: _buildNavItem(
                icon: Icons.settings,
                title: 'Settings',
                index: 5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String title,
    required int index,
  }) {
    final isSelected = selectedIndex == index;
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      child: Material(
        color: isSelected ? Colors.blue.withValues(alpha: 0.2) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: () => onIndexChanged(index),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            height: 48,
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isSelected ? Colors.blue[300] : Colors.white70,
                  size: 24,
                ),
                if (isExpanded) ...[
                  SizedBox(width: 16),
                  Flexible( // Changed from Expanded to Flexible
                    child: Text(
                      title,
                      style: TextStyle(
                        color: isSelected ? Colors.blue[300] : Colors.white70,
                        fontSize: 16,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                      overflow: TextOverflow.ellipsis, // Handle long text
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}