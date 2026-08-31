class ApiConstants {
  ApiConstants._(); // biar class ini gak bisa di-instantiate (cuma dipake statis)

  static const String baseUrl = 'https://api.escuelajs.co/api/v1';

  // Auth
  static const String login = '/auth/login';
  static const String refreshToken = '/auth/refresh-token';
  static const String profile = '/auth/profile';

  // Upload
  static const String uploadFile = '/files/upload';

  // Product (buat lazy load)
  static const String products = '/products';
}