import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:nusabacaukom/controllers/cerita_provider.dart';
import 'package:nusabacaukom/models/cerita_model.dart';
import 'package:nusabacaukom/widgets/cerita_card.dart';

class FormCeritaPage extends StatefulWidget {
  final Cerita? cerita; // null = tambah baru, terisi = edit

  const FormCeritaPage({super.key, this.cerita});

  @override
  State<FormCeritaPage> createState() => _FormCeritaPageState();
}

class _FormCeritaPageState extends State<FormCeritaPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _judulCtrl;
  late final TextEditingController _sinopsisCtrl;
  late final TextEditingController _isiCtrl;
  int? _kategoriId;
  File? _coverBaru;

  bool get _modeEdit => widget.cerita != null;

  @override
  void initState() {
    super.initState();
    // Mode edit: isi form dengan data lama (sesuai Activity Diagram 4.3)
    final c = widget.cerita;
    _judulCtrl = TextEditingController(text: c?.judul ?? '');
    _sinopsisCtrl = TextEditingController(text: c?.sinopsis ?? '');
    _isiCtrl = TextEditingController(text: c?.isiCerita ?? '');
    _kategoriId = c?.kategoriId;
  }

  @override
  void dispose() {
    _judulCtrl.dispose();
    _sinopsisCtrl.dispose();
    _isiCtrl.dispose();
    super.dispose();
  }

  Future<void> _pilihCover() async {
    final hasil = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1000, // perkecil agar unggahan ringan
      imageQuality: 80,
    );
    if (hasil != null) {
      setState(() => _coverBaru = File(hasil.path));
    }
  }

  Future<void> _simpan() async {
    // Validasi formulir (sesuai Activity Diagram 4.2)
    if (!_formKey.currentState!.validate()) return;

    final error = await context.read<CeritaProvider>().simpanCerita(
      id: widget.cerita?.id,
      kategoriId: _kategoriId!,
      judul: _judulCtrl.text.trim(),
      sinopsis: _sinopsisCtrl.text.trim(),
      isiCerita: _isiCtrl.text.trim(),
      coverBaru: _coverBaru,
    );

    if (!mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    if (error != null) {
      messenger.showSnackBar(SnackBar(content: Text(error)));
    } else {
      Navigator.pop(context);
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            _modeEdit
                ? 'Cerita berhasil diperbarui'
                : 'Cerita berhasil dipublikasikan',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final kategori = context.watch<CeritaProvider>().kategori;
    final menyimpan = context.watch<CeritaProvider>().menyimpan;

    return Scaffold(
      appBar: AppBar(
        title: Text(_modeEdit ? 'Edit Cerita' : 'Tulis Cerita Baru'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ----- Cover -----
              Center(
                child: GestureDetector(
                  onTap: _pilihCover,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: _coverBaru != null
                        ? Image.file(
                            _coverBaru!,
                            width: 140,
                            height: 200,
                            fit: BoxFit.cover,
                          )
                        : CoverCerita(
                            url: widget.cerita?.coverUrl,
                            width: 140,
                            height: 200,
                          ),
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: _pilihCover,
                icon: const Icon(Icons.image_outlined),
                label: Text(
                  _coverBaru == null && widget.cerita?.coverUrl == null
                      ? 'Pilih cover (opsional)'
                      : 'Ganti cover',
                ),
              ),
              const SizedBox(height: 12),

              // ----- Judul -----
              TextFormField(
                controller: _judulCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Judul cerita',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Judul wajib diisi'
                    : null,
              ),
              const SizedBox(height: 16),

              // ----- Genre -----
              DropdownButtonFormField<int>(
                // ignore: deprecated_member_use
                value: _kategoriId,
                decoration: const InputDecoration(
                  labelText: 'Genre',
                  border: OutlineInputBorder(),
                ),
                items: kategori
                    .map(
                      (k) => DropdownMenuItem(
                        value: k.id,
                        child: Text(k.namaKategori),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _kategoriId = v),
                validator: (v) => v == null ? 'Pilih genre' : null,
              ),
              const SizedBox(height: 16),

              // ----- Sinopsis -----
              TextFormField(
                controller: _sinopsisCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Sinopsis',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // ----- Isi cerita -----
              TextFormField(
                controller: _isiCtrl,
                minLines: 8,
                maxLines: null, // tumbuh sesuai panjang tulisan
                keyboardType: TextInputType.multiline,
                decoration: const InputDecoration(
                  labelText: 'Isi cerita',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Isi cerita wajib diisi'
                    : null,
              ),
              const SizedBox(height: 24),

              FilledButton(
                onPressed: menyimpan ? null : _simpan,
                child: menyimpan
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(_modeEdit ? 'Simpan Perubahan' : 'Publikasikan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
