
class EnergyDetailsResponse {
  final bool success;
  final int code;
  final EnergyData data;

  EnergyDetailsResponse({
    required this.success,
    required this.code,
    required this.data,
  });

  factory EnergyDetailsResponse.fromJson(Map<String, dynamic> json) {
    return EnergyDetailsResponse(
      success: json['success'] ?? false,
      code: json['code'] ?? 0,
      data: EnergyData.fromJson(json['data'] ?? {}),
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

// Main Data Model
class EnergyData {
  final String location;
  final DateTime? installationDate;
  final DateTime? lastCalibration;
  final String battery;
  final List<dynamic> notification;
  final double todayEnergyUsage;
  final int todayOutageInSeconds;
  final double todayOutageInMinutes;
  final int totalComplains;
  final int resolvedComplains;
  final int total;
  final List<PhaseData> phaseOneData;
  final List<PhaseData> phaseTwoData;
  final List<PhaseData> phaseThreeData;
  final List<PhaseData> threePhaseData;

  EnergyData({
    required this.location,
    required this.installationDate,
    required this.lastCalibration,
    required this.battery,
    required this.notification,
    required this.todayEnergyUsage,
    required this.todayOutageInSeconds,
    required this.todayOutageInMinutes,
    required this.totalComplains,
    required this.resolvedComplains,
    required this.total,
    required this.phaseOneData,
    required this.phaseTwoData,
    required this.phaseThreeData,
    required this.threePhaseData,
  });

  factory EnergyData.fromJson(Map<String, dynamic> json) {
    return EnergyData(
      location: json['location'] ?? '',

      installationDate: parseDate(json['installationDate']),
      lastCalibration: parseDate(json['lastCalibration']),

      battery: json['battery'] ?? '',
      notification: json['notification'] ?? [],

      todayEnergyUsage: parseDouble(json['todayEnergyUsage']),
      todayOutageInSeconds: json['todayOutageInSeconds'] ?? 0,
      todayOutageInMinutes: parseDouble(json['todayOutageInMinutes']),

      totalComplains: json['totalComplains'] ?? 0,
      resolvedComplains: json['resolvedComplains'] ?? 0,
      total: json['total'] ?? 0,

      phaseOneData: (json['phaseOneData'] as List? ?? [])
          .map((e) => PhaseData.fromJson(e))
          .toList(),

      phaseTwoData: (json['phaseTwoData'] as List? ?? [])
          .map((e) => PhaseData.fromJson(e))
          .toList(),

      phaseThreeData: (json['phaseThreeData'] as List? ?? [])
          .map((e) => PhaseData.fromJson(e))
          .toList(),

      threePhaseData: (json['threePhaseData'] as List? ?? [])
          .map((e) => PhaseData.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'location': location,
      'installationDate': installationDate?.toIso8601String(),
      'lastCalibration': lastCalibration?.toIso8601String(),
      'battery': battery,
      'notification': notification,
      'todayEnergyUsage': todayEnergyUsage,
      'todayOutageInSeconds': todayOutageInSeconds,
      'todayOutageInMinutes': todayOutageInMinutes,
      'totalComplains': totalComplains,
      'resolvedComplains': resolvedComplains,
      'total': total,
      'phaseOneData': phaseOneData.map((e) => e.toJson()).toList(),
      'phaseTwoData': phaseTwoData.map((e) => e.toJson()).toList(),
      'phaseThreeData': phaseThreeData.map((e) => e.toJson()).toList(),
      'threePhaseData': threePhaseData.map((e) => e.toJson()).toList(),
    };
  }
}

class PhaseData {
  final String id;
  final double avgVoltage;
  final double avgCurrent;
  final double avgPower;
  final double avgFrequency;
  final double avgPowerFactor;
  final double avgApparentPower;
  final double? avgReactivePower;
  final double sumOfEnergyPerHour;
  final int totalCount;
  final String deviceId;
  final DateTime? date;
  final int hour;

  PhaseData({
    required this.id,
    required this.avgVoltage,
    required this.avgCurrent,
    required this.avgPower,
    required this.avgFrequency,
    required this.avgPowerFactor,
    required this.avgApparentPower,
    this.avgReactivePower,
    required this.sumOfEnergyPerHour,
    required this.totalCount,
    required this.deviceId,
    required this.date,
    required this.hour,
  });

  factory PhaseData.fromJson(Map<String, dynamic> json) {
    return PhaseData(
      id: json['_id'] ?? '',

      avgVoltage: parseDouble(json['avgVoltage']),
      avgCurrent: parseDouble(json['avgCurrent']),
      avgPower: parseDouble(json['avgPower']),
      avgFrequency: parseDouble(json['avgFrequency']),
      avgPowerFactor: parseDouble(json['avgPowerFactor']),
      avgApparentPower: parseDouble(json['avgApparentPower']),
      avgReactivePower: json['avgReactivePower'] != null
          ? parseDouble(json['avgReactivePower'])
          : null,

      sumOfEnergyPerHour: parseDouble(json['sumOfEnergyPerHour']),
      totalCount: json['totalCount'] ?? 0,
      deviceId: json['deviceId'] ?? '',

      date: parseDate(json['date']),
      hour: json['hour'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'avgVoltage': avgVoltage,
      'avgCurrent': avgCurrent,
      'avgPower': avgPower,
      'avgFrequency': avgFrequency,
      'avgPowerFactor': avgPowerFactor,
      'avgApparentPower': avgApparentPower,
      'avgReactivePower': avgReactivePower,
      'sumOfEnergyPerHour': sumOfEnergyPerHour,
      'totalCount': totalCount,
      'deviceId': deviceId,
      'date': date?.toIso8601String(),
      'hour': hour,
    };
  }
}


double parseDouble(dynamic value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}

DateTime parseDate(dynamic value) {
  return DateTime.tryParse(value?.toString() ?? '') ?? DateTime.now();
}