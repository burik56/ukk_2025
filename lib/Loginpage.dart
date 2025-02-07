import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ukk_ujian/homepage.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final SupabaseClient supabase = Supabase.instance.client;

  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await supabase
          .from('user')
          .select()
          .eq('username', _usernameController.text.trim())
          .maybeSingle();

      if (response != null) {
        String storedPassword = response['password'];

        if (_passwordController.text.trim() == storedPassword) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Homepage()),
          );
        } else {
          setState(() {
            _errorMessage = "Password salah!";
          });
        }
      } else {
        setState(() {
          _errorMessage = "Username tidak ditemukan!";
        });
      }
    } catch (error) {
      setState(() {
        _errorMessage = "Gagal Memuat Halaman";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
      body: Align(
        alignment: Alignment.center,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  "assets/logo.jpg",
                  height: 90,
                  width: 90,
                  fit: BoxFit.cover,
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 8, 0, 30),
                  child: Text(
                    "Kasir Jul",
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                      color: Color(0xff3a57e8),
                    ),
                  ),
                ),
                Text(
                  "Masuk",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 24,
                    color: Color(0xff000000),
                  ),
                ),
                if (_errorMessage != null)
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: TextField(
                    controller: _usernameController,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      labelText: "Username",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "Password",
                    border: OutlineInputBorder(),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 30),
                  child: MaterialButton(
                    onPressed: _isLoading ? null : _login,
                    color: Color(0xff3a57e8),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    padding: EdgeInsets.all(16),
                    child: _isLoading
                        ? CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : Text(
                            "Masuk",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                    textColor: Color(0xffffffff),
                    height: 40,
                    minWidth: 140,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
