import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nusabacaukom/controllers/auth_provider.dart';
import 'package:nusabacaukom/controllers/cerita_provider.dart';
import 'package:nusabacaukom/controllers/markah_provider.dart';
import 'package:nusabacaukom/controllers/theme_provider.dart';

class ProfilPage extends StatelessWidget {
  const ProfilPage({super.key});

  Future<void> _editNama(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    // Controller ini sengaja tidak di-dispose manual: dialog masih
    // beranimasi menutup saat fungsi ini lanjut, dan dispose terlalu
    // cepat justru menimbulkan error.
    final ctrl = TextEditingController(text: auth.profil?.namaPenulis ?? '');

    final nama = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit nama tampilan'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            labelText: 'Nama tampilan / nama pena',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );

    if (nama == null || nama.isEmpty || !context.mounted) return;
    if (nama == auth.profil?.namaPenulis) return; // tidak ada perubahan

    final messenger = ScaffoldMessenger.of(context);
    final cerita = context.read<CeritaProvider>();
    final error = await auth.ubahNama(nama);

    if (error == null) {
      // Muat ulang katalog supaya nama penulis di cerita ikut berubah
      cerita.muat();
    }
    messenger.showSnackBar(
      SnackBar(content: Text(error ?? 'Nama berhasil diperbarui')),
    );
  }

  Future<void> _keluar(BuildContext context) async {
    final yakin = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Keluar dari akun?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );

    if (yakin != true || !context.mounted) return;

    context.read<MarkahProvider>().bersihkan();
    await context.read<AuthProvider>().logout();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final tema = context.watch<ThemeProvider>();
    final profil = auth.profil;

    final nama = profil?.namaPenulis ?? '-';
    final huruf = nama.isNotEmpty ? nama[0].toUpperCase() : '?';

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ----- Identitas -----
          Center(
            child: CircleAvatar(
              radius: 44,
              child: Text(huruf, style: const TextStyle(fontSize: 36)),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            nama,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          Text(
            profil?.email ?? '',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          Center(
            child: Chip(
              avatar: Icon(
                auth.isAuthor ? Icons.edit : Icons.menu_book,
                size: 18,
              ),
              label: Text(auth.isAuthor ? 'Penulis' : 'Pembaca'),
            ),
          ),
          const SizedBox(height: 16),

          // ----- Akun -----
          Card(
            child: ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('Edit nama tampilan'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _editNama(context),
            ),
          ),
          const SizedBox(height: 16),

          // ----- Tema -----
          Text(
            'Tampilan aplikasi',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          SegmentedButton<ThemeMode>(
            segments: const [
              ButtonSegment(
                value: ThemeMode.light,
                icon: Icon(Icons.light_mode),
                label: Text('Terang'),
              ),
              ButtonSegment(
                value: ThemeMode.dark,
                icon: Icon(Icons.dark_mode),
                label: Text('Gelap'),
              ),
              ButtonSegment(
                value: ThemeMode.system,
                icon: Icon(Icons.brightness_auto),
                label: Text('Sistem'),
              ),
            ],
            selected: {tema.mode},
            onSelectionChanged: (s) =>
                context.read<ThemeProvider>().ubah(s.first),
          ),
          const SizedBox(height: 24),

          // ----- Keluar -----
          Card(
            child: ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Keluar', style: TextStyle(color: Colors.red)),
              onTap: () => _keluar(context),
            ),
          ),
        ],
      ),
    );
  }
}
