import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nusabacaukom/models/cerita_model.dart';

class ReaderPage extends StatefulWidget {
  final Cerita cerita;

  const ReaderPage({super.key, required this.cerita});

  @override
  State<ReaderPage> createState() => _ReaderPageState();
}

class _ReaderPageState extends State<ReaderPage> {
  double _ukuran = 18; // ukuran huruf, bisa diubah pembaca

  void _ubahUkuran(double delta) {
    setState(() => _ukuran = (_ukuran + delta).clamp(14, 28));
  }

  @override
  Widget build(BuildContext context) {
    final cerita =
        widget.cerita; // 'widget' = data dari kelas ReaderPage di atas

    return Scaffold(
      appBar: AppBar(
        title: Text(cerita.judul, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            icon: const Icon(Icons.text_decrease),
            tooltip: 'Perkecil huruf',
            onPressed: () => _ubahUkuran(-2),
          ),
          IconButton(
            icon: const Icon(Icons.text_increase),
            tooltip: 'Perbesar huruf',
            onPressed: () => _ubahUkuran(2),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              cerita.judul,
              style: GoogleFonts.merriweather(
                fontSize: _ukuran + 6,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Oleh ${cerita.namaPenulis ?? '-'}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const Divider(height: 32),
            SelectableText(
              cerita.isiCerita,
              style: GoogleFonts.merriweather(fontSize: _ukuran, height: 1.8),
            ),
          ],
        ),
      ),
    );
  }
}
