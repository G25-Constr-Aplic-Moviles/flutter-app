import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:location/location.dart';
import 'dart:math';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController mapController;
  LocationData? _currentLocation;
  Location location = Location();

  final LatLng _center = const LatLng(4.6014, -74.0679);
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  Future<void> _getLocation() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _currentLocation = await location.getLocation();
    fetchRestaurants();
  }

  Future<void> fetchRestaurants() async {
    if (_currentLocation == null) {
      return;
    }

    try {
      final response = await http.get(Uri.parse('https://restaurantservice-375afbe356dc.herokuapp.com/restaurant/list'));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        LatLng userLatLng = LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!);

        setState(() {
          _markers = data.where((restaurant) {
            double latitude = restaurant['location']['latitude'];
            double longitude = restaurant['location']['longitude'];
            double distance = _calculateDistance(
              userLatLng.latitude,
              userLatLng.longitude,
              latitude,
              longitude,
            );

            return distance <= 1.0; // Mostrar restaurantes a máximo 1 km de distancia
          }).map((restaurant) {
            return Marker(
              markerId: MarkerId(restaurant['name']),
              position: LatLng(
                restaurant['location']['latitude'],
                restaurant['location']['longitude'],
              ),
              infoWindow: InfoWindow(
                title: restaurant['name'],
                snippet: restaurant['address'],
              ),
            );
          }).toSet();
        });
      } else {
        print('Error al obtener datos de Heroku: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double R = 6371; // Radio de la tierra en km
    double dLat = _degToRad(lat2 - lat1);
    double dLon = _degToRad(lon2 - lon1);

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degToRad(lat1)) * cos(_degToRad(lat2)) *
            sin(dLon / 2) * sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return R * c; // Distancia en km
  }

  double _degToRad(double deg) {
    return deg * (pi / 180);
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Restaurants'),
      ),
      body: _currentLocation == null
          ? Center(child: CircularProgressIndicator())
          : GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
          zoom: 15.0,
        ),
        markers: _markers,
        myLocationEnabled: true, // Mostrar el punto azul
        myLocationButtonEnabled: true, // Mostrar el botón de "mi ubicación"
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: 0,
        selectedItemColor: Colors.red,
        onTap: (index) {
          if (index == 0) {
            Navigator.pop(context);
          }
        },
      ),
    );
  }
}
