class TemperatureThreshold {
  final double minTemperature;
  final double maxTemperature;

  TemperatureThreshold({
    required this.minTemperature,
    required this.maxTemperature,
  });

  factory TemperatureThreshold.fromJson(Map<String, dynamic> json) {
    return TemperatureThreshold(
      minTemperature: _toDouble(json['minTemperature']),
      maxTemperature: _toDouble(json['maxTemperature']),
    );
  }
}


double _toDouble(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0.0;
}

int _toInt(dynamic value) {
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

DateTime _parseDate(dynamic value) {
  final parsed = DateTime.tryParse(value?.toString() ?? '');
  return parsed ?? DateTime.fromMillisecondsSinceEpoch(0); // keeps invalid visible
}

String _toStringValue(dynamic value) {
  return value?.toString() ?? '';
}


class TemperatureLatestResponse {
  final bool success;
  final int code;
  final TemperatureLatestData data;

  TemperatureLatestResponse({
    required this.success,
    required this.code,
    required this.data,
  });

  factory TemperatureLatestResponse.fromJson(Map<String, dynamic> json) {
    return TemperatureLatestResponse(
      success: json['success'] ?? false,
      code: _toInt(json['code']),
      data: TemperatureLatestData.fromJson(json['data'] ?? {}),
    );
  }
}

class TemperatureLatestData {
  final String id;
  final String gatewayId;
  final String nodeId;
  final DateTime readingTime;
  final double temperature;
  final double humidity;
  final String type;
  final String location;
  final String battery;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime installationDate;
  final DateTime lastCalibration;
  final int v;
  final TemperatureThreshold threshold;

  TemperatureLatestData({
    required this.id,
    required this.gatewayId,
    required this.nodeId,
    required this.readingTime,
    required this.temperature,
    required this.humidity,
    required this.type,
    required this.location,
    required this.battery,
    required this.createdAt,
    required this.updatedAt,
    required this.installationDate,
    required this.lastCalibration,
    required this.v,
    required this.threshold,
  });

  factory TemperatureLatestData.fromJson(Map<String, dynamic> json) {
    final createdAt = _parseDate(json['createdAt']);

    return TemperatureLatestData(
      id: _toStringValue(json['_id']),
      gatewayId: _toStringValue(json['gatewayId']),
      nodeId: _toStringValue(json['nodeId']),

      readingTime: DateTime.tryParse(json['readingTime'] ?? '') ??
          createdAt,

      temperature: _toDouble(json['temperature']),
      humidity: _toDouble(json['humidity']),
      type: _toStringValue(json['type']),
      location: _toStringValue(json['location']),
      battery: _toStringValue(json['battery']),

      createdAt: createdAt,
      updatedAt: _parseDate(json['updatedAt']),
      installationDate: _parseDate(json['installationDate']),
      lastCalibration: _parseDate(json['lastCalibration']),

      v: _toInt(json['__v']),

      threshold: TemperatureThreshold.fromJson(
        json['threasold'] ?? {},
      ),
    );
  }

  TemperatureLatestData copyWith({
    double? temperature,
    double? humidity,
    DateTime? updatedAt,
    TemperatureThreshold? threshold,
    String? location,
    String? battery,
    DateTime? readingTime,
  }) {
    return TemperatureLatestData(
      id: id,
      gatewayId: gatewayId,
      nodeId: nodeId,
      readingTime: readingTime ?? this.readingTime,
      temperature: temperature ?? this.temperature,
      humidity: humidity ?? this.humidity,
      type: type,
      location: location ?? this.location,
      battery: battery ?? this.battery,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      installationDate: installationDate,
      lastCalibration: lastCalibration,
      v: v,
      threshold: threshold ?? this.threshold,
    );
  }
}


class TemperatureHistoryResponse {
  final bool success;
  final int code;
  final List<TemperatureHistoryItem> data;

  TemperatureHistoryResponse({
    required this.success,
    required this.code,
    required this.data,
  });

  factory TemperatureHistoryResponse.fromJson(Map<String, dynamic> json) {
    final List<dynamic> list = json['data'] ?? [];

    return TemperatureHistoryResponse(
      success: json['success'] ?? false,
      code: _toInt(json['code']),
      data: list
          .map((e) => TemperatureHistoryItem.fromJson(e))
          .toList(),
    );
  }
}

class TemperatureHistoryItem {
  final String id;
  final String gatewayId;
  final String nodeId;
  final double temperature;
  final double humidity;
  final String type;
  final DateTime createdAt;
  final TemperatureThreshold threshold;

  TemperatureHistoryItem({
    required this.id,
    required this.gatewayId,
    required this.nodeId,
    required this.temperature,
    required this.humidity,
    required this.type,
    required this.createdAt,
    required this.threshold,
  });

  factory TemperatureHistoryItem.fromJson(Map<String, dynamic> json) {
    return TemperatureHistoryItem(
      id: _toStringValue(json['_id']),
      gatewayId: _toStringValue(json['gatewayId']),
      nodeId: _toStringValue(json['nodeId']),
      temperature: _toDouble(json['temperature']),
      humidity: _toDouble(json['humidity']),
      type: _toStringValue(json['type']),
      createdAt: _parseDate(json['createdAt']),
      threshold: TemperatureThreshold.fromJson(
        json['threasold'] ?? {},
      ),
    );
  }
}