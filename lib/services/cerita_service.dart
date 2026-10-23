import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/cerita_model.dart';
import '../models/kategori_model.dart';

class CeritaService {
  final _db = Supabase.instance.client;

  // Mengubah daftar Map menjadi daftar Cerita
  List<Cerita> _keCerita(List<Map<String, dynamic>> data) =>
      data.map<Cerita>((e) => Cerita.fromMap(e)).toList();

  // ---------- READER ----------

  Future<List<Kategori>> ambilKategori() async {
    final data = await _db.from('kategori').select().order('id');
    return data.map<Kategori>((e) => Kategori.fromMap(e)).toList();
  }

  Future<List<Cerita>> ambilTerbaru() async {
    final data = await _db
        .from('v_cerita')
        .select()
        .order('created_at', ascending: false);
    return _keCerita(data);
  }

  Future<List<Cerita>> ambilPopuler() async {
    final data = await _db
        .from('v_cerita')
        .select()
        .order('jumlah_baca', ascending: false)
        .limit(10);
    return _keCerita(data);
  }

  Future<List<Cerita>> ambilPerKategori(int idKategori) async {
    final data = await _db
        .from('v_cerita')
        .select()
        .eq('kategori_id', idKategori)
        .order('created_at', ascending: false);
    return _keCerita(data);
  }

  // Mencari berdasarkan judul ATAU nama penulis
  Future<List<Cerita>> cari(String kata) async {
    final data = await _db
        .from('v_cerita')
        .select()
        .or('judul.ilike.%$kata%,nama_penulis.ilike.%$kata%');
    return _keCerita(data);
  }

  // Menambah jumlah_baca lewat fungsi tambah_baca di database
  Future<void> tambahBaca(int idCerita) async {
    await _db.rpc('tambah_baca', params: {'p_id': idCerita});
  }

  // ---------- AUTHOR (CRUD) ----------

  // READ: hanya cerita milik sendiri
  Future<List<Cerita>> ambilMilikSendiri() async {
    final data = await _db
        .from('v_cerita')
        .select()
        .eq('user_id', _db.auth.currentUser!.id)
        .order('created_at', ascending: false);
    return _keCerita(data);
  }

  // CREATE
  Future<void> tambah({
    required int kategoriId,
    required String judul,
    required String sinopsis,
    required String isiCerita,
    String? coverUrl,
  }) async {
    await _db.from('cerita').insert({
      'user_id': _db.auth.currentUser!.id,
      'kategori_id': kategoriId,
      'judul': judul,
      'sinopsis': sinopsis,
      'isi_cerita': isiCerita,
      'cover_url': coverUrl,
    });
  }

  // UPDATE
  Future<void> ubah({
    required int id,
    required int kategoriId,
    required String judul,
    required String sinopsis,
    required String isiCerita,
    String? coverUrl,
  }) async {
    await _db
        .from('cerita')
        .update({
          'kategori_id': kategoriId,
          'judul': judul,
          'sinopsis': sinopsis,
          'isi_cerita': isiCerita,
          // ignore: use_null_aware_elements
          if (coverUrl != null)
            'cover_url': coverUrl, // hanya kalau ada cover baru
        })
        .eq('id', id);
  }

  // DELETE
  Future<void> hapus(int id) async {
    await _db.from('cerita').delete().eq('id', id);
  }

  // ---------- STORAGE ----------

  // Mengunggah gambar cover, lalu mengembalikan URL publiknya
  Future<String> uploadCover(File file) async {
    final ekstensi = file.path.split('.').last;
    final namaFile =
        '${_db.auth.currentUser!.id}/${DateTime.now().millisecondsSinceEpoch}.$ekstensi';

    await _db.storage.from('cover').upload(namaFile, file);
    return _db.storage.from('cover').getPublicUrl(namaFile);
  }
}
