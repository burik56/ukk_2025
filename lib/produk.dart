import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';

class ProdukPage extends StatefulWidget {
  @override
  _ProdukPageState createState() => _ProdukPageState();
}

class _ProdukPageState extends State<ProdukPage> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<dynamic> produkList = [];

  @override
  void initState() {
    super.initState();
    fetchProduk();
  }

  Future<void> fetchProduk() async {
    final response = await supabase.from('produk').select();
    setState(() {
      produkList = response;
    });
  }

  Future<void> confirmDeleteProduk(int id) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Konfirmasi"),
          content: Text("Apakah Anda yakin ingin menghapus produk ini?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Batal"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                deleteProduk(id);
              },
              child: Text("Hapus", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Future<void> deleteProduk(int id) async {
    await supabase.from('produk').delete().eq('produkid', id);
    fetchProduk();
    IconSnackBar.show(
      context,
      snackBarType: SnackBarType.fail,
      maxLines: 1,
      label: 'Produk berhasil dihapus!',
    );
  }

  Future<void> showTambahProdukDialog({Map<String, dynamic>? produk}) async {
    TextEditingController namaController = TextEditingController(text: produk?['namaproduk'] ?? "");
    TextEditingController hargaController = TextEditingController(text: produk?['harga']?.toString() ?? "");
    TextEditingController stokController = TextEditingController(text: produk?['stok']?.toString() ?? "");

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(produk == null ? "Tambah Produk" : "Edit Produk"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: namaController,
                decoration: InputDecoration(labelText: "Nama Produk"),
              ),
              TextField(
                controller: hargaController,
                decoration: InputDecoration(labelText: "Harga"),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              TextField(
                controller: stokController,
                decoration: InputDecoration(labelText: "Stok"),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Batal"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (produk == null) {
                  await supabase.from('produk').insert({
                    'namaproduk': namaController.text,
                    'harga': double.tryParse(hargaController.text) ?? 0,
                    'stok': int.tryParse(stokController.text) ?? 0,
                  });
                  IconSnackBar.show(
                    context,
                    snackBarType: SnackBarType.success,
                    maxLines: 1,
                    label: 'Produk berhasil ditambahkan!',
                  );
                } else {
                  await supabase.from('produk').update({
                    'namaproduk': namaController.text,
                    'harga': double.tryParse(hargaController.text) ?? 0,
                    'stok': int.tryParse(stokController.text) ?? 0,
                  }).eq('produkid', produk['produkid']);
                  IconSnackBar.show(
                    context,
                    snackBarType: SnackBarType.success,
                    maxLines: 1,
                    label: 'Produk berhasil diperbarui!',
                  );
                }
                fetchProduk();
                Navigator.pop(context);
              },
              child: Text(produk == null ? "Tambah" : "Simpan"),
            ),
          ],
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Cari Produk',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: produkList.length,
                itemBuilder: (context, index) {
                  final produk = produkList[index];
                  return Container(
                    margin: EdgeInsets.only(bottom: 16),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(color: Colors.grey.shade300, width: 1),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            'assets/makanan.png',
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                produk['namaproduk'] ?? 'Nama tidak tersedia',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Stok: ${produk['stok'] ?? 0}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.edit, color: Colors.blue),
                                        onPressed: () => showTambahProdukDialog(produk: produk),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.delete, color: Colors.red),
                                        onPressed: () => confirmDeleteProduk(produk['produkid']),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    'Rp ${produk['harga'] ?? 0}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showTambahProdukDialog(),
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }
}