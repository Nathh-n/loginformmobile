import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../models/product_model.dart';

class ProductRepository {
  final _dio = ApiClient.instance.dio;

  Future<List<ProductModel>> fetchPage({
    required int offset,
    int limit = 10,
  }) async {
    final response = await _dio.get(
      ApiConstants.products,
      queryParameters: {
        'offset': offset,
        'limit': limit,
      },
    );

    final List<dynamic> data = response.data;
    return data.map((json) => ProductModel.fromJson(json)).toList();
  }
}