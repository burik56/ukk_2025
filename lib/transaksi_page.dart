import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Inisialisasi Supabase client
final supabase = Supabase.instance.client;

class TransaksiPage extends StatefulWidget {
  @override
  _TransaksiPageState createState() => _TransaksiPageState();
}

class _TransaksiPageState extends State<TransaksiPage> {
  // Fungsi untuk mengambil daftar transaksi dari tabel penjualan
  Future<List<dynamic>> fetchTransaksi() async {
    final response = await supabase.from('penjualan').select(
        'penjualanid, tanggalpenjualan, totalharga, pelanggan(namapelanggan)');

    return response;
  }

  // Fungsi untuk menghapus transaksi berdasarkan ID
  Future<void> deleteTransaksi(int penjualanId) async {
    try {
      // Hapus detail transaksi terlebih dahulu
      await supabase
          .from('detailpenjualan')
          .delete()
          .match({'Penjualanid': penjualanId});

      // Setelah itu, hapus transaksi utama
      await supabase
          .from('penjualan')
          .delete()
          .match({'penjualanid': penjualanId});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Riwayat Transaksi berhasil dihapus"),
            backgroundColor: Colors.green),
      );

      setState(() {}); // Refresh tampilan setelah penghapusan
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Gagal menghapus Riwayat transaksi: $e"),
            backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Riwayat Transaksi",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xff3a57e8),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: fetchTransaksi(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("Tidak ada transaksi"));
          }

          final transaksiList = snapshot.data!;
          return ListView.builder(
            itemCount: transaksiList.length,
            itemBuilder: (context, index) {
              final transaksi = transaksiList[index];
              final penjualanId = transaksi['penjualanid'];
              final tanggalPenjualan = transaksi['tanggalpenjualan'] ?? 'N/A';
              final totalHarga = transaksi['totalharga'] ?? 'N/A';
              final namaPelanggan =
                  transaksi['pelanggan']['namapelanggan'] ?? 'N/A';

              return Card(
                margin: EdgeInsets.all(8),
                child: ListTile(
                  title: Text(
                    "Tanggal: $tanggalPenjualan",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    "Total Harga: Rp $totalHarga\nPelanggan: $namaPelanggan",
                  ),
                  leading: Icon(Icons.shopping_cart, color: Colors.blue),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text("Konfirmasi Hapus"),
                              content: Text(
                                  "Apakah Anda yakin ingin menghapus transaksi ini?"),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text("Batal"),
                                ),
                                TextButton(
                                  onPressed: () {
                                    deleteTransaksi(penjualanId);
                                    Navigator.pop(context);
                                  },
                                  child: Text("Hapus",
                                      style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      Icon(Icons.arrow_forward_ios),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            DetailTransaksiPage(penjualanId: penjualanId),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class DetailTransaksiPage extends StatefulWidget {
  final int penjualanId;

  DetailTransaksiPage({required this.penjualanId});

  @override
  _DetailTransaksiPageState createState() => _DetailTransaksiPageState();
}

class _DetailTransaksiPageState extends State<DetailTransaksiPage> {
  // Fungsi untuk mengambil detail transaksi berdasarkan penjualanid
  Future<List<dynamic>> fetchDetailTransaksi() async {
    final response = await supabase
        .from('detailpenjualan')
        .select('detailid, produk(namaproduk), jumlahproduk, subtotal')
        .eq('Penjualanid', widget.penjualanId);

    return response;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Detail Transaksi",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xff3a57e8),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: fetchDetailTransaksi(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("Tidak ada detail transaksi"));
          }

          final detailList = snapshot.data!;
          return ListView.builder(
            itemCount: detailList.length,
            itemBuilder: (context, index) {
              final detail = detailList[index];
              final namaProduk = detail['produk']['namaproduk'] ?? 'N/A';
              final jumlahProduk = detail['jumlahproduk'] ?? 0;
              final subtotal = detail['subtotal'] ?? 0.0;

              return Card(
                margin: EdgeInsets.all(8),
                child: ListTile(
                  title: Text("Produk: $namaProduk"),
                  subtitle:
                      Text("Jumlah: $jumlahProduk\nSubtotal: Rp $subtotal"),
                  leading: Icon(Icons.shopping_bag, color: Colors.green),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
