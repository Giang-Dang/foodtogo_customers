class MerchantProfileImageUpdateDTO {
  const MerchantProfileImageUpdateDTO({
    required this.id,
    required this.merchantId,
    required this.path,
  });
  final int id;
  final int merchantId;
  final String path;
}
