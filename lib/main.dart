import 'package:flutter/material.dart';
import 'package:dio_contact/view/screen/landing_page.dart';
import 'package:dio_contact/view/screen/home_page.dart';  
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ramen Store',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: false,
      ),
      
      routes: {
        '/': (context) => const LandingPage(),   
        '/home_page': (context) => const MenuPage(),  
      },
    );
  }
}
