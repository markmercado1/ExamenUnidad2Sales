import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../database/provider_database_helper.dart';
import '../../models/provider.dart';
import '../../providers/provider_provider.dart';

class ProviderFormScreen extends StatefulWidget {
  final ProviderModel? provider;

  const ProviderFormScreen({
    super.key,
    this.provider,
  });

  @override
  State<ProviderFormScreen> createState() => _ProviderFormScreenState();
}

class _ProviderFormScreenState extends State<ProviderFormScreen> {
  final TextEditingController controllerNombre = TextEditingController();
  final TextEditingController controllerRuc = TextEditingController();
  final TextEditingController controllerTelefono = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    final provider = widget.provider;
    if (provider != null) {
      controllerNombre.text = provider.nombre;
      controllerRuc.text = provider.ruc;
      controllerTelefono.text = provider.telefono;
    }
  }

  @override
  void dispose() {
    controllerNombre.dispose();
    controllerRuc.dispose();
    controllerTelefono.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final nombre = controllerNombre.text.trim();
    final ruc = controllerRuc.text.trim();
    final telefono = controllerTelefono.text.trim();

    if (nombre.isEmpty || ruc.isEmpty || telefono.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa todos los campos')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (widget.provider == null) {
        // Nuevo proveedor: isSynced=false, serverId=null
        await context.read<ProviderProvider>().save(
          ProviderModel(0, nombre, ruc, telefono, false, null),
        );
      } else {
        // Edición: conserva serverId, marca como no sincronizado
        await context.read<ProviderProvider>().edit(
          widget.provider!.id,
          ProviderModel(
            widget.provider!.id,
            nombre,
            ruc,
            telefono,
            false, // se marcará pendiente hasta próxima sync
            widget.provider!.serverId,
          ),
        );
      }

      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.provider != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Proveedor' : 'Nuevo Proveedor'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            TextField(
              controller: controllerNombre,
              decoration: const InputDecoration(
                labelText: 'Nombre',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: controllerRuc,
              decoration: const InputDecoration(
                labelText: 'RUC',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: controllerTelefono,
              decoration: const InputDecoration(
                labelText: 'Teléfono',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                child: _isLoading
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : Text(isEditing ? 'Guardar cambios' : 'Crear'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}