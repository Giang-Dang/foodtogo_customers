class OnlineShipperStatusCreateDTO {
  final int shipperId;
  final double geoLatitude;
  final double geoLongitude;
  final bool isAvailable;

  OnlineShipperStatusCreateDTO({
    required this.shipperId,
    required this.geoLatitude,
    required this.geoLongitude,
    required this.isAvailable,
  });

  Map<String, dynamic> toJson() => {
        'shipperId': shipperId,
        'geoLatitude': geoLatitude,
        'geoLongitude': geoLongitude,
        'isAvailable': isAvailable,
      };
}