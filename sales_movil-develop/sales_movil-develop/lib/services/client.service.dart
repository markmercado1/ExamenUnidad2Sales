import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'package:sales/config/app_config.dart';

import '../models/cliente.dart';
import '../models/sync_result.dart';

class ClientService {
  final String apiUrl = AppConfig.apiUrl;

  Future<(SyncResult, int?)> save(Client client) async {
    final url = Uri.http(apiUrl, '/client/clients/');
    final response = await http.post(
      url,
      body: convert.jsonEncode(client.toJson()),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 201) {
      final json = convert.jsonDecode(response.body);
      return (SyncResult.created, json['id'] as int);
    }
    if (response.statusCode == 400) {
      return (SyncResult.duplicate, null);
    }
    return (SyncResult.error, null);
  }

  Future<SyncResult> edit(Client client) async {
    final url = Uri.http(apiUrl, '/client/clients/${client.serverId}/');
    final response = await http.put(
      url,
      body: convert.jsonEncode(client.toJson()),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) return SyncResult.updated;
    return SyncResult.error;
  }

  Future<void> delete(int serverId) async {
    final url = Uri.http(apiUrl, '/client/clients/$serverId/');
    final response = await http.delete(url);
    if (response.statusCode != 204) {
      throw Exception('Error al eliminar cliente');
    }
  }
}
