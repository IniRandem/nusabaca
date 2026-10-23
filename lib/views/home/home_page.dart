import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nusabacaukom/controllers/auth_provider.dart';
import 'package:nusabacaukom/controllers/cerita_provider.dart';
import 'package:nusabacaukom/models/cerita_model.dart';
import 'package:nusabacaukom/views/detail/detail_page.dart';
import 'package:nusabacaukom/views/home/search_page.dart';
import 'package:nusabacaukom/widgets/cerita_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void _bukaDetail(BuildContext context, Cerita cerita) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DetailPage(cerita: cerita)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final c = context.watch<CeritaProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('NusaBaca'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Cari cerita',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SearchPage()),
            ),
          ),
        ],
      ),

      body: _isi(context, auth, c),
    );
  }

  Widget _isi(BuildContext context, AuthProvider auth, CeritaProvider c) {
    // 1) Sedang memuat pertama kali
    if (c.loading && c.daftar.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    // 2) Gagal memuat
    if (c.error != null && c.daftar.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(c.error!),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => context.read<CeritaProvider>().muat(),
              child: const Text('Coba lagi'),
            ),
          ],
        ),
      );
    }

    // 3) Tampilan normal. Tarik ke bawah untuk memuat ulang.
    return RefreshIndicator(
      onRefresh: () => context.read<CeritaProvider>().muat(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Halo, ${auth.profil?.namaPenulis ?? ''}',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const Text('Mau baca apa hari ini?'),
          const SizedBox(height: 20),

          // ----- Populer -----
          if (c.populer.isNotEmpty) ...[
            Text(
              'Cerita Populer',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 210,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: c.populer.length,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (context, i) => SizedBox(
                  width: 130,
                  child: CeritaCard(
                    cerita: c.populer[i],
                    onTap: () => _bukaDetail(context, c.populer[i]),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],

          // ----- Chip genre -----
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: const Text('Semua'),
                    selected: c.kategoriDipilih == null,
                    onSelected: (_) =>
                        context.read<CeritaProvider>().pilihKategori(null),
                  ),
                ),
                ...c.kategori.map(
                  (k) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(k.namaKategori),
                      selected: c.kategoriDipilih == k.id,
                      onSelected: (_) =>
                          context.read<CeritaProvider>().pilihKategori(k.id),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ----- Daftar utama -----
          Text(
            c.kategoriDipilih == null
                ? 'Cerita Terbaru'
                : 'Genre: ${c.namaKategoriDipilih}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),

          if (c.daftar.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(child: Text('Belum ada cerita di sini.')),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.62,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: c.daftar.length,
              itemBuilder: (context, i) => CeritaCard(
                cerita: c.daftar[i],
                onTap: () => _bukaDetail(context, c.daftar[i]),
              ),
            ),
        ],
      ),
    );
  }
}
