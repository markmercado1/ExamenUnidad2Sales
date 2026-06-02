import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/provider_provider.dart';
import 'form.dart';

class ProviderDetailScreen extends StatefulWidget {
  final int idProvider;

  const ProviderDetailScreen({
    super.key,
    required this.idProvider,
  });

  @override
  State<ProviderDetailScreen> createState() => _ProviderDetailScreenState();
}

class _ProviderDetailScreenState extends State<ProviderDetailScreen> {
  bool _isDeleting = false;

  Future<void> _delete(BuildContext context, int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar proveedor'),
        content: const Text('¿Estás seguro? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    setState(() => _isDeleting = true);
    try {
      await context.read<ProviderProvider>().delete(id);
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al eliminar el proveedor')),
        );
      }
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider =
    context.watch<ProviderProvider>().getById(widget.idProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de Proveedor'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Datos ────────────────────────────────────────
            _InfoRow(label: 'ID', value: provider.id.toString()),
            const SizedBox(height: 8),
            _InfoRow(label: 'Nombre', value: provider.nombre),
            const SizedBox(height: 8),
            _InfoRow(label: 'RUC', value: provider.ruc),
            const SizedBox(height: 8),
            _InfoRow(label: 'Teléfono', value: provider.telefono),
            const SizedBox(height: 8),

            // ── Estado de sincronización ──────────────────────
            Row(
              children: [
                const Text(
                  'Estado: ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Icon(
                  provider.isSynced ? Icons.cloud_done : Icons.cloud_upload,
                  size: 18,
                  color: provider.isSynced ? Colors.green : Colors.orange,
                ),
                const SizedBox(width: 4),
                Text(
                  provider.isSynced ? 'Sincronizado' : 'Pendiente de sync',
                  style: TextStyle(
                    color: provider.isSynced ? Colors.green : Colors.orange,
                  ),
                ),
              ],
            ),

            if (provider.serverId != null) ...[
              const SizedBox(height: 8),
              _InfoRow(
                  label: 'ID Servidor', value: provider.serverId.toString()),
            ],

            const Spacer(),

            // ── Acciones ─────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: _isDeleting ? null : () => _delete(context, provider.id),
                    icon: _isDeleting
                        ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : const Icon(Icons.delete),
                    label: const Text('Eliminar'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ProviderFormScreen(provider: provider),
                        ),
                      );
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Editar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Widget auxiliar ───────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Expanded(child: Text(value)),
      ],
    );
  }
}