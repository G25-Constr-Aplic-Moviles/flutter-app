class Restaurant {
  final int id;
  final String name;
  final String cuisineType;
  final int totalReviews;
  final String imageUrl;
  final String address;
  final double averageRating;
  final double latitude;
  final double longitude;

  Restaurant({
    required this.id,
    required this.name,
    required this.cuisineType,
    required this.totalReviews,
    required this.averageRating,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.imageUrl,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      name: json['name'],
      address: json['address'],
      latitude: json['location']['latitude'],
      longitude: json['location']['longitude'],
      imageUrl: json['image_url'],
      id: json['restaurant_id'],
      cuisineType: json['cuisine_type'],
      totalReviews: json['total_reviews'],
      averageRating: json['average_rating'] is int
          ? (json['average_rating'] as int).toDouble()
          : double.parse(json['average_rating'].toString()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'cuisineType': cuisineType,
      'totalReviews': totalReviews,
      'imageUrl': imageUrl,
      'address': address,
      'averageRating': averageRating,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
