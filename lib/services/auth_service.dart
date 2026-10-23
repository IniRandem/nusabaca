import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class AuthService {
  final _db = Supabase.instance.client;

  //user yang lagi login (jadi null kalo blom login)
  User? get currentUser => _db.auth.currentUser;

  Future<void> register({
    required String email,
    required String password,
    required String nama,
    required String role,
  }) async {
    //"Data" nya nanti dikirim sebagai metadata,
    //trigger handle_new_user di database membacanya
    //buat mengisi nama_penilis dan role di tabel users.
    await _db.auth.signUp(
      email: email,
      password: password,
      data: {'nama_penulis': nama, 'role': role},
    );
  }

  Future<void> login({required String email, required String password}) async {
    await _db.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> logout() async {
    await _db.auth.signOut();
  }

  //ini buat ngambil profil (nama dan role) dari tabel users
  Future<UserModel?> ambilProfil() async {
    final user = currentUser;
    if (user == null) return null;

    final data = await _db
        .from('users')
        .select()
        .eq('id', user.id)
        .maybeSingle();
    if (data == null) return null;
    return UserModel.fromMap(data);
  }
}
