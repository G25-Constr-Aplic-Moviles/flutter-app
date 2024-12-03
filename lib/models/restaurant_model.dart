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

  // Factory constructor para crear una instancia de Restaurant desde JSON
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

  // Método para convertir una instancia de Restaurant a un mapa
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

  // Método para crear una instancia de Restaurant desde un mapa
  factory Restaurant.fromMap(Map<String, dynamic> map) {
    return Restaurant(
      id: map['id'],
      name: map['name'],
      cuisineType: map['cuisineType'],
      totalReviews: map['totalReviews'],
      imageUrl: map['imageUrl'],
      address: map['address'],
      averageRating: map['averageRating'],
      latitude: map['latitude'],
      longitude: map['longitude'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
      'location': {
        'latitude': latitude,
        'longitude': longitude,
      },
      'image_url': imageUrl,
      'restaurant_id': id,
      'cuisine_type': cuisineType,
      'total_reviews': totalReviews,
      'average_rating': averageRating,
    };
  }
}

