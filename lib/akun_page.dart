import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'Loginpage.dart';

class AkunPage extends StatelessWidget {
  final String _username = "Aden"; // Ganti dengan data dari sesi
  final String _email = "aden@example.com"; // Ganti dengan data dari sesi
  final SupabaseClient supabase = Supabase.instance.client;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Akun Saya"),
        backgroundColor: Color(0xff3a57e8),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Profile
            Container(
              padding: EdgeInsets.all(20),
              color: Color(0xff3a57e8),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: AssetImage("assets/avatar.png"), // Gambar lokal
                  ),
                  SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _username,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        _email,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),

            // Menu "Ganti Password"
            _buildMenuItem(Icons.lock, "Ganti Password", () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => GantiPasswordPage()),
              );
            }),

            // Menu "Keluar / Logout"
            _buildMenuItem(Icons.logout, "Keluar", () {
              _showLogoutDialog(context); // Tampilkan dialog konfirmasi
            }),
          ],
        ),
      ),
    );
  }

  // Widget untuk item menu
  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Color(0xff3a57e8)),
      title: Text(title, style: TextStyle(fontSize: 16)),
      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }

  // Fungsi menampilkan dialog konfirmasi logout
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Konfirmasi Keluar"),
          content: Text("Apakah Anda yakin ingin keluar?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Tutup dialog
              child: Text("Batal"),
            ),
            TextButton(
              onPressed: () => _logout(context), // Logout jika user setuju
              child: Text("Keluar", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  // Fungsi logout (hapus sesi & kembali ke login)
  Future<void> _logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Hapus data sesi

    // Pindah ke halaman login & hapus semua riwayat sebelumnya
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }
}

class GantiPasswordPage extends StatefulWidget {
  @override
  _GantiPasswordPageState createState() => _GantiPasswordPageState();
}

class _GantiPasswordPageState extends State<GantiPasswordPage> {
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final SupabaseClient supabase = Supabase.instance.client;

  Future<void> _changePassword() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? username = prefs.getString('username');

      if (username == null) {
        IconSnackBar.show(context, snackBarType: SnackBarType.fail, label: "Kesalahan sesi, silakan login kembali");
        return;
      }

      final String oldPassword = _oldPasswordController.text;
      final String newPassword = _newPasswordController.text;
      final String confirmPassword = _confirmPasswordController.text;

      if (newPassword != confirmPassword) {
        IconSnackBar.show(context, snackBarType: SnackBarType.alert, label: "Password baru tidak cocok");
        return;
      }

      final response = await supabase
          .from('user')
          .select('password')
          .eq('username', username)
          .single();

      if (response == null || !response.containsKey('password')) {
        IconSnackBar.show(context, snackBarType: SnackBarType.fail, label: "Pengguna tidak ditemukan");
        return;
      }

      final String storedPassword = response['password'];
      if (oldPassword != storedPassword) {
        IconSnackBar.show(context, snackBarType: SnackBarType.fail, label: "Password lama salah");
        return;
      }

      await supabase
          .from('user')
          .update({'password': newPassword})
          .eq('username', username);

      IconSnackBar.show(context, snackBarType: SnackBarType.success, label: "Password berhasil diperbarui");
      Navigator.pop(context);
    } catch (e) {
      IconSnackBar.show(context, snackBarType: SnackBarType.fail, label: "Terjadi kesalahan: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Ganti Password")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _oldPasswordController, obscureText: true, decoration: InputDecoration(labelText: "Password Lama")),
            TextField(controller: _newPasswordController, obscureText: true, decoration: InputDecoration(labelText: "Password Baru")),
            TextField(controller: _confirmPasswordController, obscureText: true, decoration: InputDecoration(labelText: "Konfirmasi Password Baru")),
            SizedBox(height: 20),
            ElevatedButton(onPressed: _changePassword, child: Text("Simpan Password")),
          ],
        ),
      ),
    );
  }
}
