import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:ukk_ujian/homepage.dart';
import 'struk.dart';
import 'dart:io'; // ✅ Tambahkan ini
import 'package:file_picker/file_picker.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:html' as html;
import 'dart:typed_data';

class PembayaranPage extends StatefulWidget {
  @override
  _PembayaranPageState createState() => _PembayaranPageState();
}

class _PembayaranPageState extends State<PembayaranPage> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<Map<String, dynamic>> produkList = [];
  List<Map<String, dynamic>> filteredProdukList = [];
  List<Map<String, dynamic>> pelangganList = [];
  Map<int, int> jumlahBeli = {};
  String? selectedPelanggan;
  TextEditingController searchController = TextEditingController();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProduk();
    fetchPelanggan();
  }

  Future<void> fetchProduk() async {
    final response = await supabase.from('produk').select();
    setState(() {
      produkList = response
          .map((item) => {
                'produkid': item['produkid'],
                'namaproduk': item['namaproduk'],
                'harga': item['harga'],
                'stok': item['stok'],
              })
          .toList();
      filteredProdukList = List.from(produkList);
      isLoading = false;
    });
  }

  Future<void> fetchPelanggan() async {
    final response = await supabase.from('pelanggan').select();
    setState(() {
      pelangganList = response
          .map((item) => {
                'pelangganid': item['pelangganid'],
                'namapelanggan': item['namapelanggan'],
              })
          .toList();
    });
  }

  Future<void> generatePDF(
      BuildContext context,
      int penjualanid,
      String namaPelanggan,
      List<Map<String, dynamic>> produkDibeli,
      int totalTanpaDiskon,
      int diskon,
      int pajak,
      int totalBayar) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');

    pdf.addPage(
      pw.Page(
        margin: pw.EdgeInsets.all(24),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Center(
                child: pw.Text(
                  "TOKO Jul",
                  style: pw.TextStyle(
                      fontSize: 22, fontWeight: pw.FontWeight.bold),
                ),
              ),
              pw.SizedBox(height: 5),
              pw.Center(
                child: pw.Text(
                  "Jl. Permata jingga",
                  style: pw.TextStyle(fontSize: 12),
                ),
              ),
              pw.Divider(),

              // Informasi Transaksi
              pw.Text("No. Struk: #$penjualanid",
                  style: pw.TextStyle(fontSize: 14)),
              pw.Text("Tanggal: ${dateFormat.format(DateTime.now())}",
                  style: pw.TextStyle(fontSize: 14)),
              pw.Text("Pelanggan: $namaPelanggan",
                  style: pw.TextStyle(fontSize: 14)),
              pw.SizedBox(height: 10),

              // Daftar Produk
              pw.Text("Detail Pembelian:",
                  style: pw.TextStyle(
                      fontSize: 14, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 5),
              pw.Table.fromTextArray(
                context: context,
                headers: ["Produk", "Jumlah", "Harga", "Subtotal"],
                data: produkDibeli
                    .map((produk) => [
                          produk['namaproduk'],
                          produk['jumlah'].toString(),
                          "Rp ${produk['harga']}",
                          "Rp ${produk['subtotal']}"
                        ])
                    .toList(),
              ),
              pw.Divider(),

              // Total Pembayaran
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text("Total: Rp $totalTanpaDiskon",
                        style: pw.TextStyle(
                            fontSize: 14, fontWeight: pw.FontWeight.bold)),
                    pw.Text("Diskon (3%): -Rp $diskon",
                        style: pw.TextStyle(fontSize: 12)),
                    pw.Text("Pajak (2%): +Rp $pajak",
                        style: pw.TextStyle(fontSize: 12)),
                    pw.Divider(),
                    pw.Text("Total Bayar: Rp $totalBayar",
                        style: pw.TextStyle(
                            fontSize: 16, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
              ),
              pw.SizedBox(height: 10),

              // Footer
              pw.Center(
                child: pw.Text(
                  "Terima kasih telah berbelanja di TOKO XYZ",
                  style: pw.TextStyle(
                      fontSize: 12, fontStyle: pw.FontStyle.italic),
                ),
              ),
            ],
          );
        },
      ),
    );

    // Simpan dan Download PDF
    final Uint8List bytes = await pdf.save();
    final blob = html.Blob([bytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute("download", "struk_penjualan_$penjualanid.pdf")
      ..click();
    html.Url.revokeObjectUrl(url);
  }

  void filterProduk(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredProdukList = List.from(produkList);
      });
    } else {
      setState(() {
        filteredProdukList = produkList
            .where((item) =>
                item['namaproduk'].toLowerCase().contains(query.toLowerCase()))
            .toList();
      });
    }
  }

  void tambahProduk(int index) {
    int produkId = filteredProdukList[index]['produkid'];
    int stok = filteredProdukList[index]['stok'];

    setState(() {
      jumlahBeli[produkId] = (jumlahBeli[produkId] ?? 0) + 1;
      if (jumlahBeli[produkId]! > stok) {
        jumlahBeli[produkId] = stok;
        showDialogStokHabis();
      }
    });
  }

  void kurangiProduk(int index) {
    int produkId = filteredProdukList[index]['produkid'];

    setState(() {
      if (jumlahBeli.containsKey(produkId) && jumlahBeli[produkId]! > 0) {
        jumlahBeli[produkId] = jumlahBeli[produkId]! - 1;
        if (jumlahBeli[produkId] == 0) {
          jumlahBeli.remove(produkId);
        }
      }
    });
  }

  void showDialogStokHabis() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Stok Tidak Mencukupi'),
        content: Text('Jumlah produk yang diminta melebihi stok tersedia!'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: Text('OK')),
        ],
      ),
    );
  }

  void showDetailTransaksi() {
    if (selectedPelanggan == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Silakan pilih pelanggan terlebih dahulu!'),
            backgroundColor: Colors.red),
      );
      return;
    }

    if (jumlahBeli.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Silakan pilih produk untuk dibeli!'),
            backgroundColor: Colors.red),
      );
      return;
    }

    String namaPelanggan = pelangganList.firstWhere((pelanggan) =>
        pelanggan['pelangganid'].toString() ==
        selectedPelanggan)['namapelanggan'];

    String tanggal = DateFormat('yyyy-MM-dd').format(DateTime.now());

    int totalTanpaDiskon = 0;
    jumlahBeli.forEach((id, jumlah) {
      var produk = produkList.firstWhere((item) => item['produkid'] == id);
      totalTanpaDiskon += (produk['harga'] as num).toInt() * jumlah;
    });

    int diskon = (totalTanpaDiskon * 3) ~/ 100; // Diskon 3%
    int totalSetelahDiskon = totalTanpaDiskon - diskon;
    int pajak = (totalSetelahDiskon * 2) ~/ 100; // Pajak 2%
    int totalBayar = totalSetelahDiskon + pajak;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Konfirmasi Pembayaran'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Nama Pelanggan: $namaPelanggan'),
            Text('Tanggal: $tanggal'),
            Divider(),
            ...jumlahBeli.entries.map((entry) {
              final produk =
                  produkList.firstWhere((p) => p['produkid'] == entry.key);
              return Text(
                  '${produk['namaproduk']} x${entry.value} - Rp ${produk['harga'] * entry.value}');
            }).toList(),
            Divider(),
            Text('Total: Rp $totalTanpaDiskon',
                style: TextStyle(fontWeight: FontWeight.bold)),
            Text('Diskon (3%): -Rp $diskon',
                style: TextStyle(color: Colors.green)),
            Text('Pajak (2%): +Rp $pajak', style: TextStyle(color: Colors.red)),
            Text('Total Bayar: Rp $totalBayar',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: Text('Batal')),
          ElevatedButton(onPressed: prosesPembayaran, child: Text('Bayar')),
        ],
      ),
    );
  }

 Future<void> prosesPembayaran() async {
  try {
    // Hitung total harga transaksi
    int totalHarga = jumlahBeli.entries.fold(0, (total, entry) {
      var produk = produkList.firstWhere((p) => p['produkid'] == entry.key);
      return total + (produk['harga'] as num).toInt() * entry.value;
    });

    // Simpan data penjualan dan ambil ID
    final penjualanResponse = await supabase
        .from('penjualan')
        .insert({
          'tanggalpenjualan': DateTime.now().toIso8601String(),
          'totalharga': totalHarga,
          'pelangganid': int.parse(selectedPelanggan!),
        })
        .select('penjualanid')
        .single();

    final penjualanid = penjualanResponse['penjualanid'];

    // Simpan detail penjualan dan update stok produk
    for (var entry in jumlahBeli.entries) {
      var produk = produkList.firstWhere((p) => p['produkid'] == entry.key);
      int subtotal = produk['harga'] * entry.value;

      await supabase.from('detailpenjualan').insert({
        'Penjualanid': penjualanid,
        'produkid': entry.key,
        'jumlahproduk': entry.value,
        'subtotal': subtotal,
      });

      // Update stok produk
      int stokBaru = produk['stok'] - entry.value;
      await supabase
          .from('produk')
          .update({'stok': stokBaru})
          .match({'produkid': entry.key});
    }

    // Hitung diskon (3%) dan pajak (2%)
    int diskon = (totalHarga * 0.03).toInt();
    int pajak = (totalHarga * 0.02).toInt();
    int totalBayar = totalHarga - diskon + pajak;

    // Notifikasi sukses
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pembayaran berhasil! Stok diperbarui.'),
          backgroundColor: Colors.green,
        ),
      );
    }

    // Tampilkan dialog untuk mencetak struk
    if (context.mounted) {
      bool cetakStruk = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Struk Pembayaran'),
          content: Text('Apakah Anda ingin mencetak struk pembayaran?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Tidak'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text('Cetak Struk'),
            ),
          ],
        ),
      ) ?? false;

      if (cetakStruk) {
        generatePDF(
          context,
          penjualanid,
          "Nama Pelanggan", // Gantilah dengan data pelanggan yang sesuai
          jumlahBeli.entries.map((entry) {
            var produk = produkList.firstWhere((p) => p['produkid'] == entry.key);
            return {
              'namaproduk': produk['namaproduk'],
              'jumlah': entry.value,
              'harga': produk['harga'],
              'subtotal': produk['harga'] * entry.value,
            };
          }).toList(),
          totalHarga,
          diskon,
          pajak,
          totalBayar,
        );
      } else {
        // Navigasi kembali ke Homepage jika tidak mencetak struk
        if (context.mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => Homepage()),
            (Route<dynamic> route) => false,
          );
        }
      }
    }

    // Reset state setelah transaksi
    if (mounted) {
      setState(() {
        jumlahBeli.clear();
      });
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

  @override
  Widget build(BuildContext context) {
    int totalHarga = jumlahBeli.entries.fold(0, (total, entry) {
      var produk = produkList.firstWhere((p) => p['produkid'] == entry.key);
      return total + (produk['harga'] as int) * entry.value;
    });

    return Scaffold(
      appBar: AppBar(title: Text('Pembayaran')),
      body: Column(
        children: [
          DropdownButtonFormField(
            value: selectedPelanggan,
            items: pelangganList.map((pelanggan) {
              return DropdownMenuItem(
                value: pelanggan['pelangganid'].toString(),
                child: Text(pelanggan['namapelanggan']),
              );
            }).toList(),
            onChanged: (value) =>
                setState(() => selectedPelanggan = value as String?),
            decoration: InputDecoration(labelText: 'Pilih Pelanggan'),
          ),
          Expanded(
            child: isLoading
                ? Center(
                    child:
                        CircularProgressIndicator()) // Menampilkan loading jika belum selesai memuat
                : ListView.builder(
                    itemCount: filteredProdukList.length,
                    itemBuilder: (context, index) {
                      final produk = filteredProdukList[index];
                      int jumlah = jumlahBeli[produk['produkid']] ?? 0;
                      bool stokKurang = produk['stok'] < 20;

                      return Card(
                        margin:
                            EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          title: Text(produk['namaproduk']),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Harga: Rp ${produk['harga']}'),
                              Text(
                                'Stok: ${produk['stok']}',
                                style: TextStyle(
                                    color:
                                        stokKurang ? Colors.red : Colors.black),
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.remove_circle,
                                    color: Colors.red),
                                onPressed: () => kurangiProduk(index),
                              ),
                              Text('$jumlah', style: TextStyle(fontSize: 18)),
                              IconButton(
                                icon:
                                    Icon(Icons.add_circle, color: Colors.green),
                                onPressed: () => tambahProduk(index),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          // Total harga di atas tombol
          Container(
            padding: EdgeInsets.all(10),
            child: Text(
              'Total Bayar: Rp $totalHarga',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          // Tombol dengan sudut melengkung
          Container(
            width: double.infinity,
            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: ElevatedButton(
              onPressed: showDetailTransaksi,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xff3a57e8), // Warna tombol biru
                foregroundColor: Colors.white, // Warna teks putih
                padding: EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15), // Sudut melengkung
                ),
              ),
              child: Text(
                'Proses Pembayaran',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
