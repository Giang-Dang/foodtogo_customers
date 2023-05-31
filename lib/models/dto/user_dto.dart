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
}
