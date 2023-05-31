class NormalOpenHoursUpdateDTO {
  final int id;
  final int merchantId;
  final int dayOfWeek;
  final int sessionNo;
  final DateTime openTime;
  final DateTime closeTime;

  NormalOpenHoursUpdateDTO({
    required this.id,
    required this.merchantId,
    required this.dayOfWeek,
    required this.sessionNo,
    required this.openTime,
    required this.closeTime,
  });

  factory NormalOpenHoursUpdateDTO.fromJson(Map<String, dynamic> json) {
    return NormalOpenHoursUpdateDTO(
      id: json['id'],
      merchantId: json['merchantId'],
      dayOfWeek: json['dayOfWeek'],
      sessionNo: json['sessionNo'],
      openTime: DateTime.parse(json['OpenTime']),
      closeTime: DateTime.parse(json['CloseTime']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'merchantId': merchantId,
        'dayOfWeek': dayOfWeek,
        'sessionNo': sessionNo,
        'openTime': openTime.toIso8601String(),
        'closeTime': closeTime.toIso8601String(),
      };
}
