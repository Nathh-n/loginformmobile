import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import '../models/upload_result.dart';

const String _imgbbApiKey = '8df53c18cf344c165b7f57f8a00669a3';
const String _imgbbUploadUrl = 'https://api.imgbb.com/1/upload';

class UploadException implements Exception {
  final String message;
  UploadException(this.message);

  @override
  String toString() => message;
}

class UploadRepository {
  final Dio _dio = Dio();

  Future<UploadResult> uploadMultipart(File imageFile) async {
    try {
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(imageFile.path),
      });

      final response = await _dio.post(
        _imgbbUploadUrl,
        queryParameters: {'key': _imgbbApiKey},
        data: formData,
      );

      return UploadResult.fromJson(response.data);
    } on DioException catch (e) {
      throw UploadException(_mapError(e));
    }
  }

  /// Metode 2: encode gambar jadi base64 dulu, baru kirim sebagai teks.
  Future<UploadResult> uploadBase64(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      final response = await _dio.post(
        _imgbbUploadUrl,
        queryParameters: {'key': _imgbbApiKey},
        data: FormData.fromMap({'image': base64Image}),
      );

      return UploadResult.fromJson(response.data);
    } on DioException catch (e) {
      throw UploadException(_mapError(e));
    }
  }

  String _mapError(DioException e) {
    if (e.response?.statusCode == 400) {
      return 'Gambar tidak valid, atau API key salah.';
    }
    return 'Gagal upload gambar. Periksa koneksi internet kamu.';
  }
}