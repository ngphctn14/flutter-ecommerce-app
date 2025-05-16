class Review {
  final String username;
  final String comment;
  final int rating;

  Review({required this.username, required this.comment, required this.rating});

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      username: json['username'],
      comment: json['comment'],
      rating: json['rating'],
    );
  }
}
