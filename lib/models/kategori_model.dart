class Kategori {
  final int id;
  final String namaKategori;

  Kategori({required this.id, required this.namaKategori});

  factory Kategori.fromMap(Map<String, dynamic> m) =>
      Kategori(id: m['id'], namaKategori: m['nama_kategori']);
}
