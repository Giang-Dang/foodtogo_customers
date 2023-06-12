class MerchantDTO {
  const MerchantDTO({
    required this.merchantId,
    required this.userId,
    required this.name,
    required this.address,
    required this.phoneNumber,
    required this.geoLatitude,
    required this.geoLongitude,
    required this.isDeleted,
    required this.rating,
  });
  final int merchantId;
  final int userId;
  final String name;
  final String address;
  final String phoneNumber;
  final double geoLatitude;
  final double geoLongitude;
  final bool isDeleted;
  final double rating;

  factory MerchantDTO.fromJson(Map<String, dynamic> json) {
    return MerchantDTO(
      merchantId: json['merchantId'],
      userId: json['userId'],
      name: json['name'],
      address: json['address'],
      phoneNumber: json['phoneNumber'],
      geoLatitude: json['geoLatitude'],
      geoLongitude: json['geoLongitude'],
      isDeleted: json['isDeleted'],
      rating: json['rating'],
    );
  }
}
