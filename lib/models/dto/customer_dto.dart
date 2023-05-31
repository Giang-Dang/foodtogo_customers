class CustomerDTO {
  final int customerId;
  final String firstName;
  final String lastName;
  final String middleName;
  final String address;

  const CustomerDTO(
      {required this.customerId,
      required this.firstName,
      required this.lastName,
      required this.middleName,
      required this.address});

  factory CustomerDTO.fromJson(Map<String, dynamic> json) {
    return CustomerDTO(
        customerId: json['customerId'],
        firstName: json['firstName'],
        lastName: json['lastName'],
        middleName: json['middleName'],
        address: json['address']);
  }
}
