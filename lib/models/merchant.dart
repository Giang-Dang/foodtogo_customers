class Merchant {
  const Merchant({
    required this.merchantId,
    required this.userId,
    required this.name,
    required this.address,
    required this.phoneNumber,
    required this.geoLatitude,
    required this.geoLongitude,
    required this.isDeleted,
    required this.imagePath,
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
  final String imagePath;
  final double rating;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    if (other is Merchant &&
        runtimeType == other.runtimeType &&
        merchantId == other.merchantId &&
        userId == other.userId &&
        name == other.name &&
        address == other.address &&
        phoneNumber == other.phoneNumber &&
        geoLatitude == other.geoLatitude &&
        geoLongitude == other.geoLongitude &&
        isDeleted == other.isDeleted &&
        imagePath == other.imagePath &&
        rating == other.rating) return true;

    return false;
  }

  @override
  int get hashCode =>
      merchantId.hashCode ^
      userId.hashCode ^
      name.hashCode ^
      address.hashCode ^
      phoneNumber.hashCode ^
      geoLatitude.hashCode ^
      geoLongitude.hashCode ^
      isDeleted.hashCode ^
      imagePath.hashCode ^
      rating.hashCode;
}
