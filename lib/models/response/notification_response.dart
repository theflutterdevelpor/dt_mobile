class NotificationModel {
  final String id;
  final String userId;
  final String referenceId;
  final String type;
  final String title;
  final String message;
  final bool read;
  final String createdAt;
  final String updatedAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.referenceId,
    required this.type,
    required this.title,
    required this.message,
    required this.read,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['_id'] ?? '',
      userId: json['userId'] ?? '',
      referenceId: json['referenceId'] ?? '',
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      read: json['read'] ?? false,
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'referenceId': referenceId,
      'type': type,
      'title': title,
      'message': message,
      'read': read,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  // Copy with updated read status (local state update ke liye)
  NotificationModel copyWith({bool? read}) {
    return NotificationModel(
      id: id,
      userId: userId,
      referenceId: referenceId,
      type: type,
      title: title,
      message: message,
      read: read ?? this.read,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

class NotificationResponse {
  final bool success;
  final int code;
  final int total;
  final List<NotificationModel> data;

  NotificationResponse({
    required this.success,
    required this.code,
    required this.total,
    required this.data,
  });

  factory NotificationResponse.fromJson(Map<String, dynamic> json) {
    return NotificationResponse(
      success: json['success'] ?? false,
      code: json['code'] ?? 0,
      total: json['total'] ?? 0,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => NotificationModel.fromJson(e))
          .toList() ??
          [],
    );
  }
}