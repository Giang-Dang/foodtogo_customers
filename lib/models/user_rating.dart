class UserRating {
  final int id;
  final int fromUserId;
  final String fromUserType;
  final int toUserId;
  final String toUserType;
  final int orderId;
  final double rating;

  UserRating({
    required this.id,
    required this.fromUserId,
    required this.fromUserType,
    required this.toUserId,
    required this.toUserType,
    required this.orderId,
    required this.rating,
  });

  factory UserRating.fromJson(Map<String, dynamic> json) {
    return UserRating(
      id: json['id'],
      fromUserId: json['fromUserId'],
      fromUserType: json['fromUserType'],
      toUserId: json['toUserId'],
      toUserType: json['toUserType'],
      orderId: json['orderId'],
      rating: json['rating'],
    );
  }
}
