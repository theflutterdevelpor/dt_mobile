class AqiResponse {
  final bool success;
  final int code;
  final AqiData data;

  AqiResponse({
    required this.success,
    required this.code,
    required this.data,
  });

  factory AqiResponse.fromJson(Map<String, dynamic> json) {
    return AqiResponse(
      success: json['success'] ?? false,
      code: json['code'] ?? 0,
      data: AqiData.fromJson(json['data']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'code': code,
      'data': data.toJson(),
    };
  }
}

class AqiData {
  final String id;
  final String deviceId;
  final DateTime readingTime;
  final int pm1;
  final int pm2_5;
  final int pm10;
  final int temperature;
  final int humidity;
  final int tvoc;
  final int co2;
  final int iaq;
  final String type;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int v;

  AqiData({
    required this.id,
    required this.deviceId,
    required this.readingTime,
    required this.pm1,
    required this.pm2_5,
    required this.pm10,
    required this.temperature,
    required this.humidity,
    required this.tvoc,
    required this.co2,
    required this.iaq,
    required this.type,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  factory AqiData.fromJson(Map<String, dynamic> json) {
    return AqiData(
      id: json['_id'] ?? '',
      deviceId: json['deviceId'] ?? '',
      readingTime: DateTime.parse(json['readingTime']),
      pm1: (json['pm1'] as num?)?.toInt() ?? 0,
      pm2_5: (json['pm2_5'] as num?)?.toInt() ?? 0,
      pm10: (json['pm10'] as num?)?.toInt() ?? 0,
      temperature: (json['temperature'] as num?)?.toInt() ?? 0,
      humidity: (json['humidity'] as num?)?.toInt() ?? 0,
      tvoc: (json['tvoc'] as num?)?.toInt() ?? 0,
      co2: (json['co2'] as num?)?.toInt() ?? 0,
      iaq: (json['iaq'] as num?)?.toInt() ?? 0,
      type: json['type'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      v: json['__v'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'deviceId': deviceId,
      'readingTime': readingTime.toIso8601String(),
      'pm1': pm1,
      'pm2_5': pm2_5,
      'pm10': pm10,
      'temperature': temperature,
      'humidity': humidity,
      'tvoc': tvoc,
      'co2': co2,
      'iaq': iaq,
      'type': type,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      '__v': v,
    };
  }
}
