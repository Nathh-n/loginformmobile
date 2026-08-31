import 'package:dio/dio.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/session_manager.dart';
import '../models/user_model.dart';

class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => message;
}

class AuthRepository {
  final Dio _dio = ApiClient.instance.dio;

  Future<void> login({
    required String email,
    required String password,
  }) async {
    try {
      final loginResponse = await _dio.post(
        ApiConstants.login,
        data: {
          'email': email,
          'password': password,
        },
      );

      final accessToken = loginResponse.data['access_token'] as String;
      final refreshToken = loginResponse.data['refresh_token'] as String;

      await SessionManager.instance.saveSession(
        accessToken: accessToken,
        refreshToken: refreshToken,
        email: email,
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 401 || e.response?.statusCode == 400) {
        throw AuthException('Email atau password salah.');
      }
      throw AuthException('Gagal login. Periksa koneksi internet kamu.');
    }
  }

  Future<UserModel> getProfile() async {
    final response = await _dio.get(ApiConstants.profile);
    return UserModel.fromJson(response.data);
  }

  Future<void> logout() async {
    await SessionManager.instance.clearSession();
  }
}