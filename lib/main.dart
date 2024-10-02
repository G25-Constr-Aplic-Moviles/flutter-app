import 'package:flutter/material.dart';
import 'package:test3/pages/restaurant_page.dart';
import 'views/login.view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Gidugu',
      ),
      home: LoginView(),
    );
  }
}
