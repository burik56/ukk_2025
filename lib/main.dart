import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ukk_ujian/Loginpage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://ggqqsfsqihoshydxtztm.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdncXFzZnNxaWhvc2h5ZHh0enRtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mzg3MTM4NTIsImV4cCI6MjA1NDI4OTg1Mn0.Om7H9YDegg9Grx-jnYFRLPufGv_U32jdvj7UDux0lnU', 
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login App',
      home: LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}