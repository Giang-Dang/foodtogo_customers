class OnlineShipperStatusDTO {
  final int shipperId;
  final double geoLatitude;
  final double geoLongitude;
  final bool isAvailable;

  OnlineShipperStatusDTO({
    required this.shipperId,
    required this.geoLatitude,
    required this.geoLongitude,
    required this.isAvailable,
  });

  factory OnlineShipperStatusDTO.fromJson(Map<String, dynamic> json) {
    return OnlineShipperStatusDTO(
      shipperId: json['shipperId'],
      geoLatitude: json['geoLatitude'],
      geoLongitude: json['geoLongitude'],
      isAvailable: json['isAvailable'],
    );
  }

  Map<String, dynamic> toJson() => {
        'shipperId': shipperId,
        'geoLatitude': geoLatitude,
        'geoLongitude': geoLongitude,
        'isAvailable': isAvailable,
      };
}
