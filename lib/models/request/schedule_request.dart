import 'package:dt_mobile/models/response/schedule_response.dart';

class CreateScheduleRequest {
  final String name;
  final DateTime expireAt;
  final String timezone;
  final Map<String, List<TimeSlot>> schedule;

  CreateScheduleRequest({
    required this.name,
    required this.expireAt,
    required this.timezone,
    required this.schedule,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> scheduleMap = {};

    schedule.forEach((day, slots) {
      scheduleMap[day] =
          slots.map((slot) => slot.toJson()).toList();
    });

    return {
      "name": name,
      "expireAt": expireAt.toIso8601String(),
      "timezone": timezone,
      "schedule": scheduleMap,
    };
  }
}