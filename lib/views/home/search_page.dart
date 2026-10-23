import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nusabacaukom/controllers/cerita_provider.dart';
import 'package:nusabacaukom/views/detail/detail_page.dart';
import 'package:nusabacaukom/widgets/cerita_card.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _ctrl = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    // Kosongkan sisa hasil pencarian sebelumnya
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CeritaProvider>().bersihkanCari();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  // Tunggu 0,4 detik setelah pengguna berhenti mengetik, baru mencari
  void _onChanged(String teks) {
    setState(() {}); // agar tampilan tahu apakah kolom kosong atau tidak
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      context.read<CeritaProvider>().cari(teks);
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.watch<CeritaProvider>();
    final adaKata = _ctrl.text.trim().isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _ctrl,
          autofocus: true,
          onChanged: _onChanged,
          decoration: const InputDecoration(
            hintText: 'Cari judul atau nama penulis...',
            border: InputBorder.none,
          ),
        ),
      ),
      body: _isi(c, adaKata),
    );
  }

  Widget _isi(CeritaProvider c, bool adaKata) {
    if (!adaKata) {
      return const Center(child: Text('Ketik judul cerita atau nama penulis'));
    }
    if (c.mencari) {
      return const Center(child: CircularProgressIndicator());
    }
    if (c.hasilCari.isEmpty) {
      return const Center(child: Text('Tidak ada cerita yang ditemukan'));
    }
    return ListView.separated(
      itemCount: c.hasilCari.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final cerita = c.hasilCari[i];
        return ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: CoverCerita(url: cerita.coverUrl, width: 48, height: 64),
          ),
          title: Text(cerita.judul),
          subtitle: Text(
            '${cerita.namaPenulis ?? '-'}  •  ${cerita.namaKategori ?? '-'}',
          ),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => DetailPage(cerita: cerita)),
          ),
        );
      },
    );
  }
}
