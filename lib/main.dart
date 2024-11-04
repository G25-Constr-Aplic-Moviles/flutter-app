import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test3/pages/login_page.dart';
import 'package:test3/pages/restaurants_list.dart';
import 'package:test3/services/user_service.dart';
import 'package:test3/viewmodels/MenuItemViewModel.dart';
import 'package:test3/viewmodels/RegisterViewModel.dart';
import 'package:test3/viewmodels/history_viewmodel.dart';
import 'package:test3/viewmodels/nearby_restaurants_viewmodel.dart';
import 'package:test3/viewmodels/restaurants_list_viewmodel.dart';
import 'package:test3/viewmodels/route_view_model.dart';
import 'package:test3/viewmodels/LoginViewModel.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io';
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:path_provider/path_provider.dart';

import 'models/token_manager.dart';

void main() async {
  await dotenv.load(fileName: '.env');
  HttpOverrides.global = MyHttpOverrides();

  // Captura el snapshot inicial del mapa al iniciar la aplicación
  await captureInitialMapSnapshot();

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

Future<void> captureInitialMapSnapshot() async {
  final Completer<GoogleMapController> _controller = Completer();

  // Define una ubicación inicial y la posición de la cámara (ajusta según tus necesidades)
  final CameraPosition initialPosition = CameraPosition(
    target: LatLng(0.0, 0.0), // Cambia a la ubicación predeterminada o actual del usuario
    zoom: 12.0,
  );

  // Inicializa el mapa y toma el snapshot
  final GoogleMap map = GoogleMap(
    initialCameraPosition: initialPosition,
    onMapCreated: (GoogleMapController controller) {
      _controller.complete(controller);
    },
  );

  GoogleMapController controller = await _controller.future;
  final imageBytes = await controller.takeSnapshot();
  if (imageBytes != null) {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/initial_map_snapshot.png');
    await file.writeAsBytes(imageBytes);
    print("Initial map snapshot saved successfully.");
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
        home: FutureBuilder(
          future: _checkToken(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasData && snapshot.data == true) {
              return const RestaurantsListPage();
            } else {
              return const LoginView();
            }
          },
        ),
      ),
    );
  }

  Future<bool> _checkToken() async {
    final token = await TokenManager.instance.token;
    final expireAt = await TokenManager.instance.expireAt;

    if (token != null && expireAt != null) {
      if (DateTime.now().isBefore(expireAt)) {
        return true;
      }
    }
    return false;
  }
}
