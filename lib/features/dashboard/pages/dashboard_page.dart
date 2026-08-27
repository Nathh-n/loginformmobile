import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/storage/session_manager.dart';
import '../../auth/repositories/auth_repository.dart';
import '../../auth/pages/login_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final _authRepository = AuthRepository();
  int _currentTab = 0;
  Timer? _sessionCheckTimer;

  @override
  void initState() {
    super.initState();
    // Cek tiap 1 menit selama Dashboard terbuka: kalau sesi udah
    // lewat 4 jam, paksa balik ke Login walau app gak pernah ditutup.
    _sessionCheckTimer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => _checkSessionStillValid(),
    );
  }

  @override
  void dispose() {
    _sessionCheckTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkSessionStillValid() async {
    final isValid = await SessionManager.instance.isSessionValid();
    if (!isValid && mounted) {
      _sessionCheckTimer?.cancel();
      await _goToLogin();
    }
  }

  Future<void> _goToLogin() async {
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  Future<void> _handleLogout() async {
    await _authRepository.logout();
    await _goToLogin();
  }

  @override
  Widget build(BuildContext context) {
    final tabTitles = ['Upload Gambar', 'Daftar Produk'];

    return Scaffold(
      appBar: AppBar(
        title: Text(tabTitles[_currentTab]),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: _buildTabContent(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentTab,
        onDestinationSelected: (index) => setState(() => _currentTab = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.upload_outlined),
            label: 'Upload',
          ),
          NavigationDestination(
            icon: Icon(Icons.list_alt_outlined),
            label: 'Produk',
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    // Placeholder sementara. Nanti diganti UploadPage() & ProductListPage()
    // begitu 2 fitur itu udah kita buat.
    switch (_currentTab) {
      case 0:
        return const Center(child: Text('Halaman Upload (belum dibuat)'));
      case 1:
        return const Center(child: Text('Halaman Daftar Produk (belum dibuat)'));
      default:
        return const SizedBox.shrink();
    }
  }
}