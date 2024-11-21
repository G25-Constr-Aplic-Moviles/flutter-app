import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:test3/services/history_service.dart';
import 'package:test3/services/api_service.dart';
import 'package:test3/models/restaurant_model.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final HistoryService _historyService = HistoryService();
  final ApiService _apiService = ApiService();
  List _history = [];
  Map<int, Restaurant> _restaurants = {};
  List _filteredHistory = [];
  String _searchQuery = '';
  bool _isLoading = true;
  String _filterOption = 'All';
  bool _noInternet = false;
  late StreamSubscription _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _fetchHistory();
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      if (result != ConnectivityResult.none) {
        setState(() {
          _noInternet = false;
          _fetchHistory();
        });
      }
    });
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  Future<void> _fetchHistory() async {
    setState(() {
      _isLoading = true;
      _noInternet = false;
    });

    // Check internet connection
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      setState(() {
        _noInternet = true;
        _isLoading = false;
      });
      return;
    }

    List history = await _historyService.fetchHistory();
    Map<int, Restaurant> restaurants = {};

    for (var entry in history) {
      int restaurantId = entry['restaurant_id'];
      if (!restaurants.containsKey(restaurantId)) {
        var restaurant = await _apiService.fetchRestaurant(restaurantId);
        if (restaurant != null) {
          restaurants[restaurantId] = restaurant;
        }
      }
    }

    setState(() {
      _history = history;
      _restaurants = restaurants;
      _filteredHistory = history;
      _isLoading = false;
    });
  }

  void _filterHistory(String query) {
    setState(() {
      _searchQuery = query;
      _applyFilters();
    });
  }

  void _applyFilters() {
    List filtered = _history.where((entry) {
      var restaurant = _restaurants[entry['restaurant_id']];
      return restaurant?.name.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false;
    }).toList();

    if (_filterOption == 'Most Visited') {
      Map<int, int> visitCounts = {};
      for (var entry in _history) {
        int restaurantId = entry['restaurant_id'];
        if (!visitCounts.containsKey(restaurantId)) {
          visitCounts[restaurantId] = 0;
        }
        visitCounts[restaurantId] = visitCounts[restaurantId]! + 1;
      }
      int mostVisitedId = visitCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
      filtered = filtered.where((entry) => entry['restaurant_id'] == mostVisitedId).toList();
    } else if (_filterOption == 'Least Visited') {
      Map<int, int> visitCounts = {};
      for (var entry in _history) {
        int restaurantId = entry['restaurant_id'];
        if (!visitCounts.containsKey(restaurantId)) {
          visitCounts[restaurantId] = 0;
        }
        visitCounts[restaurantId] = visitCounts[restaurantId]! + 1;
      }
      int leastVisitedId = visitCounts.entries.reduce((a, b) => a.value < b.value ? a : b).key;
      filtered = filtered.where((entry) => entry['restaurant_id'] == leastVisitedId).toList();
    } else if (_filterOption == 'Visited This Week') {
      DateTime now = DateTime.now();
      DateTime oneWeekAgo = now.subtract(const Duration(days: 7));
      filtered = filtered.where((entry) {
        var visitDate = DateFormat("EEE, dd MMM yyyy HH:mm:ss 'GMT'").parseUTC(entry['timestamp']).toLocal();
        return visitDate.isAfter(oneWeekAgo) && visitDate.isBefore(now);
      }).toList();
    }

    setState(() {
      _filteredHistory = filtered;
    });
  }

  void _showRestaurantHistory(int restaurantId) {
    var restaurantHistory = _history.where((entry) => entry['restaurant_id'] == restaurantId).toList();
    var restaurantName = _restaurants[restaurantId]?.name ?? 'Unknown';

    // Calcular el número de visitas en la última semana
    DateTime now = DateTime.now();
    DateTime oneWeekAgo = now.subtract(const Duration(days: 7));
    int visitsThisWeek = restaurantHistory.where((entry) {
      var visitDate = DateFormat("EEE, dd MMM yyyy HH:mm:ss 'GMT'").parseUTC(entry['timestamp']).toLocal();
      return visitDate.isAfter(oneWeekAgo) && visitDate.isBefore(now);
    }).length;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Center(child: Text('History of $restaurantName')),
          content: restaurantHistory.isEmpty
              ? const Text('No entries found for this restaurant.')
              : SizedBox(
            width: double.maxFinite,
            height: 300.0, // Set a fixed height for the scrollable area
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Total visits: ${restaurantHistory.length} - This week: $visitsThisWeek'),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: restaurantHistory.length,
                    itemBuilder: (context, index) {
                      var entry = restaurantHistory[index];
                      var visitDate = DateFormat("EEE, dd MMM yyyy HH:mm:ss 'GMT'").parseUTC(entry['timestamp']).toLocal();
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        elevation: 3,
                        child: ListTile(
                          leading: const Icon(Icons.calendar_today, color: Colors.blue),
                          title: Text(
                            'Visited on ${visitDate.day}/${visitDate.month}/${visitDate.year}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Close',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromRGBO(255, 82, 71, 1),
          title: const Text('Visit History'),
        ),
        body: Column(
          children: [
          Container(
          color: Colors.white,
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search restaurant...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: PopupMenuButton<String>(
                      icon: const Icon(Icons.filter_list),
                      onSelected: (String value) {
                        setState(() {
                          _filterOption = value;
                          _applyFilters();
                        });
                      },
                      itemBuilder: (BuildContext context) {
                        return ['All', 'Most Visited', 'Least Visited', 'Visited This Week'].map((String choice) {
                          return PopupMenuItem<String>(
                            value: choice,
                            child: Text(choice),
                          );
                        }).toList();
                      },
                    ),
                  ),
                  onChanged: _filterHistory,
                ),
              ),
            ],
          ),
        ),
        if (_noInternet)
    Container(
      color: Colors.red,
      padding: const EdgeInsets.all(8.0),
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off, color: Colors.white, size: 24),
          const SizedBox(width: 10),
          const Text(
            'No internet connection',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredHistory.isEmpty
                  ? Center(
                child: _searchQuery.isEmpty
                    ? const Text('No entries found.')
                    : const Text('No restaurants match your search.'),
              )
                  : ListView.builder(
                itemCount: _filteredHistory.length,
                itemBuilder: (context, index) {
                  var entry = _filteredHistory[index];
                  var restaurant = _restaurants[entry['restaurant_id']];
                  var restaurantName = restaurant?.name ?? 'Unknown';
                  var visitDate = DateFormat("EEE, dd MMM yyyy HH:mm:ss 'GMT'").parseUTC(entry['timestamp']).toLocal();

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    elevation: 5,
                    child: ListTile(
                      leading: const Icon(Icons.restaurant, color: Colors.blue),
                      title: Text(
                        restaurantName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text('Visited on ${visitDate.day}/${visitDate.month}/${visitDate.year}'),
                      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.blue),
                      onTap: () => _showRestaurantHistory(entry['restaurant_id']),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
    );
  }
}
