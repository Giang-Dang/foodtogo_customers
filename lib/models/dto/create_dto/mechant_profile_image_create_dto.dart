class MerchantProfileImageCreateDTO {
  const MerchantProfileImageCreateDTO({
    this.id = 0,
    required this.merchantId,
    required this.path,
  });
  final int id;
  final int merchantId;
  final String path;
}
