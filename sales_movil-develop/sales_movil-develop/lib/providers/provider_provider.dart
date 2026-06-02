import 'package:flutter/material.dart';

import '../models/provider.dart';
import '../services/provider.service.dart';

class ProviderProvider extends ChangeNotifier {
  List<ProviderModel> _providers = [];
  List<ProviderModel> get providers => _providers;

  final ProviderService _service = ProviderService();

  // ── Carga ──────────────────────────────────────────────────

  Future<void> loadAll() async {
    _providers = await _service.all();
    notifyListeners();
  }

  // ── Escritura local ────────────────────────────────────────

  Future<void> save(ProviderModel provider) async {
    await _service.save(provider);
    await loadAll();
  }

  Future<void> edit(int localId, ProviderModel provider) async {
    await _service.edit(localId, provider);
    await loadAll();
  }

  Future<void> delete(int localId) async {
    final provider = getById(localId);
    if (provider.serverId != null) {
      await _service.deleteOnServer(provider.serverId!);
    }
    await _service.delete(localId);
    await loadAll();
  }

  // ── Helpers ────────────────────────────────────────────────

  ProviderModel getById(int localId) {
    return _providers.firstWhere((p) => p.id == localId);
  }

  // ── Sincronización ─────────────────────────────────────────

  Future<void> syncPending() async {
    await _service.syncPending();
    await loadAll();
  }
}
