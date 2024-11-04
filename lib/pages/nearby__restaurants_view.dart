import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path_provider/path_provider.dart';
import '../viewmodels/nearby_restaurants_viewmodel.dart';
import '../models/token_manager.dart';

class NearbyRestaurantsView extends StatefulWidget {
  const NearbyRestaurantsView({super.key});

  @override
  _NearbyRestaurantsViewState createState() => _NearbyRestaurantsViewState();
}

class _NearbyRestaurantsViewState extends State<NearbyRestaurantsView> {
  late GoogleMapController mapController;
  late DateTime _startTime;
  final String? _analitycsURL= dotenv.env['API_KEY_HEROKU'];

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();

    final viewModel = Provider.of<NearbyRestaurantsViewModel>(context, listen: false);

    viewModel.getCurrentLocation().then((_) {
      if (viewModel.currentLocation != null) {
        viewModel.fetchNearbyRestaurants().then((_) {
          _sendAnalytics();
        });
      } else {
        viewModel.loadMarkersFromLocalCache();
      }
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    cacheMapSnapshot(controller);
  }

  Future<void> cacheMapSnapshot(GoogleMapController controller) async {
    try {
      final imageBytes = await controller.takeSnapshot();
      if (imageBytes != null) {
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/map_snapshot.png');
        await file.writeAsBytes(imageBytes);
        print("Map snapshot saved successfully.");
      }
    } catch (e) {
      print("Failed to save map snapshot: $e");
    }
  }

  Future<void> _sendAnalytics() async {
    DateTime endTime = DateTime.now();
    double loadTime = endTime.difference(_startTime).inMilliseconds / 1000;
    String? userId = await TokenManager().userId;

    if (userId == null) {
      print("Error: User ID not found");
      return;
    }

    String? herokuApiUrl = '$_analitycsURL/add_time';
    Map<String, dynamic> data = {
      "plataforma": "Flutter",
      "tiempo": loadTime,
      "timestamp": endTime.toUtc().toIso8601String(),
      "userID": userId,
    };

    try {
      final response = await http.post(
        Uri.parse(herokuApiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        print("Metrics sent successfully.");
      } else {
        print("Error sending metrics: ${response.body}");
      }
    } catch (e) {
      print("Error connecting to Heroku service: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Restaurants'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Consumer<NearbyRestaurantsViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.currentLocation == null && viewModel.restaurants.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          Set<Marker> markers = {};
          for (var restaurant in viewModel.restaurants) {
            markers.add(
              Marker(
                markerId: MarkerId(restaurant.name),
                position: LatLng(restaurant.latitude, restaurant.longitude),
                infoWindow: InfoWindow(title: restaurant.name),
              ),
            );
          }

          return GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: viewModel.currentLocation != null
                  ? LatLng(viewModel.currentLocation!.latitude!, viewModel.currentLocation!.longitude!)
                  : LatLng(0, 0),
              zoom: 15.0,
            ),
            markers: markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
          );
        },
      ),
    );
  }
}
