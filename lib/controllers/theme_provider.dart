import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const _kunci = 'tema';

  ThemeMode _mode = ThemeMode.system; // bawaan: ikut pengaturan HP
  ThemeMode get mode => _mode;

  // Membaca pilihan tema yang tersimpan di HP
  Future<void> muat() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tersimpan = prefs.getString(_kunci);
      _mode = ThemeMode.values.firstWhere(
        (m) => m.name == tersimpan,
        orElse: () => ThemeMode.system,
      );
    } catch (_) {
      _mode = ThemeMode.system;
    }
    notifyListeners();
  }

  Future<void> ubah(ThemeMode mode) async {
    _mode = mode;
    notifyListeners(); // tampilan langsung berganti
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kunci, mode.name);
    } catch (_) {
      // Gagal menyimpan tidak mengganggu pemakaian
    }
  }
}
