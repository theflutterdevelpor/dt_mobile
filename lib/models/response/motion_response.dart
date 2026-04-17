import 'notification_response.dart';

class ApiResponse {
  final bool success;
  final int code;
  final Data data;

  ApiResponse({
    required this.success,
    required this.code,
    required this.data,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      success: json['success'] ?? false,
      code: json['code'] ?? 0,
      data: Data.fromJson(json['data'] ?? {}),

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

class Data {
  final String location;
  final DateTime installationDate;
  final DateTime lastCalibration;
  final String battery;
  final List<dynamic> notification;
  final List<dynamic> motionData;
  final int total;

  Data({
    required this.location,
    required this.installationDate,
    required this.lastCalibration,
    required this.battery,
    required this.notification,
    required this.motionData,
    required this.total,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      location: json['location'] ?? '',

      installationDate: json['installationDate'] != null
          ? DateTime.tryParse(json['installationDate']) ?? DateTime.now()
          : DateTime.now(),

      lastCalibration: json['lastCalibration'] != null
          ? DateTime.tryParse(json['lastCalibration']) ?? DateTime.now()
          : DateTime.now(),

      battery: json['battery'] ?? '',

      notification: json['notification'] ?? [],

      motionData: json['motionData'] ?? [],

      total: json['total'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'location': location,
      'installationDate': installationDate.toIso8601String(),
      'lastCalibration': lastCalibration.toIso8601String(),
      'battery': battery,
      'notification': notification,
      'motionData': motionData,
      'total': total,
    };
  }
}