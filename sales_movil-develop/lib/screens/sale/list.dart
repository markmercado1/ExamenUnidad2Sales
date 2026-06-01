import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/sale_provider.dart';
import 'form.dart';

class SaleListScreen extends StatefulWidget {
  const SaleListScreen({super.key});

  @override
  State<SaleListScreen> createState() => _SaleListScreenState();
}

class _SaleListScreenState extends State<SaleListScreen> {

  @override
  void initState() {
    super.initState();
    context.read<SaleProvider>().loadAll();
  }

  @override
  Widget build(BuildContext context) {

    final sales = context.watch<SaleProvider>().sales;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Lista de Ventas"),
        backgroundColor: Colors.orange,
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const SaleFormScreen(),
            ),
          );

          if (mounted) {
            context.read<SaleProvider>().loadAll();
          }
        },
      ),

      body: sales.isEmpty
          ? const Center(
        child: Text(
          "No hay ventas registradas",
        ),
      )
          : ListView.builder(
        itemCount: sales.length,
        itemBuilder: (context, index) {

          final sale = sales[index];

          final clientName =
          sale['client']['name'];

          final productName =
          sale['details'][0]['product']['name'];

          final total =
          sale['total'].toString();

          final fecha =
          sale['created_at']
              .toString()
              .substring(0, 10);

          return Card(
            margin: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 5,
            ),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.orange,
                child: Icon(
                  Icons.point_of_sale,
                  color: Colors.white,
                ),
              ),

              title: Text(clientName),

              subtitle: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text("Producto: $productName"),
                  Text("Fecha: $fecha"),
                ],
              ),

              trailing: Text(
                "S/ $total",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}