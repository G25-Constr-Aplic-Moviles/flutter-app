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

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
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
    });
  }

  void _filterHistory(String query) {
    setState(() {
      _searchQuery = query;
      _filteredHistory = _history.where((entry) {
        var restaurant = _restaurants[entry['restaurant_id']];
        return restaurant?.name.toLowerCase().contains(query.toLowerCase()) ?? false;
      }).toList();
    });
  }

  void _showRestaurantHistory(int restaurantId) {
    var restaurantHistory = _history.where((entry) => entry['restaurant_id'] == restaurantId).toList();
    var restaurantName = _restaurants[restaurantId]?.name ?? 'Unknown';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('History of $restaurantName'),
          content: restaurantHistory.isEmpty
              ? Text('No entries found for this restaurant.')
              : Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Total visits: ${restaurantHistory.length}'),
              ...restaurantHistory.map((entry) {
                var visitDate = DateFormat("EEE, dd MMM yyyy HH:mm:ss 'GMT'").parseUTC(entry['timestamp']).toLocal();
                return Card(
                  color: Colors.lightBlue[50],
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
              }).toList(),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close'),
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
        title: Text('Visit History'),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(48.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search restaurant...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: _filterHistory,
            ),
          ),
        ),
      ),
      body: _filteredHistory.isEmpty
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
            color: Colors.white,
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
    );
  }
}
