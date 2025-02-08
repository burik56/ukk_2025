import 'package:flutter/material.dart';
import 'package:ukk_ujian/Loginpage.dart';
import 'user_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'produk.dart';
import 'pelanggan_page.dart';

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
  String _username = "Pengguna"; // Default sebelum mengambil dari sesi

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  /// Mengambil username yang tersimpan di sesi
  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('username') ?? "Pengguna";
    });
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
    ProdukPage(),
    UsersPage(),
    PelangganPage(),
  ];

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
              accountEmail: Text(
                  "example@gmail.com"), // Bisa diubah ke email dari database
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 40, color: Colors.blue),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text("Beranda"),
              onTap: () {
                _onItemTapped(0);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.fastfood),
              title: Text("Produk"),
              onTap: () {
                _onItemTapped(1);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text("User"),
              onTap: () {
                _onItemTapped(2);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.people),
              title: Text("Pelanggan"),
              onTap: () {
                _onItemTapped(3);
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
        title: Text(
          "Toko Jul",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Colors.white,
          ),
        ),
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: Colors.white),
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
                        "Aden",
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
