class AqiAggregatedDataPoint {
  final double? avgPm1;
  final double? avgPm2_5;
  final double? avgPm2;
  final double? avgTemperature;
  final double? avgHumidity;
  final double? avgTvoc;
  final double? avgCo2;
  final double? avgIaq;
  final double? co2Variance;
  final String deviceId;
  final DateTime hour;

  AqiAggregatedDataPoint({
    this.avgPm1,
    this.avgPm2_5,
    this.avgPm2,
    this.avgTemperature,
    this.avgHumidity,
    this.avgTvoc,
    this.avgCo2,
    this.avgIaq,
    this.co2Variance,
    required this.deviceId,
    required this.hour,
  });

  factory AqiAggregatedDataPoint.fromJson(Map<String, dynamic> json) {
    double? toDouble(dynamic value) {
      if (value == null) return null;
      if (value is int) return value.toDouble();
      if (value is double) return value;
      return double.tryParse(value.toString());
    }

    return AqiAggregatedDataPoint(
      avgPm1: toDouble(json['avgPm1']),
      avgPm2_5: toDouble(json['avgPm2_5']),
      avgPm2: toDouble(json['avgPm2']),
      avgTemperature: toDouble(json['avgTemperature']),
      avgHumidity: toDouble(json['avgHumidity']),
      avgTvoc: toDouble(json['avgTvoc']),
      avgCo2: toDouble(json['avgCo2']),
      avgIaq: toDouble(json['avgIaq']),
      co2Variance: toDouble(json['co2Variance']),
      deviceId: json['deviceId'] ?? '',
      hour: DateTime.tryParse(json['hour'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'avgPm1': avgPm1,
      'avgPm2_5': avgPm2_5,
      'avgPm2': avgPm2,
      'avgTemperature': avgTemperature,
      'avgHumidity': avgHumidity,
      'avgTvoc': avgTvoc,
      'avgCo2': avgCo2,
      'avgIaq': avgIaq,
      'co2Variance': co2Variance,
      'deviceId': deviceId,
      'hour': hour.toIso8601String(),
    };
  }
}

class AqiAggregatedResponse {
  final bool success;
  final int code;
  final List<AqiAggregatedDataPoint> data;

  AqiAggregatedResponse({
    required this.success,
    required this.code,
    required this.data,
  });

  factory AqiAggregatedResponse.fromJson(Map<String, dynamic> json) {
    return AqiAggregatedResponse(
      success: json['success'] ?? false,
      code: json['code'] ?? 0,
      data: (json['data'] as List<dynamic>? ?? [])
          .map((e) => AqiAggregatedDataPoint.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'code': code,
      'data': data.map((e) => e.toJson()).toList(),
    };
  }
}