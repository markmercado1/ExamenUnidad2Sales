import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/provider_provider.dart';
import 'detail.dart';
import 'form.dart';

class ProviderListScreen extends StatefulWidget {
  const ProviderListScreen({super.key});

  @override
  State<ProviderListScreen> createState() => _ProviderListScreenState();
}

class _ProviderListScreenState extends State<ProviderListScreen> {
  @override
  void initState() {
    super.initState();
    // Carga inicial desde SQLite local
    context.read<ProviderProvider>().loadAll();
  }

  Future<void> _sync() async {
    try {
      await context.read<ProviderProvider>().syncPending();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sincronización completada')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al sincronizar')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final providers = context.watch<ProviderProvider>().providers;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Proveedores'),
        backgroundColor: Colors.orange,
        actions: [
          // Botón para sincronizar pendientes con el servidor
          IconButton(
            icon: const Icon(Icons.sync),
            tooltip: 'Sincronizar',
            onPressed: _sync,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ProviderFormScreen(),
            ),
          );
          // loadAll ya se llama internamente tras save/edit,
          // pero lo repetimos por si se hizo pop sin acción.
          if (mounted) context.read<ProviderProvider>().loadAll();
        },
        child: const Icon(Icons.add),
      ),
      body: providers.isEmpty
          ? const Center(child: Text('No hay proveedores registrados'))
          : ListView.builder(
        itemCount: providers.length,
        itemBuilder: (context, index) {
          final p = providers[index];
          return ListTile(
            title: Text(p.nombre),
            subtitle: Text(p.ruc),
            // Icono que indica si está sincronizado o pendiente
            trailing: Icon(
              p.isSynced ? Icons.cloud_done : Icons.cloud_upload,
              color: p.isSynced ? Colors.green : Colors.orange,
            ),
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ProviderDetailScreen(idProvider: p.id),
                ),
              );
              if (mounted) context.read<ProviderProvider>().loadAll();
            },
          );
        },
      ),
    );
  }
}