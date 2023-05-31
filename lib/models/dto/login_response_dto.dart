import 'package:foodtogo_customers/models/dto/user_dto.dart';

class LoginResponseDTO {
  const LoginResponseDTO({
    this.user,
    this.token,
    required this.isSuccess,
    required this.errorMessage,
  });

  final UserDTO? user;
  final String? token;
  final bool isSuccess;
  final String errorMessage;
}
