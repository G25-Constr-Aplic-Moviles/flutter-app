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
  final TextEditingController _searchController = TextEditingController();
  String _currentFilter = '';
  String _priceFilter = '';

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
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text('Dishes List', style: TextStyle(fontSize: 28)),
      ),
      body: Consumer<MenuItemViewModel>(
        builder: (context, menuItemViewModel, child) {
          if (!_isConnected && menuItemViewModel.allFoodMenu.isEmpty) {
            return Center(
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
            );
          } else if (menuItemViewModel.allFoodMenu.isEmpty) {
            return Center(child: CircularProgressIndicator());
          } else {
            return Column(
              children: [
                if (!_isConnected)
                  Container(
                    color: Colors.red,
                    padding: EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.wifi_off, color: Colors.white),
                        SizedBox(width: 10),
                        Text(
                          'No Internet Connection',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search dishes...',
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.filter_list),
                              onPressed: () {
                                showModalBottomSheet(
                                  context: context,
                                  builder: (context) {
                                    return ListView(
                                      children: [
                                        ListTile(
                                          title: const Text('All', style: TextStyle(fontSize: 24),),
                                          onTap: () {
                                            setState(() {
                                              _priceFilter = '';
                                            });
                                            menuItemViewModel.filterByPrice(_priceFilter);
                                            Navigator.pop(context);
                                          },
                                        ),
                                        ListTile(
                                          title: const Text('Less than \$10,000', style: TextStyle(fontSize: 24),),
                                          onTap: () {
                                            setState(() {
                                              _priceFilter = 'less_than_10000';
                                            });
                                            menuItemViewModel.filterByPrice(_priceFilter);
                                            Navigator.pop(context);
                                          },
                                        ),
                                        ListTile(
                                          title: const Text('Between \$10,000 and \$20,000', style: TextStyle(fontSize: 24),),
                                          onTap: () {
                                            setState(() {
                                              _priceFilter = 'between_10000_20000';
                                            });
                                            menuItemViewModel.filterByPrice(_priceFilter);
                                            Navigator.pop(context);
                                          },
                                        ),
                                        ListTile(
                                          title: const Text('More than \$20,000', style: TextStyle(fontSize: 24),),
                                          onTap: () {
                                            setState(() {
                                              _priceFilter = 'more_than_20000';
                                            });
                                            menuItemViewModel.filterByPrice(_priceFilter);
                                            Navigator.pop(context);
                                          },
                                        ),
                                        ListTile(
                                          title: const Text('Top 5 Cheapest', style: TextStyle(fontSize: 24),),
                                          onTap: () {
                                            setState(() {
                                              _priceFilter = 'top_5_cheapest';
                                            });
                                            menuItemViewModel.filterByPrice(_priceFilter);
                                            Navigator.pop(context);
                                          },
                                        ),
                                        ListTile(
                                          title: const Text('Top 5 Most Expensive', style: TextStyle(fontSize: 24),),
                                          onTap: () {
                                            setState(() {
                                              _priceFilter = 'top_5_expensive';
                                            });
                                            menuItemViewModel.filterByPrice(_priceFilter);
                                            Navigator.pop(context);
                                          },
                                        ),
                                        ListTile(
                                          title: const Text('Restaurant with more dishes', style: TextStyle(fontSize: 24),),
                                          onTap: () {
                                            setState(() {
                                              _priceFilter = 'most_dishes';
                                            });
                                            menuItemViewModel.filterByPrice(_priceFilter);
                                            Navigator.pop(context);
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _currentFilter = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: menuItemViewModel.filteredFoodMenu.length,
                    itemBuilder: (context, index) {
                      var item = menuItemViewModel.filteredFoodMenu[index];
                      Food food = item['food'];
                      String restaurantName = item['restaurantName'];
                      String restaurantAddress = item['restaurantAddress'];

                      if (_currentFilter.isNotEmpty &&
                          !food.name.toLowerCase().contains(_currentFilter.toLowerCase()) &&
                          !restaurantName.toLowerCase().contains(_currentFilter.toLowerCase())) {
                        return Container();
                      }

                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 15), // Espacio de separación más pequeño
                        child: ListTile(
                          contentPadding: EdgeInsets.all(20),
                          leading: CachedNetworkImage(
                            imageUrl: food.imageUrl,
                            placeholder: (context, url) => CircularProgressIndicator(),
                            errorWidget: (context, url, error) => Icon(Icons.fastfood, size: 50, color: Colors.grey), // Ícono relacionado con comida
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
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
