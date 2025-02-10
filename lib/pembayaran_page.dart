import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:ukk_ujian/homepage.dart';

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

    int diskon = (totalTanpaDiskon * 0) ~/ 100;
    int totalSetelahDiskon = totalTanpaDiskon - diskon;

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
            Text('Diskon (0%): -Rp $diskon',
                style: TextStyle(color: Colors.green)),
            Text('Total Bayar: Rp $totalSetelahDiskon',
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
      final penjualanResponse = await supabase
          .from('penjualan')
          .insert({
            'tanggalpenjualan': DateTime.now().toIso8601String(),
            'totalharga': jumlahBeli.entries.fold(0, (total, entry) {
              var produk =
                  produkList.firstWhere((p) => p['produkid'] == entry.key);
              return total + (produk['harga'] as num).toInt() * entry.value;
            }),
            'pelangganid': int.parse(selectedPelanggan!),
          })
          .select('penjualanid')
          .single();

      final penjualanid = penjualanResponse['penjualanid'];

      for (var entry in jumlahBeli.entries) {
        var produk = produkList.firstWhere((p) => p['produkid'] == entry.key);

        await supabase.from('detailpenjualan').insert({
          'Penjualanid': penjualanid,
          'produkid': entry.key,
          'jumlahproduk': entry.value,
          'subtotal': produk['harga'] * entry.value,
        });

        int stokBaru = produk['stok'] - entry.value;
        await supabase
            .from('produk')
            .update({'stok': stokBaru}).match({'produkid': entry.key});
      }

      // Notifikasi sukses sebelum navigasi
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Pembayaran berhasil! Stok diperbarui.'),
            backgroundColor: Colors.green),
      );

      // Delay sebelum pindah halaman
      await Future.delayed(Duration(seconds: 1));

      // Navigasi ke homepage **sebelum** setState
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => Homepage()),
          (Route<dynamic> route) => false,
        );
      }

      // Clear state hanya jika masih di halaman ini
      if (mounted) {
        setState(() {
          jumlahBeli.clear();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Terjadi kesalahan: $e'),
              backgroundColor: Colors.red),
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
