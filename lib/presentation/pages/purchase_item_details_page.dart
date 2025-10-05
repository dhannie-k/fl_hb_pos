// purchase_item_details_page.dart
import 'package:flutter/material.dart';
import 'package:hb_pos_inv/domain/entities/purchase.dart';

class PurchaseItemDetailsPage extends StatelessWidget {
  final Purchase purchase;

  const PurchaseItemDetailsPage({super.key, required this.purchase});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Purchase ${purchase.poNumber ?? ''}")),
      body: ListView.builder(
        itemCount: purchase.items.length,
        itemBuilder: (context, index) {
          final item = purchase.items[index];
          return Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              title: Text(item.product),
              subtitle: Text("Spec: ${item.specification} ${item.itemColor}"),
              trailing: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text("Qty: ${item.quantityOrdered}"),
                  Text("Unit Cost: ${item.unitCost}"),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
