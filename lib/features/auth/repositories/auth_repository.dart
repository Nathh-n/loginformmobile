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

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      // Langkah 1: kirim email & password, minta token
      final loginResponse = await _dio.post(
        ApiConstants.login,
        data: {
          'email': email,
          'password': password,
        },
      );

      final accessToken = loginResponse.data['access_token'] as String;
      final refreshToken = loginResponse.data['refresh_token'] as String;

      // Langkah 2: simpan token ke storage lokal
      await SessionManager.instance.saveSession(
        accessToken: accessToken,
        refreshToken: refreshToken,
        email: email,
      );

      // Langkah 3: ambil data profil user (token otomatis
      // ditempelin sama interceptor di ApiClient)
      final profileResponse = await _dio.get(ApiConstants.profile);

      // Langkah 4: ubah JSON jadi UserModel
      return UserModel.fromJson(profileResponse.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401 || e.response?.statusCode == 400) {
        throw AuthException('Email atau password salah.');
      }
      throw AuthException('Gagal login. Periksa koneksi internet kamu.');
    }
  }

  Future<void> logout() async {
    await SessionManager.instance.clearSession();
  }
}