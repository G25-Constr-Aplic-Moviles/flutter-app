abstract class RestaurantRepository {
  Future<List> fetchRestaurants();
  Future<Map> fetchRoute(double originLat, double originLng, double destLat, double destLng, String apiKey);
}