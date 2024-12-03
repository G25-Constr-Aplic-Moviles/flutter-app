class Discount {
  final bool discount50off;
  final bool discount20off;
  final int restaurantId;

  Discount({
    required this.restaurantId,
    required this.discount50off,
    required this.discount20off,
  });

  factory Discount.fromJson(Map<String, dynamic> json) {
    return Discount(
      restaurantId: json['restaurant_id'],
      discount50off: json['discount_50off'],
      discount20off: json['discount_20off'],
    );
  }
}