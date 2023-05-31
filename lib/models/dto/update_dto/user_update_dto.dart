class UserUpdateDTO {
  const UserUpdateDTO({
    required this.id,
    required this.phoneNumber,
    required this.email,
  });
  final int id;
  final String phoneNumber;
  final String email;
}
