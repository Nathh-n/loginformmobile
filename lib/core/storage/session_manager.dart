import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  SessionManager._internal();
  static final SessionManager instance = SessionManager._internal();

  static const _keyAccessToken = 'access_token';
  static const _keyRefreshToken = 'refresh_token';
  static const _keyLoginAt = 'login_at_millis';
  static const _keyEmail = 'user_email';

  final Duration sessionDuration = const Duration(hours: 4);

  Future<void> saveSession({
    required String accessToken,
    required String refreshToken,
    required String email,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAccessToken, accessToken);
    await prefs.setString(_keyRefreshToken, refreshToken);
    await prefs.setString(_keyEmail, email);
    await prefs.setInt(_keyLoginAt, DateTime.now().millisecondsSinceEpoch);
  }

  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyAccessToken);
  }

  Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyRefreshToken);
  }

  Future<String> getEmailOrEmpty() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyEmail) ?? '';
  }

  Future<bool> isSessionValid() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_keyAccessToken);
    final loginAt = prefs.getInt(_keyLoginAt);

    if (token == null || loginAt == null) return false;

    final loginTime = DateTime.fromMillisecondsSinceEpoch(loginAt);
    final elapsed = DateTime.now().difference(loginTime);

    return elapsed < sessionDuration;
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyAccessToken);
    await prefs.remove(_keyRefreshToken);
    await prefs.remove(_keyLoginAt);
    await prefs.remove(_keyEmail);
  }
}