class RegisterRequestDTO {
  const RegisterRequestDTO({
    required this.username,
    required this.password,
    required this.phoneNumber,
    required this.email,
  });
  final String username;
  final String password;
  final String phoneNumber;
  final String email;
}
