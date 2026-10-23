import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nusabacaukom/controllers/cerita_provider.dart';
import 'controllers/auth_provider.dart';
import 'views/auth/login_page.dart';
import 'views/home/home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://rfnutalgaxfixxogygpv.supabase.co',
    // ignore: deprecated_member_use
    anonKey: 'sb_publishable_0yTuc22If76jvZCnr_RVuA_SnV2Y99E',
  );

  runApp(const NusaBacaApp());
}

class NusaBacaApp extends StatelessWidget {
  const NusaBacaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // ..cekSesi() langsung dijalankan saat Provider dibuat
        ChangeNotifierProvider(create: (_) => AuthProvider()..cekSesi()),
        ChangeNotifierProvider(create: (_) => CeritaProvider()..muat()),
        // CeritaProvider akan ditambahkan di Tahap 6
      ],
      child: MaterialApp(
        title: 'NusaBaca',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
        home: const AuthGate(),
      ),
    );
  }
}

// "Penjaga pintu": menentukan layar pertama berdasarkan status login
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (!auth.siapCek) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return auth.sudahLogin ? const HomePage() : const LoginPage();
  }
}
