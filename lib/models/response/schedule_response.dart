class ScheduleResponseModel {
  final String id;
  final String name;
  final DateTime expireAt;
  final Map<String, List<TimeSlot>> schedule;
  final String timezone;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int v;

  ScheduleResponseModel({
    required this.id,
    required this.name,
    required this.expireAt,
    required this.schedule,
    required this.timezone,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  factory ScheduleResponseModel.fromJson(Map<String, dynamic> json) {
    Map<String, List<TimeSlot>> parsedSchedule = {};

    if (json['schedule'] != null) {
      json['schedule'].forEach((day, slots) {
        parsedSchedule[day] = List<TimeSlot>.from(
          slots.map((slot) => TimeSlot.fromJson(slot)),
        );
      });
    }

    return ScheduleResponseModel(
      id: json['_id'] ?? "",
      name: json['name'] ?? "",
      expireAt: json['expireAt'] != null
          ? DateTime.parse(json['expireAt'])
          : DateTime.now(),
      schedule: parsedSchedule,
      timezone: json['timezone'] ?? "",
      isActive: json['isActive'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
      v: json['__v'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> scheduleMap = {};

    schedule.forEach((day, slots) {
      scheduleMap[day] = slots.map((slot) => slot.toJson()).toList();
    });

    return {
      "_id": id,
      "name": name,
      "expireAt": expireAt.toIso8601String(),
      "schedule": scheduleMap,
      "timezone": timezone,
      "isActive": isActive,
      "createdAt": createdAt.toIso8601String(),
      "updatedAt": updatedAt.toIso8601String(),
      "__v": v,
    };
  }
}

class TimeSlot {
  final String startTime;
  final String endTime;

  TimeSlot({
    required this.startTime,
    required this.endTime,
  });

  factory TimeSlot.fromJson(Map<String, dynamic> json) {
    return TimeSlot(
      startTime: json['startTime'] ?? "",
      endTime: json['endTime'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "startTime": startTime,
      "endTime": endTime,
    };
  }
}