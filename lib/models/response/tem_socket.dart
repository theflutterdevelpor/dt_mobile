class TemperatureSocketData {
  final double temperature;
  final double humidity;
  final DateTime updatedAt;

  TemperatureSocketData({
    required this.temperature,
    required this.humidity,
    required this.updatedAt,
  });

  factory TemperatureSocketData.fromJson(Map<String, dynamic> json) {
    return TemperatureSocketData(
      temperature: (json['temperature'] as num?)?.toDouble() ?? 0.0,
      humidity: (json['humidity'] as num?)?.toDouble() ?? 0.0,
      updatedAt:
      DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }
}
