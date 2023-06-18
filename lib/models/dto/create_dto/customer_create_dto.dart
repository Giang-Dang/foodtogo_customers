class CustomerCreateDTO {
  final int customerId;
  final String firstName;
  final String lastName;
  final String middleName;
  final String address;

  const CustomerCreateDTO({
    required this.customerId,
    required this.firstName,
    required this.lastName,
    required this.middleName,
    required this.address,
  });

  factory CustomerCreateDTO.fromJson(Map<String, dynamic> json) {
    return CustomerCreateDTO(
      customerId: json['customerId'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      middleName: json['middleName'],
      address: json['address'],
    );
  }

  Map<String, dynamic> toJson() => {
        'customerId': customerId,
        'firstName': firstName,
        'lastName': lastName,
        'middleName': middleName,
        'address': address,
      };
}
