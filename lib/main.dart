import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test3/viewmodels/LoginViewModel.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'pages/login_page.dart';

void main() async {
  await dotenv.load(fileName: '.env');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => LoginViewModel(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: 'Gidugu',
        ),
        home: const LoginView(),
      ),
    );
  }
}
