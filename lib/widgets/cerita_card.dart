import 'package:flutter/material.dart';
import 'package:nusabacaukom/models/cerita_model.dart';

//gambar cover kalo ga ada url atau gagal dimuat
//tampilin kotak ama ikon buku
class CoverCerita extends StatelessWidget {
  final String? url;
  final double? width;
  final double? height;

  const CoverCerita({super.key, this.url, this.width, this.height});

  Widget _placeholder() => Container(
    width: width,
    height: height,
    color: Colors.teal.shade100,
    child: const Icon(Icons.menu_book_rounded, color: Colors.teal, size: 36),
  );

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) return _placeholder();
    return Image.network(
      url!,
      width: width,
      height: height,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => _placeholder(),
    );
  }
}

//buat kartu cerita: cover, judul dan nama penulis
class CeritaCard extends StatelessWidget {
  final Cerita cerita;
  final VoidCallback onTap;

  const CeritaCard({super.key, required this.cerita, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadiusGeometry.circular(12),
              child: SizedBox(
                width: double.infinity,
                child: CoverCerita(url: cerita.coverUrl),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            cerita.judul,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          Text(
            cerita.namaPenulis ?? '-',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
