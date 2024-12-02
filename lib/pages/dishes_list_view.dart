import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test3/models/food.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:intl/intl.dart'; // Importar para formatear el precio

import '../viewmodels/MenuItemViewModel.dart';

class FoodListView extends StatefulWidget {
  const FoodListView({super.key});

  @override
  _FoodListViewState createState() => _FoodListViewState();
}

class _FoodListViewState extends State<FoodListView> {
  bool _isConnected = true;
  late Connectivity _connectivity;
  late Stream<ConnectivityResult> _connectivityStream;

  @override
  void initState() {
    super.initState();
    _connectivity = Connectivity();
    _connectivityStream = _connectivity.onConnectivityChanged;
    _connectivityStream.listen((ConnectivityResult result) {
      if (result != ConnectivityResult.none) {
        setState(() {
          _isConnected = true;
        });
        // Recargar la lista de platos cuando se recupere la conexión
        Provider.of<MenuItemViewModel>(context, listen: false).fetchAllMenus();
      } else {
        setState(() {
          _isConnected = false;
        });
      }
    });
    _checkInternetConnection();
    // Cargar todos los menús al iniciar la vista
    Provider.of<MenuItemViewModel>(context, listen: false).fetchAllMenus();
  }

  Future<void> _checkInternetConnection() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      setState(() {
        _isConnected = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Platos', style: TextStyle(fontSize: 28)),
      ),
      body: _isConnected
          ? Consumer<MenuItemViewModel>(
        builder: (context, menuItemViewModel, child) {
          if (menuItemViewModel.allFoodMenu.isEmpty) {
            return Center(child: CircularProgressIndicator());
          } else {
            // Ordenar los platos alfabéticamente por nombre
            menuItemViewModel.allFoodMenu.sort((a, b) => a['food'].name.compareTo(b['food'].name));
            return ListView.builder(
              itemCount: menuItemViewModel.allFoodMenu.length,
              itemBuilder: (context, index) {
                var item = menuItemViewModel.allFoodMenu[index];
                Food food = item['food'];
                String restaurantName = item['restaurantName'];
                String restaurantAddress = item['restaurantAddress'];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 15), // Espacio de separación más pequeño
                  child: ListTile(
                    contentPadding: EdgeInsets.all(20),
                    leading: CachedNetworkImage(
                      imageUrl: food.imageUrl,
                      placeholder: (context, url) => CircularProgressIndicator(),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                      width: 120, // Tamaño fijo para las imágenes
                      height: 120, // Tamaño fijo para las imágenes
                      fit: BoxFit.cover,
                    ),
                    title: Text(
                      food.name,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          food.description.length > 50
                              ? '${food.description.substring(0, 50)}...'
                              : food.description,
                          style: TextStyle(fontSize: 18),
                        ),
                        if (food.description.length > 50)
                          GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text(food.name, style: TextStyle(fontSize: 24)),
                                  content: Text(food.description, style: TextStyle(fontSize: 18)),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text('Close', style: TextStyle(fontSize: 18)),
                                    ),
                                  ],
                                ),
                              );
                            },
                            child: Text(
                              'Show more',
                              style: TextStyle(color: Colors.blue, fontSize: 18),
                            ),
                          ),
                        SizedBox(height: 5),
                        Text(
                          NumberFormat.currency(locale: 'es_CO', symbol: '\$').format(food.price), // Formato de precio en Colombia
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Restaurant: $restaurantName',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        Text(
                          'Address: $restaurantAddress',
                          style: TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      )
          : Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off, size: 100, color: Colors.red),
            SizedBox(height: 20),
            Text(
              'No Internet Connection',
              style: TextStyle(fontSize: 24, color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}
