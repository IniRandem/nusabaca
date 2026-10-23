import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nusabacaukom/controllers/markah_provider.dart';
import 'package:nusabacaukom/views/detail/detail_page.dart';
import 'package:nusabacaukom/widgets/cerita_card.dart';

class MarkahPage extends StatelessWidget {
  const MarkahPage({super.key});

  @override
  Widget build(BuildContext context) {
    final m = context.watch<MarkahProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Markah Saya')),
      body: _isi(context, m),
    );
  }

  Widget _isi(BuildContext context, MarkahProvider m) {
    if (m.loading && m.daftar.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (m.error != null && m.daftar.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(m.error!),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => context.read<MarkahProvider>().muat(),
              child: const Text('Coba lagi'),
            ),
          ],
        ),
      );
    }
    if (m.daftar.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.bookmark_border, size: 64),
              SizedBox(height: 12),
              Text(
                'Belum ada cerita yang disimpan.\nTekan ikon markah di halaman cerita.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => context.read<MarkahProvider>().muat(),
      child: ListView.separated(
        itemCount: m.daftar.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, i) {
          final cerita = m.daftar[i];
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
              '${cerita.namaPenulis ?? '-'}  •  ${cerita.namaKategori ?? '-'}',
            ),
            trailing: IconButton(
              icon: Icon(
                Icons.bookmark,
                color: Theme.of(context).colorScheme.primary,
              ),
              tooltip: 'Hapus dari markah',
              onPressed: () => context.read<MarkahProvider>().toggle(cerita),
            ),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => DetailPage(cerita: cerita)),
            ),
          );
        },
      ),
    );
  }
}
