import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:file_picker/file_picker.dart';

class StrukPage extends StatelessWidget {
  final int penjualanid;
  final pw.Document pdf;

  const StrukPage({Key? key, required this.penjualanid, required this.pdf}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Struk Penjualan #$penjualanid')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('✅ Struk berhasil dibuat!', style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await _simpanPDF(pdf, penjualanid, context);
              },
              child: Text('Simpan PDF'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _simpanPDF(pw.Document pdf, int penjualanid, BuildContext context) async {
    try {
      String? path = await FilePicker.platform.saveFile(
        dialogTitle: 'Pilih lokasi untuk menyimpan struk',
        fileName: 'struk_penjualan_$penjualanid.pdf',
      );

      if (path != null) {
        final File file = File(path);
        await file.writeAsBytes(await pdf.save());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✅ Struk berhasil disimpan di: $path')),
        );
      } else {
        print("❌ Penyimpanan dibatalkan oleh pengguna.");
      }
    } catch (e) {
      print("❌ ERROR saat menyimpan PDF: $e");
    }
  }
}
