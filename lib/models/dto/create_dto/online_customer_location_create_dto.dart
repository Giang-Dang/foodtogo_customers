class OnlineCustomerLocationCreateDTO {
  const OnlineCustomerLocationCreateDTO({
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
}
