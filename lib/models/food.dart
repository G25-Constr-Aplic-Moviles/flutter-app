class Food{
  final int id;
  final String name;
  final double price;
  final String description;
  final String imageUrl;



  Food({
    required this.id, 
    required this.name, 
    required this.price, 
    required this.description, 
    required this.imageUrl, 
    });

  factory Food.fromJson(Map<String, dynamic> json) {
    return Food(
      id: json['item_id'],
      name: json['name'],
      price: json['price'],
      description: json['description'],
      imageUrl: json['image_url'],
    );

  }
}