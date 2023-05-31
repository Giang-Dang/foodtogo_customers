class APIResponseDTO {
  const APIResponseDTO({
    required this.statusCode,
    required this.isSuccess,
    this.errorMessages,
    this.result,
  });
  final int statusCode;
  final bool isSuccess;
  final List<String>? errorMessages;
  final Object? result;
}
