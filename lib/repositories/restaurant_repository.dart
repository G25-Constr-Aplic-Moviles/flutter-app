abstract class RestaurantRepository {
  Future<List> fetchRestaurants();
  Future<List> fetchRecommendedRestaurants(String idUsuario);
  Future<List> fetchMenu(int idRestaurant);
  Future<Map> fetchRoute(double originLat, double originLng, double destLat, double destLng, String apiKey);
}