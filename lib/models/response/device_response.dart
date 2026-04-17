class DeviceListResponse {
  final bool success;
  final int code;
  final List<DeviceModel> devices;

  DeviceListResponse({
    required this.success,
    required this.code,
    required this.devices,
  });

  factory DeviceListResponse.fromJson(Map<String, dynamic> json) {
    return DeviceListResponse(
      success: json['success'] ?? false,
      code: json['code'] ?? 0,
      devices: (json['data'] as List? ?? [])
          .map((e) => DeviceModel.fromJson(e))
          .toList(),
    );
  }
}

class DeviceModel {
  final String id;
  final String name;
  final String deviceId;
  final String status;
  final DateTime? lastSeen;
  final int offlineThreshold;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final BuildingModel? building;
  final FloorModel? floor;
  final List<SensorModel> sensors;

  DeviceModel({
    required this.id,
    required this.name,
    required this.deviceId,
    required this.status,
    required this.offlineThreshold,
    this.lastSeen,
    this.createdAt,
    this.updatedAt,
    this.building,
    this.floor,
    required this.sensors,
  });

  factory DeviceModel.fromJson(Map<String, dynamic> json) {
    return DeviceModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      deviceId: json['deviceId'] ?? '',
      status: json['status'] ?? 'offline',
      offlineThreshold: json['offlineThreshold'] ?? 0,
      lastSeen: json['lastSeen'] != null
          ? DateTime.tryParse(json['lastSeen'])
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,

      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,

      building: json['building'] != null
          ? BuildingModel.fromJson(json['building'])
          : null,
      floor: json['floor'] != null
          ? FloorModel.fromJson(json['floor'])
          : null,
      sensors: (json['sensors'] as List? ?? [])
          .map((e) => SensorModel.fromJson(e))
          .toList(),
    );

  }
}

class BuildingModel {
  final String id;
  final String name;

  BuildingModel({required this.id, required this.name});

  factory BuildingModel.fromJson(Map<String, dynamic> json) {
    return BuildingModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
    );
  }
}

class FloorModel {
  final String id;
  final String label;
  final int number;

  FloorModel({
    required this.id,
    required this.label,
    required this.number,
  });

  factory FloorModel.fromJson(Map<String, dynamic> json) {
    return FloorModel(
      id: json['_id'] ?? '',
      label: json['label'] ?? '',
      number: json['number'] ?? 0,
    );
  }
}

class SensorModel {
  final String id;
  final String name;
  final String unit;
  final num minThreshold;
  final num maxThreshold;

  SensorModel({
    required this.id,
    required this.name,
    required this.unit,
    required this.minThreshold,
    required this.maxThreshold,
  });

  factory SensorModel.fromJson(Map<String, dynamic> json) {
    return SensorModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      unit: json['unit'] ?? '',
      minThreshold: json['minThreshold'] ?? 0,
      maxThreshold: json['maxThreshold'] ?? 0,
    );
  }
}
