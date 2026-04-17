class Permission {
  final String id;
  final String key;
  final String label;
  final String description;
  final String category;
  final DateTime createdAt;
  final DateTime updatedAt;

  Permission({
    required this.id,
    required this.key,
    required this.label,
    required this.description,
    required this.category,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Permission.fromJson(Map<String, dynamic> json) {
    return Permission(
      id: json['_id'] ?? '',
      key: json['key'] ?? '',
      label: json['label'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'key': key,
      'label': label,
      'description': description,
      'category': category,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class PermissionResponse {
  final bool success;
  final int code;
  final int total;
  final List<Permission> data;

  PermissionResponse({
    required this.success,
    required this.code,
    required this.total,
    required this.data,
  });

  factory PermissionResponse.fromJson(Map<String, dynamic> json) {
    return PermissionResponse(
      success: json['success'] ?? false,
      code: json['code'] ?? 0,
      total: json['total'] ?? 0,
      data: (json['data'] as List<dynamic>?)
          ?.map((item) => Permission.fromJson(item as Map<String, dynamic>))
          .toList() ??
          [],
    );
  }
}