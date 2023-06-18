class MerchantRatingCreateDTO {
  final int id;
  final int fromUserId;
  final String fromUserType;
  final int toMerchantId;
  final int orderId;
  final double rating;

  MerchantRatingCreateDTO({
    required this.id,
    required this.fromUserId,
    required this.fromUserType,
    required this.toMerchantId,
    required this.orderId,
    required this.rating,
  });

  factory MerchantRatingCreateDTO.fromJson(Map<String, dynamic> json) {
    return MerchantRatingCreateDTO(
      id: json['id'],
      fromUserId: json['fromUserId'],
      fromUserType: json['fromUserType'],
      toMerchantId: json['toMerchantId'],
      orderId: json['orderId'],
      rating: json['rating'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'fromUserId': fromUserId,
        'fromUserType': fromUserType,
        'toMerchantId': toMerchantId,
        'orderId': orderId,
        'rating': rating,
      };
}
