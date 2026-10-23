import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nusabacaukom/controllers/cerita_provider.dart';
import 'package:nusabacaukom/models/cerita_model.dart';
import 'package:nusabacaukom/views/detail/reader_page.dart';
import 'package:nusabacaukom/widgets/cerita_card.dart';
import 'package:nusabacaukom/controllers/markah_provider.dart';

class DetailPage extends StatelessWidget {
  final Cerita cerita;

  const DetailPage({super.key, required this.cerita});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context).textTheme;
    final tersimpan = context.watch<MarkahProvider>().sudahDimarkah(cerita.id);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Cerita'),
        actions: [
          IconButton(
            icon: Icon(tersimpan ? Icons.bookmark : Icons.bookmark_border),
            tooltip: tersimpan ? 'Hapus dari markah' : 'Simpan ke markah',
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              final error = await context.read<MarkahProvider>().toggle(cerita);
              messenger.showSnackBar(
                SnackBar(
                  content: Text(
                    error ??
                        (tersimpan
                            ? 'Dihapus dari markah'
                            : 'Disimpan ke markah'),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CoverCerita(
                  url: cerita.coverUrl,
                  width: 160,
                  height: 230,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(cerita.judul, style: tema.headlineSmall),
            const SizedBox(height: 4),
            Text('Oleh ${cerita.namaPenulis ?? '-'}', style: tema.bodyLarge),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                Chip(
                  avatar: const Icon(Icons.category, size: 18),
                  label: Text(cerita.namaKategori ?? '-'),
                ),
                Chip(
                  avatar: const Icon(Icons.visibility, size: 18),
                  label: Text('${cerita.jumlahBaca} dibaca'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('Sinopsis', style: tema.titleMedium),
            const SizedBox(height: 6),
            Text(
              (cerita.sinopsis == null || cerita.sinopsis!.isEmpty)
                  ? 'Belum ada sinopsis.'
                  : cerita.sinopsis!,
              style: tema.bodyLarge?.copyWith(height: 1.5),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton.icon(
            icon: const Icon(Icons.menu_book),
            label: const Text('Mulai Membaca'),
            onPressed: () {
              // Tambah jumlah baca (tidak perlu ditunggu), lalu buka layar baca
              context.read<CeritaProvider>().tambahBaca(cerita.id);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ReaderPage(cerita: cerita)),
              );
            },
          ),
        ),
      ),
    );
  }
}
