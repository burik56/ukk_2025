import 'package:flutter/material.dart';
import 'package:ukk_ujian/Loginpage.dart';
import 'user_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'produk.dart';
import 'pelanggan_page.dart';
import 'transaksi_page.dart';
import 'pembayaran_page.dart';
import 'akun_page.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Homepage(),
    );
  }
}

class Homepage extends StatefulWidget {
  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  int _selectedIndex = 0;
  List<dynamic> produkList = [];
  String _username = "Pengguna"; // Default sebelum mengambil dari sesi
  String _role = "Pengguna"; // Default sebelum mengambil dari sesi

  void _onItemTapped(int index) {
    if (_role == "petugas" || _role == "pelanggan") {
      // Jika role adalah Petugas atau Pelanggan, blokir akses ke halaman tertentu (misalnya index 3 dan 2)
      if (index == 2 || index == 3 || index == 4) {
        // Gunakan IconSnackBar untuk pesan error
        IconSnackBar.show(
          context,
          snackBarType: SnackBarType.alert, // SnackBar dengan ikon error
          maxLines: 1,
          label: "Anda tidak memiliki akses!",
        );
        return; // Batalkan perpindahan halaman
      }
    }

    // Jika pengecekan tidak menghalangi, lanjutkan untuk mengganti halaman
    setState(() {
      _selectedIndex = index;
    });
  }

  /// Mengambil username yang tersimpan di sesi
  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('username') ?? "Pengguna";
      _role = prefs.getString('role') ??
          "Pengguna"; // Ambil role dari SharedPreferences
    });

    // DEBUGGING: Cetak hasil di terminal
    print("DEBUG: Username -> $_username");
    print("DEBUG: Role -> $_role");
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Hapus data sesi
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  static List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    TransaksiPage(),
    ProdukPage(),
    UsersPage(),
    PelangganPage(),
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Tambahkan ini agar username langsung dimuat saat aplikasi dijalankan
    fetchProduk();
  }

  Future<void> fetchProduk() async {
    final response = await supabase.from('produk').select();
    setState(() {
      produkList = response;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: Color(0xff3a57e8)),
              accountName: Text(
                _username, // Nama user dari sesi
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              accountEmail: Text("example@gmail.com"),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 40, color: Colors.blue),
              ),
            ),
            // Menu "Akun" sekarang di posisi pertama
            ListTile(
              leading: Icon(Icons.account_circle),
              title: Text("Akun"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AkunPage()),
                );
              },
            ),
            // Menu "User" sekarang di posisi kedua
            ListTile(
              leading: Icon(Icons.person),
              title: Text("User"),
              onTap: () {
                // Cek jika role bukan "Admin" (baik Petugas atau Pelanggan)
                if (_role == "Petugas" || _role == "Pelanggan") {
                  // Jika role adalah Petugas atau Pelanggan, tampilkan peringatan
                  IconSnackBar.show(
                    context,
                    snackBarType: SnackBarType.alert,
                    maxLines: 1,
                    label: "Anda tidak memiliki Hak akses",
                  );
                } else {
                  // Jika role adalah Admin, lanjutkan navigasi
                  _onItemTapped(3);
                  Navigator.pop(context);
                }
              },
            ),

            // Menu "Pembayaran"
            ListTile(
              leading: Icon(Icons.shopping_cart),
              title: Text("Pembayaran"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PembayaranPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.payment),
              title: Text("Riwayat Transaksi"),
              onTap: () {
                _onItemTapped(1);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.fastfood),
              title: Text("Produk"),
              onTap: () {
                if (_role == "petugas" || _role == "pelanggan") {
                  // Jika role adalah Petugas atau Pelanggan, blokir akses
                  IconSnackBar.show(
                    context,
                    snackBarType:
                        SnackBarType.alert, // SnackBar dengan ikon error
                    maxLines: 1,
                    label: "Anda tidak memiliki akses!",
                  );
                } else {
                  // Jika role bukan Petugas atau Pelanggan, izinkan akses ke menu Produk
                  _onItemTapped(2);
                  Navigator.pop(context);
                }
              },
            ),

            ListTile(
              leading: Icon(Icons.people),
              title: Text("Pelanggan"),
              onTap: () {
                // Pengecekan untuk role Petugas dan Pelanggan agar tidak bisa akses halaman index 4
                if (_role == "petugas" || _role == "pelanggan") {
                  // Gunakan IconSnackBar untuk pesan error
                  IconSnackBar.show(
                    context,
                    snackBarType:
                        SnackBarType.alert, // SnackBar dengan ikon error
                    maxLines: 1,
                    label: "Anda tidak memiliki akses!",
                  );
                  return; // Batalkan perpindahan halaman
                }
                _onItemTapped(4);
                Navigator.pop(context);
              },
            ),

            Divider(),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.red),
              title: Text("Logout", style: TextStyle(color: Colors.red)),
              onTap: _logout,
            ),
          ],
        ),
      ),
      appBar: AppBar(
        elevation: 2,
        centerTitle: true,
        backgroundColor: Color(0xff3a57e8),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Toko Jul",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Colors.white,
              ),
            ),
            Text(
              _role, // Menampilkan Role di kanan AppBar
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ],
        ),
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: Colors.white), // Ubah warna ke putih
            onPressed: () {
              Scaffold.of(context).openDrawer(); // Membuka Drawer saat ditekan
            },
          ),
        ),
      ),
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Beranda",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.payment),
            label: "Riwayat Transaksi",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fastfood),
            label: "Produk",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "User",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: "Pelanggan",
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue, // Warna ketika dipilih
        unselectedItemColor: Color(0xFFB771E5), // Warna ikon saat tidak dipilih
        onTap: _onItemTapped,
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16, 40, 16, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  flex: 1,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Text(
                        "Selamat Datang",
                        textAlign: TextAlign.start,
                        overflow: TextOverflow.clip,
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontStyle: FontStyle.normal,
                          fontSize: 14,
                          color: Color(0xff8c8989),
                        ),
                      ),
                      Text(
                        "DI KASIR JUL",
                        textAlign: TextAlign.start,
                        overflow: TextOverflow.clip,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontStyle: FontStyle.normal,
                          fontSize: 16,
                          color: Color(0xff000000),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 50,
                  width: 50,
                  child: Stack(
                    alignment: Alignment.topRight,
                    children: [
                      Container(
                        height: 50,
                        width: 50,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextField(
              controller: TextEditingController(),
              obscureText: false,
              textAlign: TextAlign.start,
              maxLines: 1,
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontStyle: FontStyle.normal,
                fontSize: 14,
                color: Color(0xff000000),
              ),
              decoration: InputDecoration(
                disabledBorder: UnderlineInputBorder(
                  borderRadius: BorderRadius.circular(4.0),
                  borderSide: BorderSide(color: Color(0xff000000), width: 1),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderRadius: BorderRadius.circular(4.0),
                  borderSide: BorderSide(color: Color(0xff000000), width: 1),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderRadius: BorderRadius.circular(4.0),
                  borderSide: BorderSide(color: Color(0xff000000), width: 1),
                ),
                filled: true,
                fillColor: Color(0x00ffffff),
                isDense: true,
                contentPadding: EdgeInsets.all(12),
                prefixIcon:
                    Icon(Icons.search, color: Color(0xffa4a2a2), size: 20),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => PembayaranPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                  ),
                  icon: Icon(Icons.shopping_cart),
                  label: Text("Pembayaran"),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => PelangganPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                  ),
                  icon: Icon(Icons.people),
                  label: Text("Pelanggan"),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              "Produk",
              textAlign: TextAlign.start,
              overflow: TextOverflow.clip,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontStyle: FontStyle.normal,
                fontSize: 18,
                color: Color(0xff000000),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.all(0),
            padding: EdgeInsets.all(0),
            height: 170,
            decoration: BoxDecoration(
              color: Color(0x00ffffff),
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.zero,
            ),
          ),
        ],
      ),
    );
  }
}
