import 'dart:io';
import 'package:flutter/material.dart';
import 'package:nusabacaukom/models/cerita_model.dart';
import 'package:nusabacaukom/models/kategori_model.dart';
import 'package:nusabacaukom/services/cerita_service.dart';

class CeritaProvider extends ChangeNotifier {
  final _service = CeritaService();

  List<Kategori> _kategori = [];
  List<Cerita> _populer = [];
  List<Cerita> _daftar = []; // daftar utama (terbaru atau hasil filter genre)
  List<Cerita> _hasilCari = [];
  int? _kategoriDipilih; // null = semua genre
  bool _loading = false;
  bool _mencari = false;
  String? _error;

  //-----Penulis-----
  List<Cerita> _milik = [];
  bool _loadingMilik = false;
  bool _menyimpan = false;

  List<Cerita> get milik => _milik;
  bool get loadingMilik => _loadingMilik;
  bool get menyimpan => _menyimpan;
  //-----Pembaca-----
  List<Kategori> get kategori => _kategori;
  List<Cerita> get populer => _populer;
  List<Cerita> get daftar => _daftar;
  List<Cerita> get hasilCari => _hasilCari;
  int? get kategoriDipilih => _kategoriDipilih;
  bool get loading => _loading;
  bool get mencari => _mencari;
  String? get error => _error;

  String get namaKategoriDipilih {
    if (_kategoriDipilih == null) return 'Terbaru';
    return _kategori.firstWhere((k) => k.id == _kategoriDipilih).namaKategori;
  }

  Future<void> muatMilik({bool reset = false}) async {
    if (reset) _milik = [];
    _loadingMilik = true;
    notifyListeners();
    try {
      _milik = await _service.ambilMilikSendiri();
    } catch (e) {
      debugPrint('muatMilik error: $e');
    }
    _loadingMilik = false;
    notifyListeners();
  }

  Future<String?> simpanCerita({
    int? id,
    required int kategoriId,
    required String judul,
    required String sinopsis,
    required String isiCerita,
    File? coverBaru,
  }) async {
    _menyimpan = true;
    notifyListeners();
    try {
      // 1) Kalau ada cover baru, unggah dulu untuk mendapat URL-nya
      String? coverUrl;
      if (coverBaru != null) {
        coverUrl = await _service.uploadCover(coverBaru);
      }

      // 2) Simpan ke database
      if (id == null) {
        await _service.tambah(
          kategoriId: kategoriId,
          judul: judul,
          sinopsis: sinopsis,
          isiCerita: isiCerita,
          coverUrl: coverUrl,
        );
      } else {
        await _service.ubah(
          id: id,
          kategoriId: kategoriId,
          judul: judul,
          sinopsis: sinopsis,
          isiCerita: isiCerita,
          coverUrl: coverUrl, // null = cover lama dipertahankan
        );
      }

      // 3) Segarkan daftar Studio dan Beranda
      await muatMilik();
      await muat();
      return null;
    } catch (e) {
      debugPrint('simpanCerita error: $e');
      return 'Gagal menyimpan cerita. Periksa koneksi internet Anda.';
    } finally {
      _menyimpan = false;
      notifyListeners();
    }
  }

  // DELETE
  Future<String?> hapusCerita(int id) async {
    try {
      await _service.hapus(id);
      await muatMilik();
      await muat();
      return null;
    } catch (e) {
      debugPrint('hapusCerita error: $e');
      return 'Gagal menghapus cerita.';
    }
  }

  //Pembaca
  // Memuat semua data Beranda. Dipanggil saat aplikasi dibuka dan saat tarik-untuk-refresh.
  Future<void> muat() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _kategori = await _service.ambilKategori();
      _populer = await _service.ambilPopuler();
      _kategoriDipilih = null;
      _daftar = await _service.ambilTerbaru();
    } catch (e) {
      _error = 'Gagal memuat cerita. Periksa koneksi internet Anda.';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // id null berarti kembali ke "Semua"
  Future<void> pilihKategori(int? id) async {
    _kategoriDipilih = id;
    notifyListeners();
    try {
      _daftar = id == null
          ? await _service.ambilTerbaru()
          : await _service.ambilPerKategori(id);
    } catch (e) {
      _error = 'Gagal memuat cerita.';
    }
    notifyListeners();
  }

  Future<void> cari(String kata) async {
    // Buang karakter yang bisa merusak filter pencarian
    final bersih = kata.replaceAll(RegExp(r'[,()%]'), ' ').trim();
    if (bersih.isEmpty) {
      _hasilCari = [];
      notifyListeners();
      return;
    }
    _mencari = true;
    notifyListeners();
    try {
      _hasilCari = await _service.cari(bersih);
    } catch (e) {
      _hasilCari = [];
    }
    _mencari = false;
    notifyListeners();
  }

  void bersihkanCari() {
    _hasilCari = [];
    notifyListeners();
  }

  // Dipanggil saat pembaca menekan "Mulai Membaca"
  Future<void> tambahBaca(int idCerita) async {
    try {
      await _service.tambahBaca(idCerita);
    } catch (_) {
      // Gagal menghitung pembaca tidak boleh mengganggu pembaca
    }
  }
}
