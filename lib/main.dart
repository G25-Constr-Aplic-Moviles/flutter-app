import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test3/pages/register_page.dart';
import 'package:test3/pages/restaurant_page.dart';
import 'package:test3/pages/restaurants_list.dart';
import 'package:test3/pages/login_page.dart';
import 'package:test3/viewmodels/nearby_restaurants_viewmodel.dart';
import 'package:test3/viewmodels/route_view_model.dart';
import 'package:test3/viewmodels/restaurant_page_viewmodel.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => NearbyRestaurantsViewModel()),
        ChangeNotifierProvider(create: (context) => RouteViewModel()),
        //ChangeNotifierProvider(create: (context) => RestaurantPageViewModel()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: 'Gidugu',
        ),
        home: const RestaurantsListPage(),
      ),
    );
  }
}

