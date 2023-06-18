class UserDTO {
  const UserDTO({
    required this.id,
    required this.username,
    required this.role,
    required this.phoneNumber,
    required this.email,
  });

  final int id;
  final String username;
  final String role;
  final String phoneNumber;
  final String email;

  factory UserDTO.fromJson(Map<String, dynamic> json) => UserDTO(
        id: json['id'],
        username: json['username'],
        role: json['role'],
        phoneNumber: json['phoneNumber'],
        email: json['email'],
      );
}
