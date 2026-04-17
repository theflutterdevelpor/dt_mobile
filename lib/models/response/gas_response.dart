
class GasHistoryResponse {
  final bool? success;
  final int? code;
  final List<GasReading>? data;

  GasHistoryResponse({this.success, this.code, this.data});

  factory GasHistoryResponse.fromJson(Map<String, dynamic> json) {
    return GasHistoryResponse(
      success: json['success'],
      code: json['code'],
      data: json['data'] != null
          ? (json['data'] as List)
          .map((e) => GasReading.fromJson(e as Map<String, dynamic>))
          .toList()
          : [],
    );
  }
}

class GasReading {
  final String? id;
  final String? gatewayId;
  final String? nodeId;
  final DateTime? readingTime;
  final double? co2;
  final double? co;
  final String? type;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? location;
  final String? battery;
  final DateTime? installationDate;
  final DateTime? lastCalibration;


  GasReading({
    this.id,
    this.gatewayId,
    this.nodeId,
    this.readingTime,
    this.co2,
    this.co,
    this.type,
    this.createdAt,
    this.updatedAt,
    this.location,
    this.battery,
    this.installationDate,
    this.lastCalibration,
  });

  factory GasReading.fromJson(Map<String, dynamic> json) {
    return GasReading(
      id: json['_id'],
      gatewayId: json['gatewayId'],
      nodeId: json['nodeId'],
      readingTime: json['readingTime'] != null
          ? DateTime.tryParse(json['readingTime'])
          : null,
      co2: json['co2'] != null
          ? (json['co2'] is num ? (json['co2'] as num).toDouble() : double.tryParse(json['co2'].toString()))
          : null,
      co: json['co'] != null
          ? (json['co'] is num ? (json['co'] as num).toDouble() : double.tryParse(json['co'].toString()))
          : null,
      type: json['type'],
      createdAt: json['createdAt'] != null
      ? DateTime.parse(json['createdAt'])
      : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
      location: json['location'],
      battery: json['battery'],
      installationDate: json['installationDate'] != null
          ? DateTime.tryParse(json['installationDate'])
          : null,
      lastCalibration: json['lastCalibration'] != null
          ? DateTime.tryParse(json['lastCalibration'])
          : null,

    );
  }
}

class GasLatestResponse {
  final bool? success;
  final int? code;
  final GasReading? data;

  GasLatestResponse({this.success, this.code, this.data});

  factory GasLatestResponse.fromJson(Map<String, dynamic> json) {
    return GasLatestResponse(
      success: json['success'],
      code: json['code'],
      data: json['data'] != null
          ? GasReading.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}