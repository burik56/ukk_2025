import 'package:flutter/material.dart';

class TransaksiPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Transaksi"),
        backgroundColor: Color(0xff3a57e8),
      ),
      body: Center(
        child: Text(
          "Halaman Transaksi",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
