import 'package:flutter/material.dart';
import 'user_page.dart';
import 'produk.dart';

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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  static List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    ProdukPage(),
    UsersPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: Color(0xff3a57e8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
        title: Text(
          "Toko Jul",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontStyle: FontStyle.normal,
            fontSize: 14,
            color: Color(0xffffffff),
          ),
        ),
        leading: Icon(
          Icons.menu,
          color: Color(0xffffffff),
          size: 24,
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
            icon: Icon(Icons.search),
            label: "Produk",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "User",
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
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
