import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:nusabacaukom/controllers/cerita_provider.dart';
import 'package:nusabacaukom/models/cerita_model.dart';
import 'package:nusabacaukom/widgets/cerita_card.dart';
import 'package:nusabacaukom/services/dokumen_service.dart';

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

  bool _membaca = false; // true saat dokumen sedang dibaca
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

  Future<void> _imporDokumen() async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _membaca = true);

    try {
      final hasil = await DokumenService().pilihDanBaca();
      if (hasil == null || !mounted) return; // pengguna membatalkan

      // Kalau sudah ada tulisan, minta konfirmasi sebelum menimpa
      if (_isiCtrl.text.trim().isNotEmpty) {
        final ganti = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Ganti isi cerita?'),
            content: Text(
              'Isi yang sudah Anda ketik akan diganti dengan teks dari "${hasil.namaFile}".',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Batal'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Ganti'),
              ),
            ],
          ),
        );
        if (ganti != true || !mounted) return;
      }

      setState(() {
        _isiCtrl.text = hasil.teks;
        // Judul kosong? Pakai nama file sebagai saran
        if (_judulCtrl.text.trim().isEmpty) {
          _judulCtrl.text = hasil.judulSaran;
        }
      });

      messenger.showSnackBar(
        const SnackBar(
          content: Text(
            'Teks berhasil dimasukkan. Periksa dan rapikan sebelum dipublikasikan.',
          ),
        ),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _membaca = false);
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
              // ----- Impor dari dokumen -----
              OutlinedButton.icon(
                onPressed: _membaca ? null : _imporDokumen,
                icon: _membaca
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.upload_file),
                label: Text(
                  _membaca
                      ? 'Membaca dokumen...'
                      : 'Impor dari dokumen (.txt, .docx, .pdf)',
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Atau ketik langsung di bawah. Teks hasil impor bisa diedit.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 12),

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
