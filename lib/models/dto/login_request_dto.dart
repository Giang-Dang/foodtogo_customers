class LoginRequestDTO {
  const LoginRequestDTO({
    required this.username,
    required this.password,
    required this.loginFromApp,
  });

  final String username;
  final String password;
  final String loginFromApp;
}
