import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nusabacaukom/controllers/cerita_provider.dart';
import 'package:nusabacaukom/models/cerita_model.dart';
import 'package:nusabacaukom/views/studio/form_cerita_page.dart';
import 'package:nusabacaukom/widgets/cerita_card.dart';

class StudioPage extends StatefulWidget {
  const StudioPage({super.key});

  @override
  State<StudioPage> createState() => _StudioPageState();
}

class _StudioPageState extends State<StudioPage> {
  @override
  void initState() {
    super.initState();
    // Muat cerita milik sendiri begitu Studio dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CeritaProvider>().muatMilik(reset: true);
    });
  }

  void _bukaForm([Cerita? cerita]) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => FormCeritaPage(cerita: cerita)),
    );
  }

  // Dialog konfirmasi sebelum menghapus (sesuai Activity Diagram 4.4)
  Future<void> _konfirmasiHapus(Cerita cerita) async {
    final yakin = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus cerita?'),
        content: Text(
          '"${cerita.judul}" akan dihapus permanen dan tidak bisa dikembalikan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (yakin != true || !mounted) return;

    final error = await context.read<CeritaProvider>().hapusCerita(cerita.id);
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(error ?? 'Cerita berhasil dihapus')));
  }

  @override
  Widget build(BuildContext context) {
    final c = context.watch<CeritaProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Studio Penulis')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _bukaForm(),
        icon: const Icon(Icons.add),
        label: const Text('Tulis Cerita'),
      ),
      body: _isi(c),
    );
  }

  Widget _isi(CeritaProvider c) {
    if (c.loadingMilik && c.milik.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (c.milik.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text(
            'Kamu belum punya cerita.\nTekan "Tulis Cerita" untuk mulai!',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => context.read<CeritaProvider>().muatMilik(),
      child: ListView.separated(
        padding: const EdgeInsets.only(
          bottom: 90,
        ), // ruang agar tidak tertutup tombol
        itemCount: c.milik.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, i) {
          final cerita = c.milik[i];
          return ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: CoverCerita(url: cerita.coverUrl, width: 48, height: 64),
            ),
            title: Text(
              cerita.judul,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              '${cerita.namaKategori ?? '-'}  •  ${cerita.jumlahBaca} dibaca',
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'Edit',
                  onPressed: () => _bukaForm(cerita),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  tooltip: 'Hapus',
                  onPressed: () => _konfirmasiHapus(cerita),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
