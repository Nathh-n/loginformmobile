import 'package:flutter/material.dart';
import 'core/storage/session_manager.dart';
import 'features/auth/pages/login_page.dart';
import 'features/dashboard/pages/dashboard_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login Dashboard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
      ),
      home: const _SessionGate(),
    );
  }
}

/// Widget "gerbang": ngecek dulu apakah ada sesi login yang masih valid
/// tersimpan di HP, sebelum mutusin halaman awal yang ditampilkan.
class _SessionGate extends StatelessWidget {
  const _SessionGate();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: SessionManager.instance.isSessionValid(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final isSessionValid = snapshot.data ?? false;
        return isSessionValid ? const DashboardPage() : const LoginPage();
      },
    );
  }
}