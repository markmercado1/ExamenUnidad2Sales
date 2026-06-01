import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/sale.dart';
import '../../providers/client.provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/sale_provider.dart';

class SaleFormScreen extends StatefulWidget {
  const SaleFormScreen({super.key});

  @override
  State<SaleFormScreen> createState() => _SaleFormScreenState();
}

class _SaleFormScreenState extends State<SaleFormScreen> {

  int? selectedClient;
  int? selectedProduct;

  final quantityController =
  TextEditingController(text: "1");

  @override
  void initState() {
    super.initState();

    context.read<ClientProvider>().loadAll();
    context.read<ProductProvider>().loadAll();
  }

  @override
  Widget build(BuildContext context) {

    final clients =
        context.watch<ClientProvider>().clients;

    final products =
        context.watch<ProductProvider>().products;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Nueva Venta"),
        backgroundColor: Colors.orange,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),

          child: Padding(
            padding: const EdgeInsets.all(16),

            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.stretch,

              children: [

                const Icon(
                  Icons.point_of_sale,
                  size: 70,
                  color: Colors.orange,
                ),

                const SizedBox(height: 20),

                DropdownButtonFormField<int>(
                  value: selectedClient,
                  decoration: const InputDecoration(
                    labelText: "Cliente",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  items: clients.map((client) {
                    return DropdownMenuItem(
                      value: client.serverId,
                      child: Text(client.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedClient = value;
                    });
                  },
                ),

                const SizedBox(height: 15),

                DropdownButtonFormField<int>(
                  value: selectedProduct,
                  decoration: const InputDecoration(
                    labelText: "Producto",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.inventory),
                  ),
                  items: products.map((product) {
                    return DropdownMenuItem(
                      value: product.id,
                      child: Text(product.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedProduct = value;
                    });
                  },
                ),

                const SizedBox(height: 15),

                TextField(
                  controller: quantityController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Cantidad",
                    border: OutlineInputBorder(),
                    prefixIcon:
                    Icon(Icons.format_list_numbered),
                  ),
                ),

                const SizedBox(height: 25),

                SizedBox(
                  height: 50,

                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.save),

                    label: const Text(
                      "Registrar Venta",
                    ),

                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),

                    onPressed: () async {

                      if (selectedClient == null ||
                          selectedProduct == null) {
                        return;
                      }

                      await context
                          .read<SaleProvider>()
                          .save(
                        Sale(
                          clientId: selectedClient!,
                          productId: selectedProduct!,
                          quantity: int.parse(
                            quantityController.text,
                          ),
                        ),
                      );

                      if (mounted) {
                        Navigator.pop(context);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}