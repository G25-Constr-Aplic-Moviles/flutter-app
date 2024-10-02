class Review{
  String title;
  String username;
  double numberStars;
  String fullReview;

  Review({
    required this.title,
    required this.username,
    required this.numberStars,
    required this.fullReview,
  });

  String get _title => title;
  String get _username => username;
  double get _numberStars => numberStars;
  String get _fullReview => fullReview; 
}