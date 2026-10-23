import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nusabacaukom/controllers/auth_provider.dart';
import 'package:nusabacaukom/controllers/markah_provider.dart';
import 'package:nusabacaukom/views/home/home_page.dart';
import 'package:nusabacaukom/views/markah/markah_page.dart';
import 'package:nusabacaukom/views/profil/profil_page.dart';
import 'package:nusabacaukom/views/studio/studio_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    // Muat markah milik user yang baru login
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MarkahProvider>().muat();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isAuthor = context.watch<AuthProvider>().isAuthor;

    // Tab Studio hanya ada untuk Penulis
    final halaman = <Widget>[
      const HomePage(),
      const MarkahPage(),
      if (isAuthor) const StudioPage(),
      const ProfilPage(),
    ];

    final tujuan = <NavigationDestination>[
      const NavigationDestination(
        icon: Icon(Icons.home_outlined),
        selectedIcon: Icon(Icons.home),
        label: 'Beranda',
      ),
      const NavigationDestination(
        icon: Icon(Icons.bookmark_border),
        selectedIcon: Icon(Icons.bookmark),
        label: 'Markah',
      ),
      if (isAuthor)
        const NavigationDestination(
          icon: Icon(Icons.edit_note_outlined),
          selectedIcon: Icon(Icons.edit_note),
          label: 'Studio',
        ),
      const NavigationDestination(
        icon: Icon(Icons.person_outline),
        selectedIcon: Icon(Icons.person),
        label: 'Profil',
      ),
    ];

    final index = _index.clamp(0, halaman.length - 1);

    return Scaffold(
      // IndexedStack menyimpan semua halaman, jadi posisi gulir
      // dan data tidak hilang saat pindah tab.
      body: IndexedStack(index: index, children: halaman),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: tujuan,
      ),
    );
  }
}
