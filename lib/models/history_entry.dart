class HistoryEntry {
  final String restaurantName;
  final String date;

  HistoryEntry({
    required this.restaurantName,
    required this.date,
  });

  factory HistoryEntry.fromJson(Map<String, dynamic> json) {
    return HistoryEntry(
        restaurantName: json['name'],
        date: json['date'],
    );
  }
}
