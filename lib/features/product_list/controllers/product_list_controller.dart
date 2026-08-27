import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/product_model.dart';
import '../repositories/product_repository.dart';

class ProductListController extends ChangeNotifier {
  final ProductRepository _repository = ProductRepository();

  static const int _pageSize = 10;

  final List<ProductModel> items = [];
  bool isLoading = false;
  bool hasMore = true;
  String? errorMessage;

  int _offset = 0;

  Future<void> loadMore() async {
    // Cegah fetch dobel kalau lagi proses, atau data emang udah habis.
    if (isLoading || !hasMore) return;

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final newItems = await _repository.fetchPage(
        offset: _offset,
        limit: _pageSize,
      );

      items.addAll(newItems);
      _offset += _pageSize;
      hasMore = newItems.length == _pageSize;
    } on DioException catch (_) {
      errorMessage = 'Gagal memuat produk. Periksa koneksi internet kamu.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    items.clear();
    _offset = 0;
    hasMore = true;
    errorMessage = null;
    await loadMore();
  }
}