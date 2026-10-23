import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nusabacaukom/models/user_model.dart';
import 'package:nusabacaukom/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final _service = AuthService();

  UserModel? _profil; //data user yang sedang login
  bool _loading = false; //true saat nungguin proses login/register
  bool _siapCek = false; //true setelah pengecekan sesi awal selesai

  UserModel? get profil => _profil;
  bool get loading => _loading;
  bool get siapCek => _siapCek;
  bool get sudahLogin => _profil != null;
  bool get isAuthor => _profil?.isAuthor ?? false;

  //dipanggil sekali pas apk dibuka: "apa masih ada sesi login?"

  Future<void> cekSesi() async {
    try {
      _profil = await _service.ambilProfil();
    } catch (_) {
      _profil = null;
    }
    _siapCek = true;
    notifyListeners();
  }

  //ngembaliin null kalo sukses, atau ga teks pesan error kalo gagal

  Future<String?> login(String email, String password) async {
    _loading = true;
    notifyListeners();
    try {
      await _service.login(email: email, password: password);
      _profil = await _service.ambilProfil();
      return null;
    } on AuthException catch (e) {
      return _terjemah(e.message);
    } catch (_) {
      return 'Terjadi kesalahan. Periksa koneksi internet Anda.';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<String?> register({
    required String nama,
    required String email,
    required String password,
    required String role,
  }) async {
    _loading = true;
    notifyListeners();
    try {
      await _service.register(
        email: email,
        password: password,
        nama: nama,
        role: role,
      );
      _profil = await _service.ambilProfil();
      if (_profil == null) {
        // Terjadi kalau "Confirm email" di Supabase masih aktif
        return 'Akun dibuat. Silakan verifikasi email Anda, lalu login.';
      }
      return null;
    } on AuthException catch (e) {
      return _terjemah(e.message);
    } catch (_) {
      return 'Terjadi kesalahan. Periksa koneksi internet Anda.';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _service.logout();
    _profil = null;
    notifyListeners();
  }

  // Menerjemahkan pesan error umum dari Supabase ke bahasa Indonesia
  String _terjemah(String pesan) {
    final p = pesan.toLowerCase();
    if (p.contains('invalid login')) return 'Email atau password salah.';
    if (p.contains('already registered')) return 'Email sudah terdaftar.';
    if (p.contains('password should be')) return 'Password minimal 6 karakter.';
    if (p.contains('valid email') || p.contains('invalid')) {
      return 'Format email tidak valid.';
    }
    return pesan;
  }
}
