class Rating {
  final int id;
  final int productId;
  final String userName;
  final int stars;
  final DateTime createdAt;

  Rating({
    required this.id,
    required this.productId,
    required this.userName,
    required this.stars,
    required this.createdAt,
  });

  factory Rating.fromJson(Map<String, dynamic> json) {
    return Rating(
      id: json['id'],
      productId: json['productId'],
      userName: json['userName'],
      stars: json['stars'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
