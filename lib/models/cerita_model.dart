class Cerita {
  final int id;
  final String userId;
  final int kategoriId;
  final String judul;
  final String? sinopsis;
  final String isiCerita;
  final String? coverUrl;
  final String? namaPenulis;
  final String? namaKategori;
  final int jumlahBaca;

  Cerita({
    required this.id,
    required this.userId,
    required this.kategoriId,
    required this.judul,
    this.sinopsis,
    required this.isiCerita,
    required this.coverUrl,
    required this.namaPenulis,
    this.namaKategori,
    this.jumlahBaca = 0,
  });

  factory Cerita.fromMap(Map<String, dynamic> m) => Cerita(
    id: m['id'],
    userId: m['user_id'],
    kategoriId: m['kategori_id'],
    judul: m['judul'],
    sinopsis: m['sinopsis'],
    isiCerita: m['isi_cerita'],
    coverUrl: m['cover_url'],
    namaPenulis: m['nama_penulis'],
    namaKategori: m['nama_kategori'],
    jumlahBaca: m['jumlah_baca'] ?? 0,
  );
}
