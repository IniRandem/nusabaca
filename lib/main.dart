import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:nusabacaukom/controllers/auth_provider.dart';
import 'package:nusabacaukom/controllers/cerita_provider.dart';
import 'package:nusabacaukom/controllers/markah_provider.dart';
import 'package:nusabacaukom/controllers/theme_provider.dart';
import 'package:nusabacaukom/views/auth/login_page.dart';
import 'package:nusabacaukom/views/main_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://rfnutalgaxfixxogygpv.supabase.co', // isi dengan milik Anda
    // ignore: deprecated_member_use
    anonKey:
        'sb_publishable_0yTuc22If76jvZCnr_RVuA_SnV2Y99E', // isi dengan milik Anda
  );

  // Muat pilihan tema SEBELUM aplikasi tampil, supaya tidak
  // berkedip terang dulu lalu berubah gelap.
  final temaProvider = ThemeProvider();
  await temaProvider.muat();

  runApp(NusaBacaApp(temaProvider: temaProvider));
}

class NusaBacaApp extends StatelessWidget {
  final ThemeProvider temaProvider;

  const NusaBacaApp({super.key, required this.temaProvider});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..cekSesi()),
        ChangeNotifierProvider(create: (_) => CeritaProvider()..muat()),
        ChangeNotifierProvider(create: (_) => MarkahProvider()),
        ChangeNotifierProvider.value(value: temaProvider),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, tema, _) => MaterialApp(
          title: 'NusaBaca',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorSchemeSeed: Colors.teal,
            useMaterial3: true,
            brightness: Brightness.light,
          ),
          darkTheme: ThemeData(
            colorSchemeSeed: Colors.teal,
            useMaterial3: true,
            brightness: Brightness.dark,
          ),
          themeMode: tema.mode,
          home: const AuthGate(),
        ),
      ),
    );
  }
}

// Penjaga pintu: belum login ke Login, sudah login ke MainPage (navbar)
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (!auth.siapCek) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return auth.sudahLogin ? const MainPage() : const LoginPage();
  }
}
