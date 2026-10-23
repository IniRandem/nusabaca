import 'dart:convert';
import 'package:docx_to_text/docx_to_text.dart';
import 'package:file_picker/file_picker.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class HasilDokumen {
  final String namaFile;
  final String teks;

  HasilDokumen(this.namaFile, this.teks);

  // Nama file tanpa ekstensi, dipakai sebagai saran judul
  String get judulSaran {
    final titik = namaFile.lastIndexOf('.');
    final tanpaEkstensi = titik > 0 ? namaFile.substring(0, titik) : namaFile;
    return tanpaEkstensi.replaceAll(RegExp(r'[_-]+'), ' ').trim();
  }
}

class DokumenService {
  static const int _batasBytes = 5 * 1024 * 1024; // 5 MB
  static const int _batasKarakter = 100000;

  // Mengembalikan null kalau pengguna membatalkan pilihan file.
  // Melempar Exception dengan pesan ramah kalau gagal.
  Future<HasilDokumen?> pilihDanBaca() async {
    final hasil = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt', 'docx', 'pdf'],
      withData: true, // isi file langsung dimuat ke memori
    );
    if (hasil == null || hasil.files.isEmpty) return null;

    final file = hasil.files.single;
    final bytes = file.bytes;
    if (bytes == null) throw Exception('File tidak dapat dibaca.');
    if (bytes.length > _batasBytes) {
      throw Exception('Ukuran file terlalu besar (maksimal 5 MB).');
    }

    final ekstensi = (file.extension ?? '').toLowerCase();
    String teks;

    try {
      switch (ekstensi) {
        case 'txt':
          teks = _rapikan(utf8.decode(bytes, allowMalformed: true));
          break;
        case 'docx':
          teks = _rapikanDocx(docxToText(bytes));
          break;
        case 'pdf':
          final dokumen = PdfDocument(inputBytes: bytes);
          final mentah = PdfTextExtractor(dokumen).extractText();
          dokumen.dispose();
          teks = _rapikanPdf(mentah);
          break;
        default:
          throw Exception('Format file tidak didukung.');
      }
    } on Exception {
      rethrow;
    } catch (_) {
      throw Exception(
        'File tidak dapat dibaca. Pastikan file tidak rusak atau diberi password.',
      );
    }

    if (teks.isEmpty) {
      throw Exception(
        'Tidak ada teks yang bisa dibaca. Jika ini PDF hasil scan (berupa gambar), teksnya tidak bisa diambil.',
      );
    }
    if (teks.length > _batasKarakter) {
      throw Exception('Dokumen terlalu panjang (maksimal 100.000 karakter).');
    }

    return HasilDokumen(file.name, teks);
  }

  // Samakan jenis baris baru, buang spasi berlebih, maksimal 1 baris kosong
  String _rapikan(String teks) {
    return teks
        .replaceAll('\r\n', '\n')
        .replaceAll('\r', '\n')
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .trim();
  }

  // Word: tiap paragraf dipisahkan satu baris kosong
  String _rapikanDocx(String teks) {
    final paragraf = _rapikan(
      teks,
    ).split('\n').map((b) => b.trim()).where((b) => b.isNotEmpty);
    return paragraf.join('\n\n');
  }

  // PDF: baris yang terpotong lebar halaman digabung lagi menjadi kalimat utuh.
  // Baris kosong dipertahankan sebagai batas paragraf.
  String _rapikanPdf(String teks) {
    final bersih = _rapikan(teks);
    return bersih
        .split('\n\n')
        .map(
          (p) => p
              .split('\n')
              .map((b) => b.trim())
              .where((b) => b.isNotEmpty)
              .join(' '),
        )
        .where((p) => p.isNotEmpty)
        .join('\n\n');
  }
}
