class UserRatingDTO {
  final int id;
  final int fromUserId;
  final String fromUserType;
  final int toUserId;
  final String toUserType;
  final int orderId;
  final double rating;

  UserRatingDTO({
    required this.id,
    required this.fromUserId,
    required this.fromUserType,
    required this.toUserId,
    required this.toUserType,
    required this.orderId,
    required this.rating,
  });

  factory UserRatingDTO.fromJson(Map<String, dynamic> json) {
    return UserRatingDTO(
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
