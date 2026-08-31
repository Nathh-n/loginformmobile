import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../storage/session_manager.dart';

class ApiClient {
  ApiClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      LogInterceptor(requestBody: true, responseBody: true),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: _onRequest,
        onError: _onError,
      ),
    );
  }

  static final ApiClient instance = ApiClient._internal();

  late final Dio _dio;

  Dio get dio => _dio;

  // Endpoint yang TIDAK butuh token (belum ada sesi login saat manggil ini).
  static const _authFreePaths = [
    ApiConstants.login,
    ApiConstants.refreshToken,
  ];

  Future<void> _onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final isAuthFree = _authFreePaths.any((path) => options.path.contains(path));

    if (!isAuthFree) {
      final token = await SessionManager.instance.getAccessToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }

    handler.next(options); // lanjutkan request seperti biasa
  }

  Future<void> _onError(
    DioException error,
    ErrorInterceptorHandler handler,
  ) async {
    final isUnauthorized = error.response?.statusCode == 401;
    final alreadyRetried = error.requestOptions.extra['retried'] == true;

    if (isUnauthorized && !alreadyRetried) {
      final newToken = await _tryRefreshToken();
      if (newToken != null) {
        final retryOptions = error.requestOptions;
        retryOptions.headers['Authorization'] = 'Bearer $newToken';
        retryOptions.extra['retried'] = true;

        try {
          final response = await _dio.fetch(retryOptions);
          return handler.resolve(response); // sukses, gak perlu error lagi
        } catch (_) {
          // retry tetap gagal, lanjut ke error asli di bawah
        }
      }
    }

    handler.next(error);
  }

  Future<String?> _tryRefreshToken() async {
    final refreshToken = await SessionManager.instance.getRefreshToken();
    if (refreshToken == null) return null;

    try {
      final response = await _dio.post(
        ApiConstants.refreshToken,
        data: {'refreshToken': refreshToken},
      );
      final newAccessToken = response.data['access_token'] as String;
      await SessionManager.instance.saveSession(
        accessToken: newAccessToken,
        refreshToken: refreshToken,
        email: await SessionManager.instance.getEmailOrEmpty(),
      );
      return newAccessToken;
    } catch (_) {
      await SessionManager.instance.clearSession();
      return null;
    }
  }
}