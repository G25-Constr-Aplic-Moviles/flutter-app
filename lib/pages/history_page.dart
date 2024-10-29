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
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Historial de Visitas'),
      ),
      body: _history.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _history.length,
        itemBuilder: (context, index) {
          var entry = _history[index];
          var restaurant = _restaurants[entry['restaurant_id']];
          var restaurantName = restaurant?.name ?? 'Desconocido';
          var visitDate = DateFormat("EEE, dd MMM yyyy HH:mm:ss 'GMT'").parseUTC(entry['timestamp']).toLocal();

          return ListTile(
            title: Text(restaurantName),
            subtitle: Text('Visitado el ${visitDate.day}/${visitDate.month}/${visitDate.year}'),
          );
        },
      ),
    );
  }
}
