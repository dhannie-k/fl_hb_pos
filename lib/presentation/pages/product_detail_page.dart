import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hb_pos_inv/domain/entities/inventory.dart';
import 'package:hb_pos_inv/domain/entities/product.dart';
import 'package:hb_pos_inv/domain/repositories/product_service.dart';
import 'package:hb_pos_inv/presentation/router/route_paths.dart';
import '../bloc/product/product_bloc.dart';
import '../bloc/product/product_state.dart';
import '../bloc/product/product_event.dart';
import '../widgets/common/loading_widget.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;

class ProductDetailPage extends StatefulWidget {
  final int productId;

  const ProductDetailPage({super.key, required this.productId});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  @override
  void initState() {
    super.initState();
    context.read<ProductBloc>().add(LoadProductDisplayDetail(widget.productId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),        
      ),
      body: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {
          if (state is ProductLoading) {
            return const LoadingWidget();
          } else if (state is ProductDisplayDetailLoaded) {
            final product = state.product;
            final items = state.product.items;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product header card
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (product.imageUrl != null &&
                              product.imageUrl!.isNotEmpty)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                product.imageUrl!,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            )
                          else
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.image_not_supported),
                            ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.name,
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                if (product.brand != null)
                                  Text(
                                    product.brand!,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium,
                                  ),
                                if (product.description != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(product.description!),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  Text(
                    'Product Items',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),

                  // Items list
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: items.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return ListTile(
                        title: Text(
                          '${item.specification} ${item.color ?? ''}',
                        ),
                        subtitle: Text('Unit: ${item.unitOfMeasure}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              item.unitPrice != null
                                  ? 'Rp${item.unitPrice!.toStringAsFixed(2)}'
                                  : '-',
                            ),
                            PopupMenuButton<String>(
                              onSelected: (value) {
                                switch (value) {
                                  case 'edit':
                                    context.push(
                                      RoutePaths.productEditItem,
                                      extra: item,
                                    );
                                    break;
                                  case 'movements':
                                    context.push(
                                      '/inventory/items/${item.id}/movements',
                                      extra: InventoryItem(
                                        productId: item.productId,
                                        productName: product.name,
                                        itemId: item.id!,
                                        specification: item.specification,
                                        unitOfMeasure: item.unitOfMeasure,
                                        stock: 0.0,
                                      ),
                                    );
                                    break;
                                  case 'adjust':
                                    // maybe reuse your stock adjust dialog
                                    break;
                                  case 'stock_card':
                                    _generateStockCard(context, product, item);
                                    break;
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit, size: 16),
                                      SizedBox(width: 8),
                                      Text('Edit Item'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'movements',
                                  child: Row(
                                    children: [
                                      Icon(Icons.history, size: 16),
                                      SizedBox(width: 8),
                                      Text('View Movements'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'adjust',
                                  child: Row(
                                    children: [
                                      Icon(Icons.tune, size: 16),
                                      SizedBox(width: 8),
                                      Text('Quick Adjustment'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'stock_card',
                                  child: Row(
                                    children: [
                                      Icon(Icons.tune, size: 16),
                                      SizedBox(width: 8),
                                      Text('print stock card'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          } else if (state is ProductError) {
            return Center(
              child: Text(
                state.message,
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

Future<void> _generateStockCard(
  BuildContext context,
  ProductDisplayItem product,
  ProductItem item,
) async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a5,
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Card Header
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.black, width: 2),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    product.name,
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    '${product.brand ?? ''} ${item.specification} ${item.color ?? ''}',
                    style: const pw.TextStyle(fontSize: 16),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'Unit of Measure: ${item.unitOfMeasure}',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontStyle: pw.FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            // Stock Table Header
            pw.TableHelper.fromTextArray(
              headers: ['Date', 'Transaction', 'In', 'Out', 'Balance'],
              data: [
                // This is where you would loop through your stock movements for this item
                // For now, here is some sample data
                ['2023-10-26', 'Initial Stock', '10', '', '10'],
                ['2023-10-27', 'Sale #123', '', '2', '8'],
                ['2023-10-28', 'Purchase #456', '5', '', '13'],
              ],
              border: pw.TableBorder.all(),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              cellAlignment: pw.Alignment.center,
              cellStyle: const pw.TextStyle(fontSize: 12),
            ),
          ],
        );
      },
    ),
  );

  // Print the PDF
  await Printing.layoutPdf(
    onLayout: (PdfPageFormat format) async => pdf.save(),
  );
}

