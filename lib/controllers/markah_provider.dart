import 'package:flutter/material.dart';
import 'package:nusabacaukom/models/cerita_model.dart';
import 'package:nusabacaukom/services/markah_service.dart';

class MarkahProvider extends ChangeNotifier {
  final _service = MarkahService();

  List<Cerita> _daftar = [];
  bool _loading = false;
  String? _error;

  List<Cerita> get daftar => _daftar;
  bool get loading => _loading;
  String? get error => _error;

  // Apakah cerita ini sudah dimarkah? (dipakai untuk ikon di Detail)
  bool sudahDimarkah(int idCerita) => _daftar.any((c) => c.id == idCerita);

  Future<void> muat() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _daftar = await _service.ambilMarkah();
    } catch (e) {
      debugPrint('muat markah error: $e');
      _error = 'Gagal memuat markah. Periksa koneksi internet Anda.';
    }
    _loading = false;
    notifyListeners();
  }

  // Simpan kalau belum dimarkah, hapus kalau sudah.
  // Tampilan diubah dulu (terasa instan), lalu dikirim ke database.
  // Kalau gagal, perubahan dibatalkan.
  Future<String?> toggle(Cerita cerita) async {
    final sudah = sudahDimarkah(cerita.id);

    if (sudah) {
      _daftar = _daftar.where((c) => c.id != cerita.id).toList();
    } else {
      _daftar = [cerita, ..._daftar];
    }
    notifyListeners();

    try {
      if (sudah) {
        await _service.hapus(cerita.id);
      } else {
        await _service.tambah(cerita.id);
      }
      return null;
    } catch (e) {
      debugPrint('toggle markah error: $e');
      // Batalkan perubahan tampilan
      if (sudah) {
        _daftar = [cerita, ..._daftar];
      } else {
        _daftar = _daftar.where((c) => c.id != cerita.id).toList();
      }
      notifyListeners();
      return 'Gagal memperbarui markah.';
    }
  }

  // Dipanggil saat logout agar markah akun lain tidak terlihat
  void bersihkan() {
    _daftar = [];
    _error = null;
    notifyListeners();
  }
}
