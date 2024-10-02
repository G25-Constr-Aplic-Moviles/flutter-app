class Food{
  String image;
  String price;
  String name;

  Food({
    required this.image,
    required this.price,
    required this.name,
  });

  String get _name => name;
  String get _price => price;
  String get _image => image;
}