import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'package:sales/config/app_config.dart';

import '../database/database_helper.dart';
import '../models/provider.dart';
import '../models/sync_result.dart';

class ProviderService {
  final String apiUrl = AppConfig.apiUrl;
  final DatabaseHelper _db = DatabaseHelper.instance;

  static const _table = DatabaseHelper.tableProviders;

  // ── Lectura ────────────────────────────────────────────────

  Future<List<ProviderModel>> all() async {
    final rows = await _db.queryAll(_table);
    return rows.map(ProviderModel.fromMap).toList();
  }

  Future<ProviderModel> getById(int localId) async {
    final rows = await _db.queryAll(_table);
    return rows.map(ProviderModel.fromMap).firstWhere((p) => p.id == localId);
  }

  // ── Escritura local ────────────────────────────────────────

  Future<int> save(ProviderModel provider) async {
    final map = provider.toMap()
      ..['is_synced'] = 0
      ..remove('id');
    return await _db.insert(_table, map);
  }

  Future<void> edit(int localId, ProviderModel provider) async {
    final map = provider.toMap()..['is_synced'] = 0;
    await _db.update(_table, localId, map);
  }

  Future<void> delete(int localId) async {
    await _db.delete(_table, localId);
  }

  // ── Sincronización ─────────────────────────────────────────

  Future<void> syncPending() async {
    final pending = await _db.queryPending(_table);
    for (final row in pending) {
      final provider = ProviderModel.fromMap(row);
      final localId = row['id'] as int;

      if (provider.serverId == null) {
        final (result, serverId) = await _create(provider);
        if (result == SyncResult.created && serverId != null) {
          await _db.updateSynced(_table, localId, serverId);
        } else if (result == SyncResult.duplicate) {
          await _db.updateSyncedOnly(_table, localId);
        }
      } else {
        final result = await _update(provider);
        if (result == SyncResult.updated) {
          await _db.updateSyncedOnly(_table, localId);
        }
      }
    }
  }

  // ── Llamadas HTTP privadas ─────────────────────────────────

  Future<(SyncResult, int?)> _create(ProviderModel provider) async {
    final url = Uri.http(apiUrl, '/provider/providers/');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: convert.jsonEncode(provider.toJson()),
    );
    if (response.statusCode == 201) {
      final json = convert.jsonDecode(response.body);
      return (SyncResult.created, json['id'] as int);
    }
    if (response.statusCode == 400) return (SyncResult.duplicate, null);
    return (SyncResult.error, null);
  }

  Future<SyncResult> _update(ProviderModel provider) async {
    final url =
        Uri.http(apiUrl, '/provider/providers/${provider.serverId}/');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: convert.jsonEncode(provider.toJson()),
    );
    if (response.statusCode == 200) return SyncResult.updated;
    return SyncResult.error;
  }

  Future<void> deleteOnServer(int serverId) async {
    final url = Uri.http(apiUrl, '/provider/providers/$serverId/');
    final response = await http.delete(url);
    if (response.statusCode != 204) {
      throw Exception('Error al eliminar proveedor en servidor');
    }
  }
}
