class UserModel {
  final String id;
  final String email;
  final String namaPenulis;
  final String role; //reader atau author

  UserModel({
    required this.id,
    required this.email,
    required this.namaPenulis,
    required this.role,
  });

  //true kalo user nya penulis
  bool get isAuthor => role == 'author';

  //ngubah data dari supabase jadi objek userModel
  factory UserModel.fromMap(Map<String, dynamic> m) => UserModel(
    id: m['id'],
    email: m['email'],
    namaPenulis: m['nama_penulis'],
    role: m['role'] ?? 'reader',
  );
}
