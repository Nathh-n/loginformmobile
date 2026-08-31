import 'package:flutter/foundation.dart';
import 'package:forui/forui.dart';
import 'package:material_ui/material_ui.dart';
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
    // Pilih tema Forui: ukuran "touch" buat HP, "desktop" buat komputer.
    final (lightTheme, darkTheme) =
        const <TargetPlatform>{
          TargetPlatform.android,
          TargetPlatform.iOS,
          TargetPlatform.fuchsia,
        }.contains(defaultTargetPlatform)
        ? (FTheme.neutral.light.touch, FTheme.neutral.dark.touch)
        : (FTheme.neutral.light.desktop, FTheme.neutral.dark.desktop);

    return MaterialApp(
      title: 'Login Dashboard',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.light,
      supportedLocales: FLocalizations.supportedLocales,
      localizationsDelegates: FLocalizations.localizationsDelegates,
      theme: lightTheme.toApproximateMaterialTheme(),
      darkTheme: darkTheme.toApproximateMaterialTheme(),
      builder: (context, child) => FTheme(
        data: Theme.brightnessOf(context) == Brightness.light
            ? lightTheme
            : darkTheme,
        child: FToaster(child: FTooltipGroup(child: child!)),
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
          return const FScaffold(
            childPad: false,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final isSessionValid = snapshot.data ?? false;
        return isSessionValid ? const DashboardPage() : const LoginPage();
      },
    );
  }
}