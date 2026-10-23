import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nusabacaukom/models/cerita_model.dart';

class MarkahService {
  final _db = Supabase.instance.client;

  Future<List<Cerita>> ambilMarkah() async {
    final data = await _db
        .from('v_markah')
        .select()
        .eq('markah_user_id', _db.auth.currentUser!.id)
        .order('markah_at', ascending: false);
    return data.map<Cerita>((e) => Cerita.fromMap(e)).toList();
  }

  Future<void> tambah(int ceritaId) async {
    await _db.from('markah').insert({
      'user_id': _db.auth.currentUser!.id,
      'cerita_id': ceritaId,
    });
  }

  Future<void> hapus(int ceritaId) async {
    await _db
        .from('markah')
        .delete()
        .eq('user_id', _db.auth.currentUser!.id)
        .eq('cerita_id', ceritaId);
  }
}
