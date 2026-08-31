import 'dart:async';
import 'package:forui/forui.dart';
import 'package:material_ui/material_ui.dart';
import '../../../core/storage/session_manager.dart';
import '../../auth/repositories/auth_repository.dart';
import '../../auth/pages/login_page.dart';
import '../../product_list/controllers/product_list_controller.dart';
import '../../product_list/pages/product_list_page.dart';
import '../../upload/controllers/upload_controller.dart';
import '../../upload/pages/upload_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final _authRepository = AuthRepository();
  final _uploadController = UploadController();
  final _productListController = ProductListController();
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
    _uploadController.dispose();
    _productListController.dispose();
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
    final confirmed = await _confirmLogout();
    if (!confirmed) return;

    await _authRepository.logout();
    await _goToLogin();
  }

  Future<bool> _confirmLogout() async {
    final confirmed = await showFDialog<bool>(
      context: context,
      builder: (context, style, animation) => FDialog(
        animation: animation,
        builder: (context, style) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Keluar dari aplikasi?',
                style: style.titleTextStyle,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: FButton(
                      variant: FButtonVariant.outline,
                      onPress: () => Navigator.pop(context, false),
                      child: const Text('Batal'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FButton(
                      variant: FButtonVariant.destructive,
                      onPress: () => Navigator.pop(context, true),
                      child: const Text('Logout'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    return confirmed ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final tabTitles = ['Upload Gambar', 'Daftar Produk'];

    return FScaffold(
      header: FHeader(
        title: Text(tabTitles[_currentTab]),
        suffixes: [
          FHeaderAction(
            icon: const Icon(FLucideIcons.logOut),
            semanticsTooltip: 'Logout',
            onPress: _handleLogout,
          ),
        ],
      ),
      footer: FBottomNavigationBar(
        index: _currentTab,
        onChange: (index) => setState(() => _currentTab = index),
        children: const [
          FBottomNavigationBarItem(
            icon: Icon(FLucideIcons.uploadCloud),
            label: Text('Upload'),
          ),
          FBottomNavigationBarItem(
            icon: Icon(FLucideIcons.list),
            label: Text('Produk'),
          ),
        ],
      ),
      child: _buildTabContent(),
    );
  }

  Widget _buildTabContent() {
    switch (_currentTab) {
      case 0:
        return UploadPage(controller: _uploadController);
      case 1:
        return ProductListPage(controller: _productListController);
      default:
        return const SizedBox.shrink();
    }
  }
}