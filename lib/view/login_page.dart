import 'package:dio_contact/model/login_model.dart';
import 'package:dio_contact/service/api_service.dart';
import 'package:dio_contact/service/auth_manager.dart';
import 'package:dio_contact/view/screen/home_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio_contact/view/screen/landing_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  final ApiServices _dataService = ApiServices();

  @override
  void initState() {
    super.initState();
    checkLogin();
  }

  void checkLogin() async {
    bool isLoggedIn = await AuthManager.isLoggedIn();
    if (isLoggedIn) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const MenuPage(),
        ),
        (route) => false,
      );
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateUsername(String? value) {
    if (value != null && value.length < 4) {
      return 'Masukkan minimal 4 karakter';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value != null && value.length < 3) {
      return 'Masukkan minimal 3 karakter';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFFF8E1), // Warna latar selaras dengan LandingPage
        body: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo Ramen
                  Image.asset(
                    'assets/ramen.png',
                    width: 150, // Sesuaikan ukuran logo
                    height: 150,
                  ),
                  const SizedBox(height: 20),
                  // Judul Halaman
                  Text(
                    'Admin Login',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown[800],
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Deskripsi
                  Text(
                    'Masukkan username dan password untuk masuk',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.brown[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Input Username
                        TextFormField(
                          validator: _validateUsername,
                          controller: _usernameController,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.account_circle_rounded),
                            hintText: 'Username',
                            labelText: 'Username',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            fillColor: Colors.white,
                            filled: true,
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Input Password
                        TextFormField(
                          obscureText: true,
                          controller: _passwordController,
                          validator: _validatePassword,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.lock_rounded),
                            hintText: 'Password',
                            labelText: 'Password',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            fillColor: Colors.white,
                            filled: true,
                          ),
                        ),
                        const SizedBox(height: 30),
                        // Tombol Login
                        ElevatedButton(
                          onPressed: () async {
                            final isValidForm =
                                _formKey.currentState!.validate();
                            if (isValidForm) {
                              final postModel = {
                                "username": _usernameController.text,
                                "password": _passwordController.text,
                              };

                              try {
                                LoginResponse? res =
                                    await _dataService.login(postModel);

                                if (res != null && res.statusCode == 200) {
                                  SharedPreferences prefs =
                                      await SharedPreferences.getInstance();
                                  await prefs.setString('token',
                                      res.token ?? 'Token tidak ditemukan');

                                  await AuthManager.login(
                                      _usernameController.text);

                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => const MenuPage()),
                                    (route) => false,
                                  );
                                } else {
                                  displaySnackbar(
                                    res?.message ??
                                        'Login gagal. Periksa koneksi atau data yang dimasukkan.',
                                  );
                                }
                              } catch (e) {
                                displaySnackbar(
                                    'Terjadi kesalahan saat login. Coba lagi nanti.');
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 40, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            'Login',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Tombol Kembali ke Landing Page
                  TextButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LandingPage()),
                        (route) => false,
                      );
                    },
                    child: const Text(
                      'Back to Landing Page',
                      style: TextStyle(
                        color: Colors.blueGrey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  dynamic displaySnackbar(String msg) {
    return ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }
}
