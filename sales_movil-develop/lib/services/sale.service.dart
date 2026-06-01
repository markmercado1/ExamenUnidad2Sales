import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'package:sales/config/app_config.dart';
import '../models/sale.dart';

class SaleService {
  final String apiUrl = AppConfig.apiUrl;

  Future<List<dynamic>> all() async {
    var url = Uri.http(apiUrl, '/sale/sales/');

    var response = await http.get(url);

    if (response.statusCode == 200) {
      return convert.jsonDecode(response.body);
    }

    throw Exception("Error al cargar ventas");
  }

  Future<void> save(Sale sale) async {
    var url = Uri.http(apiUrl, '/sale/sales/');

    var response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: convert.jsonEncode(sale.toJson()),
    );

    if (response.statusCode != 201) {
      throw Exception("Error al guardar venta");
    }
  }
}