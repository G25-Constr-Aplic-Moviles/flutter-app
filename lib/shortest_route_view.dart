import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'dart:convert';
import 'dart:math';

class RouteView extends StatefulWidget {
  @override
  _RouteViewState createState() => _RouteViewState();
}

class _RouteViewState extends State<RouteView> {
  late GoogleMapController mapController;
  LocationData? _currentLocation;
  Location location = Location();

  final LatLng _initialCenter = const LatLng(4.6014, -74.0679);
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    _getLocationAndRestaurant();
  }

  Future<void> _getLocationAndRestaurant() async {
    try {
      // Obtener la ubicación actual del usuario
      bool serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) {
          return;
        }
      }

      PermissionStatus permissionGranted = await location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) {
          return;
        }
      }

      _currentLocation = await location.getLocation();

      // Obtener la ubicación del primer restaurante desde el API de Heroku
      final response = await http.get(Uri.parse('https://restaurantservice-375afbe356dc.herokuapp.com/restaurant/list'));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {

          //aqui toca cambiarlo para que sea con el restaurante especifico
          var restaurant = data[0];


          LatLng restaurantLocation = LatLng(
            restaurant['location']['latitude'],
            restaurant['location']['longitude'],
          );

          // Agregar marcadores para la ubicación actual del usuario y del restaurante
          setState(() {
            _markers.add(
              Marker(
                markerId: MarkerId('userLocation'),
                position: LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
                infoWindow: InfoWindow(title: 'My Location'),
              ),
            );

            _markers.add(
              Marker(
                markerId: MarkerId(restaurant['name']),
                position: restaurantLocation,
                infoWindow: InfoWindow(title: restaurant['name']),
              ),
            );
          });

          // Obtener la ruta desde la ubicación actual hasta el restaurante
          _getRoute(
            LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
            restaurantLocation,
          );
        }
      } else {
        print('Error al obtener datos de Heroku: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _getRoute(LatLng origin, LatLng destination) async {
    try {
      final String apiKey = 'AIzaSyBCmuFDXquBd5vdxehcjkgSglXoA6e6-_s';
      final String url =
          'https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&key=$apiKey';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        if (data['routes'] != null && data['routes'].isNotEmpty) {
          String polylinePoints = data['routes'][0]['overview_polyline']['points'];
          List<LatLng> polylineCoordinates = _decodePolyline(polylinePoints);

          setState(() {
            _polylines.add(
              Polyline(
                polylineId: PolylineId('route'),
                color: Colors.blue,
                width: 5,
                points: polylineCoordinates,
              ),
            );
          });
        } else {
          print('No route found');
        }
      } else {
        print('Error al obtener la ruta: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  // Decodificar la respuesta Polyline para obtener la lista de coordenadas
  List<LatLng> _decodePolyline(String polyline) {
    List<LatLng> coordinates = [];
    int index = 0, len = polyline.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int shift = 0, result = 0;
      int b;
      do {
        b = polyline.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = polyline.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      coordinates.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return coordinates;
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Route to Restaurant'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
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
        polylines: _polylines,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
      ),
    );
  }
}
