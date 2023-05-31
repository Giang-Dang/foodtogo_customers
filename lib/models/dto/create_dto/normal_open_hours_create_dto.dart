class NormalOpenHoursCreateDTO {
  final int id;
  final int merchantId;
  final int dayOfWeek;
  final int sessionNo;
  final DateTime openTime;
  final DateTime closeTime;

  NormalOpenHoursCreateDTO({
    required this.id,
    required this.merchantId,
    required this.dayOfWeek,
    required this.sessionNo,
    required this.openTime,
    required this.closeTime,
  });

  factory NormalOpenHoursCreateDTO.fromJson(Map<String, dynamic> json) {
    return NormalOpenHoursCreateDTO(
      id: json['id'],
      merchantId: json['merchantId'],
      dayOfWeek: json['dayOfWeek'],
      sessionNo: json['sessionNo'],
      openTime: DateTime.parse(json['openTime']),
      closeTime: DateTime.parse(json['closeTime']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': 0,
        'merchantId': merchantId,
        'dayOfWeek': dayOfWeek,
        'sessionNo': sessionNo,
        'openTime': openTime.toIso8601String(),
        'closeTime': closeTime.toIso8601String(),
      };
}
