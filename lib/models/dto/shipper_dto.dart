class ShipperDTO {
  final int userId;
  final String firstName;
  final String lastName;
  final String middleName;
  final String vehicleType;
  final String vehicleNumberPlate;
  final double rating;

  const ShipperDTO({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.middleName,
    required this.vehicleType,
    required this.vehicleNumberPlate,
    required this.rating,
  });

  factory ShipperDTO.fromJson(Map<String, dynamic> json) {
    return ShipperDTO(
      userId: json['userId'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      middleName: json['middleName'],
      vehicleType: json['vehicleType'],
      vehicleNumberPlate: json['vehicleNumberPlate'],
      rating: json['rating'],
    );
  }
}
