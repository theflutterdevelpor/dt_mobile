// // .dart
// class GasSensorData {
//   final bool success;
//   final int code;
//   final GasSensor? data;
//
//   GasSensorData({
//     required this.success,
//     required this.code,
//     this.data,
//   });
//
//   factory GasSensorData.fromJson(Map<String, dynamic> json) {
//     return GasSensorData(
//       success: json['success'] ?? false,
//       code: json['code'] ?? 0,
//       data: json['data'] != null ? GasSensor.fromJson(json['data']) : null,
//     );
//   }
// }
//
// class GasSensor {
//   final String id;
//   final String gatewayId;
//   final String nodeId;
//   final DateTime? readingTime;
//   final double co2;
//   final double co;
//   final String type;
//   final DateTime? createdAt;
//   final DateTime? updatedAt;
//   final String? location;
//   final String? battery;
//   final DateTime? installationDate;
//   final DateTime? lastCalibration;
//
//   GasSensor({
//     required this.id,
//     required this.gatewayId,
//     required this.nodeId,
//     required this.readingTime,
//     required this.co2,
//     required this.co,
//     required this.type,
//     required this.createdAt,
//     required this.updatedAt,
//     this.location,
//     this.battery,
//     this.installationDate,
//     this.lastCalibration,
//   });
//
//   factory GasSensor.fromJson(Map<String, dynamic> json) {
//     return GasSensor(
//       id: json['_id'],
//       gatewayId: json['gatewayId'],
//       nodeId: json['nodeId'],
//       readingTime: json['readingTime'] != null
//           ? DateTime.parse(json['readingTime'])
//           : null,
//       co2: (json['co2'] ?? 0).toDouble(),
//       co: (json['co'] ?? 0).toDouble(),
//       type: json['type'] ?? 'MQ7',
//       createdAt: DateTime.parse(json['createdAt']),
//       updatedAt: DateTime.parse(json['updatedAt']),
//       location: json['location'],
//       battery: json['battery'],
//       installationDate: json['installationDate'] != null
//           ? DateTime.parse(json['installationDate'])
//           : null,
//       lastCalibration: json['lastCalibration'] != null
//           ? DateTime.parse(json['lastCalibration'])
//           : null,
//     );
//   }
// }