import 'package:flutter/foundation.dart';
import 'package:test3/models/food.dart';
import 'package:test3/models/location.dart';

class Restaurant {
  final int id;
  final String name;
  final String cuisineType;
  final int price;
  final int totalReviews;
  final String imageUrl;
  final List<Food> menuIds;
  final Location location;

  Restaurant({
    required this.id, 
    required this.name, 
    required this.cuisineType, 
    required this.price, 
    required this.totalReviews, 
    required this.imageUrl, 
    required this.menuIds, 
    required this.location
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['restaurant_id'], 
      name: json['name'], 
      cuisineType: json['cuisine_type'], 
      price: json['price'], 
      totalReviews: json['total_reviews'], 
      imageUrl: json['image_url'], 
      menuIds: (json['menu_ids'] as List<dynamic>) 
          .map((item) => Food.fromJson(item)) 
          .toList(), 
      location: Location.fromJson(json),
      );
  }
}