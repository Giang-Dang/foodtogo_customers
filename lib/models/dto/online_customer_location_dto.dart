class OnlineCustomerLocationDTO {
  const OnlineCustomerLocationDTO({
    required this.customerId,
    required this.geoLatitude,
    required this.geoLongitude,
  });

  final int customerId;
  final double geoLatitude;
  final double geoLongitude;

  Map<String, String> toJson() => {
        'customerId': customerId.toString(),
        'geoLatitude': geoLatitude.toString(),
        'geoLongitude': geoLongitude.toString(),
      };

  factory OnlineCustomerLocationDTO.fromJson(Map<String, dynamic> json) {
    return OnlineCustomerLocationDTO(
      customerId: int.parse(json['customerId']),
      geoLatitude: double.parse(json['geoLatitude']),
      geoLongitude: double.parse(json['geoLongitude']),
    );
  }
}
