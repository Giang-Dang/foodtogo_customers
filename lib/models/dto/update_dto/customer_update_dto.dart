class CustomerUpdateDTO {
  final int customerId;
  final String firstName;
  final String lastName;
  final String middleName;
  final String address;
  final double rating;

  const CustomerUpdateDTO({
    required this.customerId,
    required this.firstName,
    required this.lastName,
    required this.middleName,
    required this.address,
    required this.rating,
  });

  factory CustomerUpdateDTO.fromJson(Map<String, dynamic> json) {
    return CustomerUpdateDTO(
      customerId: json['customerId'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      middleName: json['middleName'],
      address: json['address'],
      rating: json['rating'],
    );
  }

  Map<String, dynamic> toJson() => {
        'customerId': customerId,
        'firstName': firstName,
        'lastName': lastName,
        'middleName': middleName,
        'address': address,
        'rating': rating,
      };
}
