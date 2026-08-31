import 'package:forui/forui.dart';
import 'package:material_ui/material_ui.dart';
import '../repositories/auth_repository.dart';
import '../../dashboard/pages/dashboard_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'john@mail.com');
  final _passwordController = TextEditingController(text: 'changeme');
  final _authRepository = AuthRepository();

  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email wajib diisi';
    }
    final emailRegex = RegExp(r'^[\w\.\-]+@[\w\-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Format email tidak valid';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password wajib diisi';
    }
    if (value.length < 6) {
      return 'Password minimal 6 karakter';
    }
    return null;
  }

  Future<void> _handleLogin() async {
    final isFormValid = _formKey.currentState!.validate();
    if (!isFormValid) return;

    setState(() => _isLoading = true);

    try {
      await _authRepository.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const DashboardPage()),
      );
    } on AuthException catch (e) {
      if (!mounted) return;
      showFToast(
        context: context,
        variant: FToastVariant.destructive,
        title: const Text('Login Gagal'),
        description: Text(e.message),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FScaffold(
      childPad: false,
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(FLucideIcons.lockKeyhole, size: 64),
                  const SizedBox(height: 16),
                  Text(
                    'Masuk ke Akunmu',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 32),
                  FTextFormField.email(
                    control: FTextFieldControl.managed(
                      controller: _emailController,
                    ),
                    label: const Text('Email'),
                    hint: 'contoh@mail.com',
                    validator: _validateEmail,
                  ),
                  const SizedBox(height: 16),
                  FTextFormField.password(
                    control: FTextFieldControl.managed(
                      controller: _passwordController,
                    ),
                    label: const Text('Password'),
                    hint: 'Minimal 6 karakter',
                    validator: _validatePassword,
                  ),
                  const SizedBox(height: 24),
                  FButton(
                    onPress: _isLoading ? null : _handleLogin,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Login'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}