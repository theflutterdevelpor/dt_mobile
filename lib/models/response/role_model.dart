class Role {
  final String id;
  final String name;
  final String? description;
  final List<String> permissionKeys;
  final List<String> permissions;
  final String? organizationId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Role({
    required this.id,
    required this.name,
    this.description,
    required this.permissionKeys,
    required this.permissions,
    this.organizationId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      permissionKeys: List<String>.from(json['permissionKeys'] ?? []),
      permissions: List<String>.from(json['permissions'] ?? []),
      organizationId: json['organizationId'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'description': description,
      'permissionKeys': permissionKeys,
      'permissions': permissions,
      'organizationId': organizationId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class RoleResponse {
  final bool success;
  final int code;
  final int total;
  final List<Role> data;

  RoleResponse({
    required this.success,
    required this.code,
    required this.total,
    required this.data,
  });

  factory RoleResponse.fromJson(Map<String, dynamic> json) {
    return RoleResponse(
      success: json['success'] ?? false,
      code: json['code'] ?? 0,
      total: json['total'] ?? 0,
      data: (json['data'] as List<dynamic>?)
          ?.map((item) => Role.fromJson(item as Map<String, dynamic>))
          .toList() ??
          [],
    );
  }
}