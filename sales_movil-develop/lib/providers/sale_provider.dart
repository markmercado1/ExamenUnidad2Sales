import 'package:flutter/material.dart';
import '../models/sale.dart';
import '../services/sale.service.dart';

class SaleProvider extends ChangeNotifier {
  List<dynamic> _sales = [];

  List<dynamic> get sales => _sales;

  final SaleService saleService = SaleService();

  Future<void> loadAll() async {
    _sales = await saleService.all();
    notifyListeners();
  }

  Future<void> save(Sale sale) async {
    await saleService.save(sale);
    await loadAll();
  }
}