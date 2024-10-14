class Restaurant {
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String imageUrl;

  Restaurant({
    required this.name,
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
    );
  }
}
