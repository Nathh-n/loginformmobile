# Penjelasan Kode Flutter - Fitur Login

## Struktur Folder Project

```
lib/
├── main.dart                              ← Titik awal aplikasi
├── core/                                  ← Fungsi inti yang dipakai semua fitur
│   ├── constants/api_constants.dart       ← Daftar alamat URL server
│   ├── network/api_client.dart            ← Pengirim pesan ke server (HTTP client)
│   └── storage/session_manager.dart       ← Tempat menyimpan data login di HP
└── features/                              ← Fitur-fitur aplikasi
    └── auth/                              ← Fitur login/autentikasi
        ├── models/user_model.dart         ← Template data user
        ├── repositories/auth_repository.dart ← Gudang logic login/logout
        └── pages/login_page.dart          ← Tampilan halaman login
    └── dashboard/
        └── pages/dashboard_page.dart      ← Halaman setelah login berhasil
```

---

## Penjelasan Tiap File

### 1. `main.dart` - Pintu Masuk Aplikasi

**Apa fungsinya?** Ini yang pertama kali dijalankan saat app dibuka.

**Alurnya:**
- App dimulai → `runApp(MyApp())`
- `MyApp` menampilkan material design dengan judul "Login Dashboard"
- Sebelum menampilkan halaman, ada widget `_SessionGate` yang **mengecek dulu**: "Apakah user sudah login sebelumnya dan sesinya masih berlaku?"
- Kalau **ya** → langsung ke `DashboardPage` (halaman utama)
- Kalau **tidak** → ke `LoginPage` (halaman login)

**Analogi:** Seperti penjaga pintu yang mengecek tiket dulu sebelum masuk gedung.

---

### 2. `api_constants.dart` - Daftar Alamat Server

**Apa fungsinya?** Menyimpan semua URL endpoint server di satu tempat.

```dart
baseUrl = 'https://api.escuelajs.co/api/v1'  ← Alamat server utama
login = '/auth/login'                          ← URL untuk login
profile = '/auth/profile'                      ← URL untuk ambil data profil
```

**Kenapa dipisah?** Supaya kalau alamat server berubah, cukup ganti di satu tempat saja.

---

### 3. `api_client.dart` - Pengirim Pesan ke Server

**Apa fungsinya?** Bertugas mengirim permintaan (request) ke server dan menerima respons.

**Fitur penting:**
- **Interceptor Token Otomatis**: Setiap kali ada request ke server, otomatis menyertakan token login (kecuali untuk endpoint login & refresh token)
- **Auto Refresh Token**: Kalau server bilang "token expired" (401), otomatis minta token baru lalu coba ulang request

**Alurnya:**
1. User mau ambil data → request dikirim
2. Sebelum dikirim, cek apakah butuh token → kalau iya, tempelkan token
3. Kalau server bilang "token expired" → minta token baru → coba ulang request
4. Kalau tetap gagal → kirim error

---

### 4. `user_model.dart` - Template Data User

**Apa fungsinya?** Menentukan bentuk data user yang diterima dari server.

```dart
class UserModel {
  final int id;        ← ID unik user
  final String email;  ← Email user
  final String name;   ← Nama user
  final String avatar; ← URL foto profil
}
```

**Kenapa pakai factory `fromJson`?** Karena server mengirim data dalam format JSON, dan kita perlu mengubahnya jadi objek Dart.

---

### 5. `auth_repository.dart` - Gudang Logic Login

**Apa fungsinya?** Menangani semua proses terkait login dan logout.

**Alur Login (langkah demi langkah):**
1. **Kirim email & password** ke server via endpoint `/auth/login`
2. Server mengirim balikan **access_token** dan **refresh_token**
3. **Simpan token** ke penyimpanan lokal HP (SharedPreferences)
4. **Ambil data profil** user via endpoint `/auth/profile`
5. **Kembalikan data user** dalam bentuk `UserModel`

**Alur Logout:**
- Hapus semua data token dari penyimpanan lokal HP

---

### 6. `login_page.dart` - Tampilan Halaman Login

**Apa fungsinya?** Menampilkan form login dan menangani input user.

**Komponen:**
- **Form Email**: Input email dengan validasi format
- **Form Password**: Input password dengan validasi minimal 6 karakter
- **Tombol Login**: Tombol untuk memproses login
- **Indikator Loading**: Menampilkan animasi loading saat proses login

**Alur:**
1. User isi email & password
2. Tekan tombol "Login"
3. App **validasi** input (email valid? password cukup panjang?)
4. Kalau valid → panggil `AuthRepository.login()`
5. Kalau berhasil → pindah ke `DashboardPage`
6. Kalau gagal → tampilkan pesan error (SnackBar)

---

### 7. `session_manager.dart` - Penyimpan Sesi

**Apa fungsinya?** Menyimpan dan mengelola data login di HP user.

**Data yang disimpan:**
- `access_token` ← Token untuk akses API
- `refresh_token` ← Token untuk memperpanjang sesi
- `user_email` ← Email yang login
- `login_at_millis` ← Waktu login (dalam milidetik)

**Fitur Penting:**
- **Sesi Berlaku 4 Jam**: Setelah 4 jam, sesi dianggap kadaluarsa
- `isSessionValid()` ← Mengecek apakah sesi masih berlaku
- `clearSession()` ← Menghapus semua data sesi

---

### 8. `dashboard_page.dart` - Halaman Utama (Setelah Login)

**Apa fungsinya?** Halaman yang ditampilkan setelah login berhasil.

**Fitur:**
- **Navigation Bar**: Dua tab (Upload & Produk) - masih placeholder
- **Tombol Logout**: Untuk keluar dari akun
- **Cek Sesi Berkala**: Setiap 1 menit, mengecek apakah sesi masih valid. Kalau sudah 4 jam, paksa logout.

---

## Alur Komunikasi Antar Kode

```
┌─────────────────────────────────────────────────────────────┐
│                        main.dart                            │
│  (Mengecek sesi, memutuskan halaman awal)                   │
└─────────────────────┬───────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────┐
│                    LoginPage.dart                           │
│  (User isi email & password)                                │
└─────────────────────┬───────────────────────────────────────┘
                      │ Panggil login()
                      ▼
┌─────────────────────────────────────────────────────────────┐
│                AuthRepository.dart                          │
│  (Logic login: kirim data, simpan token, ambil profil)      │
└──────────┬────────────────────────────┬─────────────────────┘
           │                            │
           ▼                            ▼
┌──────────────────────┐  ┌─────────────────────────────────┐
│  ApiClient.dart      │  │  SessionManager.dart            │
│  (Kirim request ke   │  │  (Simpan/hapus token di HP)     │
│   server + auto      │  └─────────────────────────────────┘
│   token attachment)  │
└──────────┬───────────┘
           │
           ▼
┌─────────────────────────────────────────────────────────────┐
│              SERVER (api.escuelajs.co)                      │
│  (Memproses login, mengirim token & data user)              │
└─────────────────────────────────────────────────────────────┘
```

---

## Detail Penjelasan: api_client.dart

### Apa ini?
Bayangkan `ApiClient` seperti **asisten pribadi** yang selalu menyertakan kartu identitas (token) setiap kali mengirim surat (request) ke kantor pusat (server).

### Kode per Kode:

#### Konstruktor dan Inisialisasi

```dart
class ApiClient {
  ApiClient._internal() {
```
- Ini adalah **konstruktor privat** (hanya bisa dipanggil dari dalam kelas ini sendiri).
- Tanda `_` artinya "privat" - tidak bisa diakses dari luar.
- Fungsi ini berjalan **satu kali saja** saat `ApiClient` pertama kali dibuat.

---

```dart
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
```
- **`Dio`**: Library untuk mengirim request HTTP (seperti browser tapi di dalam aplikasi).
- **`baseUrl`**: Alamat server utama (dari `api_constants.dart`).
- **`connectTimeout`**: Kalau koneksi ke server lebih dari 15 detik → gagal.
- **`receiveTimeout`**: Kalau server tidak merespon lebih dari 15 detik → gagal.
- **`headers`**: Memberitahu server bahwa data yang dikirim dalam format JSON.

---

#### Interceptor (Penjaga Gerbang)

```dart
    _dio.interceptors.add(
      LogInterceptor(requestBody: true, responseBody: true),
    );
```
- **Interceptor**: Seperti "penjaga gerbang" yang memantau semua request/response.
- **LogInterceptor**: Mencatat semua request dan response ke console (untuk debugging).
- `requestBody: true` → catat isi data yang dikirim.
- `responseBody: true` → catat isi data yang diterima.

---

```dart
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: _onRequest,
        onError: _onError,
      ),
    );
```
- Menambahkan **2 interceptor utama**:
  - `onRequest`: Berjalan sebelum request dikirim → untuk menempelkan token.
  - `onError`: Berjalan saat ada error → untuk auto-refresh token.

---

#### Singleton Pattern (Hanya Satu Instance)

```dart
  static final ApiClient instance = ApiClient._internal();
```
- **Singleton Pattern**: Hanya ada **satu instance** `ApiClient` di seluruh aplikasi.
- Semua bagian aplikasi menggunakan `ApiClient.instance` yang sama.
- **Analogi**: Seperti SIM card - satu nomor untuk satu HP, tidak bisa duplikat.

---

```dart
  late final Dio _dio;
  Dio get dio => _dio;
```
- `_dio`: Variabel internal yang menyimpan objek Dio.
- `get dio`: Getter untuk mengakses `_dio` dari luar kelas.
- Artinya, bagian lain bisa memanggil `ApiClient.instance.dio` untuk mengirim request.

---

#### Endpoint yang Tidak Butuh Token

```dart
  static const _authFreePaths = [
    ApiConstants.login,
    ApiConstants.refreshToken,
  ];
```
- Daftar endpoint yang **TIDAK butuh token**:
  - `/auth/login` → Karena ini proses login, belum punya token.
  - `/auth/refresh-token` → Untuk memperpanjang token, pakai refresh token.

---

### Fungsi `_onRequest` (Menempelkan Token):

```dart
  Future<void> _onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
```
- Fungsi ini berjalan **otomatis** sebelum setiap request dikirim.
- `RequestOptions options`: Berisi semua informasi request (URL, method, headers, dll).
- `RequestInterceptorHandler handler`: Untuk melanjutkan atau membatalkan request.

---

```dart
    final isAuthFree = _authFreePaths.any((path) => options.path.contains(path));
```
- Mengecek: Apakah request ini ke endpoint yang **tidak butuh token**?
- `any()` → Mengembalikan `true` jika **minimal satu** path cocok.
- `contains()` → Mengecek apakah path request mengandung string tertentu.

**Contoh:**
- Request ke `/auth/login` → `isAuthFree = true` → tidak perlu token.
- Request ke `/auth/profile` → `isAuthFree = false` → butuh token.

---

```dart
    if (!isAuthFree) {
      final token = await SessionManager.instance.getAccessToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
```
- Kalau request **butuh token**:
  1. Ambil token dari `SessionManager` (penyimpanan lokal).
  2. Kalau token ada → tempelkan di header request.
  3. Format: `Authorization: Bearer <token>` (standar industri).

**Analogi**: Seperti menempelkan stiker "VIP" di tiket masuk gedung.

---

```dart
    handler.next(options);
```
- **Lanjutkan request** seperti biasa setelah token ditempelkan.

---

### Fungsi `_onError` (Auto Refresh Token):

```dart
  Future<void> _onError(
    DioException error,
    ErrorInterceptorHandler handler,
  ) async {
```
- Fungsi ini berjalan **otomatis** saat ada error dari server.

---

```dart
    final isUnauthorized = error.response?.statusCode == 401;
    final alreadyRetried = error.requestOptions.extra['retried'] == true;
```
- **`isUnauthorized`**: Cek apakah errornya "401 Unauthorized" (token expired/invalid).
- **`alreadyRetried`**: Cek apakah request ini sudah pernah dicoba ulang (agar tidak infinite loop).

---

```dart
    if (isUnauthorized && !alreadyRetried) {
      final newToken = await _tryRefreshToken();
```
- Kalau error 401 DAN belum pernah retry → coba refresh token.

---

```dart
      if (newToken != null) {
        final retryOptions = error.requestOptions;
        retryOptions.headers['Authorization'] = 'Bearer $newToken';
        retryOptions.extra['retried'] = true;

        try {
          final response = await _dio.fetch(retryOptions);
          return handler.resolve(response);
        } catch (_) {
          // retry tetap gagal
        }
      }
    }
```
- Kalau refresh token berhasil:
  1. Ganti token lama dengan token baru di header.
  2. Tandai request ini sudah di-retry (`extra['retried'] = true`).
  3. Kirim ulang request yang gagal tadi.
  4. Kalau berhasil → return response (tidak error lagi).

---

### Fungsi `_tryRefreshToken` (Minta Token Baru):

```dart
  Future<String?> _tryRefreshToken() async {
    final refreshToken = await SessionManager.instance.getRefreshToken();
    if (refreshToken == null) return null;
```
- Ambil refresh token dari penyimpanan lokal.
- Kalau tidak ada refresh token → return `null` (tidak bisa refresh).

---

```dart
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
```
- Kirim refresh token ke server `/auth/refresh-token`.
- Server mengirim balikan `access_token` baru.
- Simpan token baru ke `SessionManager`.
- Kalau gagal → hapus semua sesi (logout paksa).

---

## Detail Penjelasan: auth_repository.dart

### Apa ini?
`AuthRepository` seperti **petugas keamanan** yang memproses pendaftaran dan mengatur akses user.

### Kode per Kode:

#### Custom Exception (Error Khusus)

```dart
class AuthException implements Exception {
  final String message;
  AuthException(this.message);
  @override
  String toString() => message;
}
```
- **Custom Exception**: Error khusus untuk masalah autentikasi.
- `message`: Pesan error yang akan ditampilkan ke user.
- `toString()`: Mengembalikan pesan error saat di-catch.

**Contoh penggunaan:**
```dart
throw AuthException('Email atau password salah.');
```

---

#### Inisialisasi Dio

```dart
class AuthRepository {
  final Dio _dio = ApiClient.instance.dio;
```
- Mengambil objek `Dio` dari `ApiClient` (yang sudah diatur dengan token otomatis).
- Semua request menggunakan `ApiClient` yang sama.

---

### Fungsi `login`:

```dart
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
```
- Fungsi login yang mengembalikan `UserModel` (data user).
- `required` → email dan password wajib diisi.

---

**Langkah 1: Kirim Email & Password**

```dart
      final loginResponse = await _dio.post(
        ApiConstants.login,
        data: {
          'email': email,
          'password': password,
        },
      );
```
- Kirim POST request ke `/auth/login`.
- Data yang dikirim: `{ "email": "...", "password": "..." }`.

---

**Langkah 2: Ambil Token dari Response**

```dart
      final accessToken = loginResponse.data['access_token'] as String;
      final refreshToken = loginResponse.data['refresh_token'] as String;
```
- Server mengirim balikan JSON:
  ```json
  {
    "access_token": "abc123...",
    "refresh_token": "xyz789..."
  }
  ```
- Kita ambil kedua token tersebut.

---

**Langkah 3: Simpan Token**

```dart
      await SessionManager.instance.saveSession(
        accessToken: accessToken,
        refreshToken: refreshToken,
        email: email,
      );
```
- Simpan token ke penyimpanan lokal HP (via `SessionManager`).
- Data yang disimpan: access_token, refresh_token, email.

---

**Langkah 4: Ambil Data Profil User**

```dart
      final profileResponse = await _dio.get(ApiConstants.profile);
```
- Kirim GET request ke `/auth/profile`.
- **Catatan**: Token sudah otomatis ditempelkan oleh `ApiClient` interceptor!
- Server mengirim data profil user (id, name, email, avatar).

---

**Langkah 5: Kembalikan Data User**

```dart
      return UserModel.fromJson(profileResponse.data);
```
- Ubah JSON response menjadi objek `UserModel`.
- Kembalikan ke pemanggil (biasanya `LoginPage`).

---

**Error Handling:**

```dart
    } on DioException catch (e) {
      if (e.response?.statusCode == 401 || e.response?.statusCode == 400) {
        throw AuthException('Email atau password salah.');
      }
      throw AuthException('Gagal login. Periksa koneksi internet kamu.');
    }
```
- **401/400**: Email atau password salah → pesan spesifik.
- **Error lainnya**: Masalah koneksi internet → pesan umum.

---

### Fungsi `logout`:

```dart
  Future<void> logout() async {
    await SessionManager.instance.clearSession();
  }
```
- Hapus semua data sesi dari penyimpanan lokal.
- User akan diminta login kembali saat membuka app.

---

## Detail Penjelasan: session_manager.dart

### Apa ini?
`SessionManager` seperti **brankas pribadi** yang menyimpan kartu akses (token) dan hanya bisa diakses oleh user yang bersangkutan.

### Kode per Kode:

#### Singleton Pattern

```dart
class SessionManager {
  SessionManager._internal();
  static final SessionManager instance = SessionManager._internal();
```
- **Singleton Pattern**: Hanya ada satu instance di seluruh aplikasi.
- Semua bagian aplikasi menggunakan `SessionManager.instance` yang sama.

---

#### Key untuk Penyimpanan

```dart
  static const _keyAccessToken = 'access_token';
  static const _keyRefreshToken = 'refresh_token';
  static const _keyLoginAt = 'login_at_millis';
  static const _keyEmail = 'user_email';
```
- **Key untuk SharedPreferences**: Nama-nama unik untuk menyimpan data.
- **`SharedPreferences`**: Penyimpanan lokal di HP (seperti hard drive kecil).

**Contoh penyimpanan:**
```
access_token → "eyJhbGciOiJIUzI1NiIs..."
refresh_token → "dGhpcyBpcyBhIHJlZnJl..."
login_at_millis → 1693123456789
user_email → "john@mail.com"
```

---

#### Durasi Sesi

```dart
  final Duration sessionDuration = const Duration(hours: 4);
```
- Sesi berlaku selama **4 jam**.
- Setelah 4 jam, sesi dianggap kadaluarsa.

---

### Fungsi `saveSession`:

```dart
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
```
- **`SharedPreferences.getInstance()`**: Mengakses penyimpanan lokal HP.
- **`setString`**: Menyimpan teks (token, email).
- **`setInt`**: Menyimpan angka (waktu login dalam milidetik).
- **`DateTime.now().millisecondsSinceEpoch`**: Waktu sekarang dalam format angka.

**Contoh:**
```
Waktu login: 27 Agustus 2026, 10:00 WIB
→ Disimpan sebagai: 1693123456789 (milidetik sejak 1 Januari 1970)
```

---

### Fungsi `getAccessToken`:

```dart
  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyAccessToken);
  }
```
- Mengambil access token dari penyimpanan.
- Mengembalikan `null` jika tidak ada (belum login).

---

### Fungsi `getRefreshToken`:

```dart
  Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyRefreshToken);
  }
```
- Mengambil refresh token dari penyimpanan.

---

### Fungsi `getEmailOrEmpty`:

```dart
  Future<String> getEmailOrEmpty() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyEmail) ?? '';
  }
```
- Mengambil email dari penyimpanan.
- Kalau tidak ada → kembalikan string kosong (`''`).

---

### Fungsi `isSessionValid` (PENTING):

```dart
  Future<bool> isSessionValid() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_keyAccessToken);
    final loginAt = prefs.getInt(_keyLoginAt);

    if (token == null || loginAt == null) return false;

    final loginTime = DateTime.fromMillisecondsSinceEpoch(loginAt);
    final elapsed = DateTime.now().difference(loginTime);

    return elapsed < sessionDuration;
  }
```

**Penjelasan step-by-step:**

1. **Ambil token dan waktu login** dari penyimpanan.
2. **Cek apakah ada**: Kalau tidak ada → `false` (belum login).
3. **Hitung waktu berlalu**:
   - `loginTime`: Waktu login (dari `loginAt`).
   - `elapsed`: Selisih waktu antara sekarang dan waktu login.
4. **Bandingkan dengan durasi sesi** (4 jam):
   - Kalau `elapsed < 4 jam` → `true` (sesi masih valid).
   - Kalau `elapsed >= 4 jam` → `false` (sesi kadaluarsa).

**Contoh:**
```
Waktu login: 10:00 WIB
Sekarang: 13:30 WIB
elapsed: 3 jam 30 menit
3 jam 30 menit < 4 jam → true (sesi masih valid)

Sekarang: 14:30 WIB
elapsed: 4 jam 30 menit
4 jam 30 menit < 4 jam → false (sesi kadaluarsa)
```

---

### Fungsi `clearSession`:

```dart
  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyAccessToken);
    await prefs.remove(_keyRefreshToken);
    await prefs.remove(_keyLoginAt);
    await prefs.remove(_keyEmail);
  }
```
- Menghapus **semua data sesi** dari penyimpanan.
- Dipanggil saat logout atau sesi kadaluarsa.

---

## Alur Komunikasi Detail

### Proses Login

```
┌─────────────────────────────────────────────────────────────┐
│                    LOGIN PROCESS                            │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  LoginPage                                                  │
│     │                                                       │
│     │ 1. User isi email & password                          │
│     ▼                                                       │
│  AuthRepository.login()                                     │
│     │                                                       │
│     │ 2. Kirim email & password ke server                   │
│     │    (via ApiClient.dio)                                │
│     ▼                                                       │
│  ApiClient (otomatis menempelkan token jika ada)            │
│     │                                                       │
│     │ 3. Server kirim token balik                           │
│     ▼                                                       │
│  AuthRepository                                              │
│     │                                                       │
│     │ 4. Simpan token ke SessionManager                     │
│     ▼                                                       │
│  SessionManager.saveSession()                               │
│     │                                                       │
│     │ 5. Token tersimpan di SharedPreferences (HP)          │
│     ▼                                                       │
│  AuthRepository                                              │
│     │                                                       │
│     │ 6. Ambil data profil user                             │
│     │    (via ApiClient.dio, token otomatis ditempel)       │
│     ▼                                                       │
│  UserModel (data user dikembalikan)                         │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

### Auto Token Refresh (Saat Token Expired)

```
┌─────────────────────────────────────────────────────────────┐
│              AUTO TOKEN REFRESH (saat token expired)        │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ApiClient._onError()                                       │
│     │                                                       │
│     │ 1. Error 401 (token expired)                          │
│     ▼                                                       │
│  ApiClient._tryRefreshToken()                               │
│     │                                                       │
│     │ 2. Ambil refresh_token dari SessionManager            │
│     ▼                                                       │
│  Kirim ke server /auth/refresh-token                        │
│     │                                                       │
│     │ 3. Server kirim access_token baru                     │
│     ▼                                                       │
│  SessionManager.saveSession() (token baru disimpan)         │
│     │                                                       │
│     │ 4. Kirim ulang request dengan token baru              │
│     ▼                                                       │
│  Request berhasil                                           │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

### Session Check (Saat App Dibuka)

```
┌─────────────────────────────────────────────────────────────┐
│              SESSION CHECK (saat app dibuka)                │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  main.dart (_SessionGate)                                   │
│     │                                                       │
│     │ 1. Cek sesi masih valid?                              │
│     ▼                                                       │
│  SessionManager.isSessionValid()                            │
│     │                                                       │
│     │ 2. Bandingkan waktu login dengan sekarang             │
│     ▼                                                       │
│  Kalau < 4 jam → true (ke DashboardPage)                    │
│  Kalau >= 4 jam → false (ke LoginPage)                      │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## Ringkasan dalam Bentuk Tabel

| Komponen | Fungsi | Analogi |
|----------|--------|---------|
| **main.dart** | Titik masuk, cek sesi awal | Penjaga pintu utama |
| **api_constants.dart** | Menyimpan URL server | Daftar alamat kantor |
| **api_client.dart** | Mengirim request HTTP, auto token, auto refresh | Kurir pribadi dengan kartu identitas |
| **user_model.dart** | Template data user | Formulir pendaftaran |
| **auth_repository.dart** | Logic login/logout | Petugas keamanan |
| **login_page.dart** | Tampilan form login | Lobi gedung |
| **session_manager.dart** | Menyimpan/mengelola token | Brankas kartu akses |
| **dashboard_page.dart** | Halaman utama setelah login | Ruangan kantor |

---

## Ringkasan Alur Sederhana

Bayangkan ini seperti **proses masuk gedung perkantoran**:

1. **`main.dart`** = Penjaga pintu utama yang mengecek apakah kamu punya kartu akses yang masih berlaku
2. **`LoginPage`** = Formulir pendaftaran di lobi gedung
3. **`AuthRepository`** = Petugas keamanan yang memproses pendaftaran
4. **`ApiClient`** = Kurir yang membawa surat-menyurat ke kantor pusat (server)
5. **`SessionManager`** = Brankas yang menyimpan kartu akses kamu
6. **`DashboardPage`** = Ruangan kantor yang bisa kamu masuki setelah kartu akses aktif

**Proses Login:**
1. Kamu isi formulir (email & password)
2. Petugas keamanan (AuthRepository) mengirim data ke kantor pusat (server)
3. Kantor pusat mengirim kartu akses (token) balik
4. Kartu akses disimpan di brankas (SessionManager)
5. Kamu bisa masuk ruangan kantor (DashboardPage)

**Keamanan:**
- Kartu akses otomatis ditempelkan setiap kali ada surat-menyurat (auto token attachment)
- Kartu akses berlaku 4 jam, lalu kadaluarsa
- Kalau kartu tidak berlaku, kamu diminta keluar dan daftar ulang
