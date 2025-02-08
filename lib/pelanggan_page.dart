import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PelangganPage extends StatefulWidget {
  @override
  _PelangganPageState createState() => _PelangganPageState();
}

class _PelangganPageState extends State<PelangganPage> {
  final SupabaseClient _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _pelanggan = [];
  List<Map<String, dynamic>> _allPelanggan = [];
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchPelanggan();
    _searchController.addListener(_filterPelanggan);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchPelanggan() async {
    try {
      final List<dynamic> response =
          await _supabase.from('pelanggan').select('*');

      if (response.isNotEmpty) {
        setState(() {
          _allPelanggan =
              response.map((e) => Map<String, dynamic>.from(e)).toList();
          _pelanggan = List.from(_allPelanggan);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tidak ada data pelanggan')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: ${error.toString()}')),
      );
    }
  }

  void _filterPelanggan() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _pelanggan = _allPelanggan
          .where((pelanggan) =>
              pelanggan['namapelanggan'].toLowerCase().contains(query) ||
              pelanggan['alamat'].toLowerCase().contains(query) ||
              pelanggan['nomertelepon'].toLowerCase().contains(query))
          .toList();
    });
  }

  Future<void> _editPelangganDialog(Map<String, dynamic> pelanggan) async {
    TextEditingController namaController =
        TextEditingController(text: pelanggan['namapelanggan']);
    TextEditingController alamatController =
        TextEditingController(text: pelanggan['alamat'] ?? '');
    TextEditingController teleponController =
        TextEditingController(text: pelanggan['nomertelepon'] ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Pelanggan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: namaController,
              decoration: InputDecoration(labelText: 'Nama Pelanggan'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: alamatController,
              decoration: InputDecoration(labelText: 'Alamat'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: teleponController,
              decoration: InputDecoration(labelText: 'Nomor Telepon'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _updatePelanggan(
                pelanggan['pelangganid'],
                namaController.text,
                alamatController.text,
                teleponController.text,
              );
            },
            child: Text('Simpan'),
          ),
        ],
      ),
    );
  }

  Future<void> _updatePelanggan(
      int id, String nama, String alamat, String telepon) async {
    try {
      await _supabase.from('pelanggan').update({
        'namapelanggan': nama,
        'alamat': alamat,
        'nomertelepon': telepon,
      }).eq('pelangganid', id);
      _fetchPelanggan();
      Navigator.pop(context);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memperbarui pelanggan: $error')),
      );
    }
  }

  Future<void> _deletePelanggan(int id) async {
    bool confirmDelete = await _showDeleteConfirmationDialog();
    if (confirmDelete) {
      try {
        await _supabase.from('pelanggan').delete().eq('pelangganid', id);
        _fetchPelanggan();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Pelanggan berhasil dihapus')),
        );
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus pelanggan: $error')),
        );
      }
    }
  }

  Future<bool> _showDeleteConfirmationDialog() async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Konfirmasi'),
            content: Text('Apakah Anda yakin ingin menghapus pelanggan ini?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: Text('Hapus'),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Daftar Pelanggan')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Cari Pelanggan',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _pelanggan.length,
              itemBuilder: (context, index) {
                final pelanggan = _pelanggan[index];
                return ListTile(
                  title: Text(pelanggan['namapelanggan']),
                  subtitle: Text('${pelanggan['alamat']} \n${pelanggan['nomertelepon']}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _editPelangganDialog(pelanggan),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deletePelanggan(pelanggan['pelangganid']),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
