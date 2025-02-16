import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'About Application',
          style: TextStyle(color: Colors.brown),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.brown),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo Aplikasi
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  'assets/ramen.png',
                  width: 200,
                  height: 200,
                ),
              ),
              const SizedBox(height: 30),
              // Judul Aplikasi
              Text(
                'Ramen Store Japanese',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown[800],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              // Deskripsi Aplikasi
              Text(
                'Ramen Store Japanese adalah aplikasi pemesanan ramen dengan '
                'tampilan yang menarik dan mudah digunakan. Aplikasi ini '
                'menyediakan berbagai macam menu ramen autentik Jepang yang '
                'lezat. Nikmati pengalaman memesan ramen kapan saja dan di mana saja.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.brown[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              // Tombol Kembali
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                label: const Text(
                  'Back to Landing Page',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown,
                  padding: const EdgeInsets.symmetric(
                    vertical: 15,
                    horizontal: 30,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
