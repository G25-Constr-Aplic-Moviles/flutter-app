import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test3/pages/register_page.dart';
import 'package:test3/pages/restaurant_page.dart';
import 'package:test3/pages/restaurants_list.dart';
import 'package:test3/pages/login_page.dart';
import 'package:test3/services/api_service.dart';
import 'package:test3/services/history_service.dart';
import 'package:test3/services/user_service.dart';
import 'package:test3/viewmodels/MenuItemViewModel.dart';
import 'package:test3/viewmodels/RegisterViewModel.dart';
import 'package:test3/viewmodels/history_viewmodel.dart';
import 'package:test3/viewmodels/nearby_restaurants_viewmodel.dart';
import 'package:test3/viewmodels/restaurants_list_viewmodel.dart';
import 'package:test3/viewmodels/route_view_model.dart';
//import 'package:test3/viewmodels/restaurant_page_viewmodel.dart';
import 'package:test3/viewmodels/LoginViewModel.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'pages/login_page.dart';
import 'dart:io';

void main() async {
  await dotenv.load(fileName: '.env');
  HttpOverrides.global = MyHttpOverrides();
  runApp(const MyApp());
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (context) => NearbyRestaurantsViewModel()),
    ChangeNotifierProvider(create: (context) => RouteViewModel()),
    ChangeNotifierProvider(create: (context) => RestaurantsListViewModel()),
    ChangeNotifierProvider(create: (context) => MenuItemViewModel()),
    ChangeNotifierProvider(create: (context) => LoginViewModel(userService: UserService())),
    ChangeNotifierProvider(create: (context) => RegisterViewModel(userService: UserService())),
    ChangeNotifierProvider(create: (context) => HistoryViewModel())
  ],
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
