abstract class HistoryRepository {
  Future<List> fetchHistory();

  Future<void> markRestaurantVisited(int restaurantId);

}