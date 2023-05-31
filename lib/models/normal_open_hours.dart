class NormalOpenHours {
  final int id;
  final int merchantId;
  final int dayOfWeek;
  final int sessionNo;
  final DateTime openTime;
  final DateTime closeTime;

  NormalOpenHours({
    required this.id,
    required this.merchantId,
    required this.dayOfWeek,
    required this.sessionNo,
    required this.openTime,
    required this.closeTime,
  });

  factory NormalOpenHours.fromJson(Map<String, dynamic> json) {
    return NormalOpenHours(
      id: json['id'],
      merchantId: json['merchantId'],
      dayOfWeek: json['dayOfWeek'],
      sessionNo: json['sessionNo'],
      openTime: DateTime.parse(json['openTime']),
      closeTime: DateTime.parse(json['closeTime']),
    );
  }
}
