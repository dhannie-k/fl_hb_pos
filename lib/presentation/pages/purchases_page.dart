import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hb_pos_inv/presentation/bloc/purchase/purchase_state.dart';
// import 'package:hb_pos_inv/presentation/router/route_names.dart'; // No longer needed for navigation here
import 'package:intl/intl.dart';
import '../../domain/entities/purchase.dart';
import '../bloc/purchase/purchase_bloc.dart';
import '../bloc/purchase/purchase_event.dart';
import '../router/route_paths.dart';

class PurchasesPage extends StatefulWidget {
  const PurchasesPage({super.key});

  @override
  State<PurchasesPage> createState() => _PurchasesPageState();
}

class _PurchasesPageState extends State<PurchasesPage> {
  @override
  void initState() {
    super.initState();
    context.read<PurchaseBloc>().add(LoadPurchases());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: () => context.go('/dashboard'), icon: Icon(Icons.arrow_back)),
        title: const Text('Purchases'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Add New Purchase',
            onPressed: () {
              context.push(RoutePaths.purchaseAdd).then((_) {
                if (context.mounted) {
                  context.read<PurchaseBloc>().add(LoadPurchases());
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () {
              context.read<PurchaseBloc>().add(LoadPurchases());
            },
          ),
        ],
      ),
      body: BlocBuilder<PurchaseBloc, PurchaseState>(
        builder: (context, state) {
          if (state is PurchaseLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is PurchaseError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: ${state.message}',
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<PurchaseBloc>().add(LoadPurchases()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          if (state is PurchasesLoaded) {
            if (state.purchases.isEmpty) {
              return const Center(child: Text('No purchases found.'));
            }
            return LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 600) {
                  return _buildMobileLayout(state.purchases);
                } else {
                  return _buildDesktopLayout(state.purchases);
                }                
              },
            );
          }
          return const Center(
            child: Text('Tap the + button to add a purchase.'),
          );
        },
      ),
    );
  }

  Future<void> _showCancelPurchaseConfirmationDialog(
    BuildContext context,
    Purchase purchase,
  ) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('confirm cancel'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to cancel purchase?'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('No'),
            ),
            TextButton(
              onPressed: () {
                context.read<PurchaseBloc>().add(CancelPurchase(purchase.id!));
              },
              child: Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  // --- Mobile Layout ---
  Widget _buildMobileLayout(List<Purchase> purchases) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return ListView.builder(
      itemCount: purchases.length,
      itemBuilder: (context, index) {
        final purchase = purchases[index];
        return Card(
          margin: const EdgeInsets.all(8),
          child: ListTile(
            title: Text("PO: ${purchase.poNumber ?? ''}"),
            subtitle: Text(
              "Supplier: ${purchase.supplierName ?? '-'}\n"
              "Items: ${purchase.items.length} • \n"
              "${purchase.items[0].product}..."
              "Total: ${currencyFormat.format(purchase.totalAmount)}",
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.list_alt),
                  tooltip: "View Items",
                  onPressed: () {
                    // CORRECT NAVIGATION CALL
                    context.push(
                      RoutePaths.purchaseItemDetails,
                      extra: purchase,
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.cancel, color: Colors.red),
                  tooltip: "Cancel Purchase",
                  onPressed: () {
                    // Add confirmation dialog
                    _showCancelPurchaseConfirmationDialog(context, purchase);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- UPDATED Desktop/Tablet Layout ---
  Widget _buildDesktopLayout(List<Purchase> purchases) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Date')),
          DataColumn(label: Text('Supplier')),
          DataColumn(label: Text('PO Number')),
          DataColumn(label: Text('Items')),
          DataColumn(label: Text('Total Amount'), numeric: true),
          DataColumn(label: Text('Actions')), // <-- NEW COLUMN
        ],
        rows: purchases.map((purchase) {
          return DataRow(
            cells: [
              DataCell(Text(DateFormat.yMMMd().format(purchase.purchaseDate))),
              DataCell(Text(purchase.supplierName ?? 'Unknown')),
              DataCell(Text(purchase.poNumber ?? 'N/A')),
              DataCell(Text('${purchase.items.length} items \n ${purchase.items[0].product}...')),
              DataCell(Text(currencyFormat.format(purchase.totalAmount))),
              // --- NEW ACTIONS CELL ---
              DataCell(
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.list_alt),
                      color: Theme.of(context).primaryColor,
                      tooltip: 'View Items',
                      onPressed: () {
                        // Navigate to details page instead of showing dialog
                        context.push(
                          RoutePaths.purchaseItemDetails,
                          extra: purchase,
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.cancel),
                      color: Colors.red,
                      tooltip: 'Cancel Purchase',
                      onPressed: () {
                        // Add confirmation dialog if desired
                        /* context.read<PurchaseBloc>().add(
                          CancelPurchase(purchase.id!),
                        ); */
                        _showCancelPurchaseConfirmationDialog(context, purchase);
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
