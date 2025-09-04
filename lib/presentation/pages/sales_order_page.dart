import 'package:flutter/material.dart';

class SalesOrderPage extends StatelessWidget {
  const SalesOrderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sales Orders'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Text('Sales Orders Page - Coming Soon'),
      ),
    );
  }
}