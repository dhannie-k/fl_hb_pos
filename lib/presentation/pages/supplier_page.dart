import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/supplier.dart';
import '../bloc/supplier/supplier_bloc.dart';

class SuppliersPage extends StatefulWidget {
  const SuppliersPage({super.key});

  @override
  State<SuppliersPage> createState() => _SuppliersPageState();
}

class _SuppliersPageState extends State<SuppliersPage> {
  @override
  void initState() {
    super.initState();
    context.read<SupplierBloc>().add(LoadSuppliers());
  }

  void _showSupplierDialog({Supplier? supplier}) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: supplier?.name);
    final addressController = TextEditingController(text: supplier?.address);
    final phoneController = TextEditingController(text: supplier?.phoneNumber);

    showDialog(
      context: context,
      // Use the parent context that has the SupplierBloc
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(supplier == null ? 'Add Supplier' : 'Edit Supplier'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    autofocus: true,
                    decoration: const InputDecoration(labelText: 'Supplier Name*'),
                    validator: (val) => (val == null || val.trim().isEmpty)
                        ? 'Name cannot be empty'
                        : null,
                  ),
                  TextFormField(
                    controller: addressController,
                    decoration: const InputDecoration(labelText: 'Address'),
                  ),
                  TextFormField(
                    controller: phoneController,
                    decoration: const InputDecoration(labelText: 'Phone Number'),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // --- DEBUGGING & FIX ---
                final bool isValid = formKey.currentState?.validate() ?? false;
                print('Form validation state: $isValid'); // See this in your terminal

                if (isValid) {
                  final name = nameController.text.trim();
                  final address = addressController.text.trim();
                  final phone = phoneController.text.trim();

                  if (supplier == null) {
                    // Add new supplier
                    context.read<SupplierBloc>().add(AddSupplier(
                          name: name,
                          address: address.isNotEmpty ? address : null,
                          phoneNumber: phone.isNotEmpty ? phone : null,
                        ));
                  } else {
                    // Update existing supplier
                    final updatedSupplier = supplier.copyWith(
                      name: name,
                      address: address,
                      phoneNumber: phone,
                    );
                    context
                        .read<SupplierBloc>()
                        .add(UpdateSupplier(updatedSupplier));
                  }
                  Navigator.of(dialogContext).pop(); // Close the dialog
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Suppliers'), leading: IconButton(onPressed: () => context.pushReplacement('/dashboard'), icon: Icon(Icons.arrow_back)),),
      body: BlocConsumer<SupplierBloc, SupplierState>(
        listener: (context, state) {
          if (state is SupplierError) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Colors.red));
          }
          if (state is SupplierOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(state.message), backgroundColor: Colors.green));
          }
        },
        builder: (context, state) {
          if (state is SupplierLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is SuppliersLoaded) {
            if (state.suppliers.isEmpty) {
              return const Center(child: Text('No suppliers found. Tap + to add one.'));
            }
            return ListView.builder(
              padding: const EdgeInsets.only(bottom: 80), // Avoid FAB overlap
              itemCount: state.suppliers.length,
              itemBuilder: (context, index) {
                final supplier = state.suppliers[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  child: ListTile(
                    title: Text(supplier.name),
                    subtitle: Text(supplier.address ?? 'No address'),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          _showSupplierDialog(supplier: supplier);
                        } else if (value == 'delete') {
                           // It's good practice to confirm deletion
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Confirm Deletion'),
                              content: Text('Are you sure you want to delete ${supplier.name}?'),
                              actions: [
                                TextButton(onPressed: ()=>Navigator.of(ctx).pop(), child: const Text('No')),
                                TextButton(onPressed: (){
                                  context.read<SupplierBloc>().add(DeleteSupplier(supplier.id));
                                  Navigator.of(ctx).pop();
                                }, child: const Text('Yes')),
                              ],
                            )
                          );
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'edit', child: Text('Edit')),
                        const PopupMenuItem(value: 'delete', child: Text('Delete')),
                      ],
                    ),
                  ),
                );
              },
            );
          }
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Could not load suppliers.'),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => context.read<SupplierBloc>().add(LoadSuppliers()),
                  child: const Text('Retry'),
                )
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showSupplierDialog(),
        tooltip: 'Add Supplier',
        child: const Icon(Icons.add),
      ),
    );
  }
}
