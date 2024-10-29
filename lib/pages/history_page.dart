import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:test3/services/history_service.dart';
import 'package:test3/services/api_service.dart';
import 'package:test3/models/restaurant_model.dart';

class HistoryPage extends StatefulWidget {
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

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    setState(() {
      _isLoading = true;
    });

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
    }

    setState(() {
      _filteredHistory = filtered;
    });
  }

  void _showRestaurantHistory(int restaurantId) {
    var restaurantHistory = _history.where((entry) => entry['restaurant_id'] == restaurantId).toList();
    var restaurantName = _restaurants[restaurantId]?.name ?? 'Unknown';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Center(child: Text('History of $restaurantName')),
          content: restaurantHistory.isEmpty
              ? Text('No entries found for this restaurant.')
              : Container(
            width: double.maxFinite,
            height: 300.0, // Set a fixed height for the scrollable area
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Total visits: ${restaurantHistory.length}'),
                ),
                SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: restaurantHistory.length,
                    itemBuilder: (context, index) {
                      var entry = restaurantHistory[index];
                      var visitDate = DateFormat("EEE, dd MMM yyyy HH:mm:ss 'GMT'").parseUTC(entry['timestamp']).toLocal();
                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 4.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        elevation: 3,
                        child: ListTile(
                          leading: Icon(Icons.calendar_today, color: Colors.blue),
                          title: Text(
                            'Visited on ${visitDate.day}/${visitDate.month}/${visitDate.year}',
                            style: TextStyle(fontWeight: FontWeight.bold),
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
              child: Text(
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
        title: Text('Visit History'),
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
                      prefixIcon: Icon(Icons.search),
                      suffixIcon: PopupMenuButton<String>(
                        icon: Icon(Icons.filter_list),
                        onSelected: (String value) {
                          setState(() {
                            _filterOption = value;
                            _applyFilters();
                          });
                        },
                        itemBuilder: (BuildContext context) {
                          return ['All', 'Most Visited', 'Least Visited'].map((String choice) {
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
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _filteredHistory.isEmpty
                ? Center(
              child: _searchQuery.isEmpty
                  ? Text('No entries found.')
                  : Text('No restaurants match your search.'),
            )
                : ListView.builder(
              itemCount: _filteredHistory.length,
              itemBuilder: (context, index) {
                var entry = _filteredHistory[index];
                var restaurant = _restaurants[entry['restaurant_id']];
                var restaurantName = restaurant?.name ?? 'Unknown';
                var visitDate = DateFormat("EEE, dd MMM yyyy HH:mm:ss 'GMT'").parseUTC(entry['timestamp']).toLocal();

                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  elevation: 5,
                  child: ListTile(
                    leading: Icon(Icons.restaurant, color: Colors.blue),
                    title: Text(
                      restaurantName,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('Visited on ${visitDate.day}/${visitDate.month}/${visitDate.year}'),
                    trailing: Icon(Icons.arrow_forward_ios, color: Colors.blue),
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
