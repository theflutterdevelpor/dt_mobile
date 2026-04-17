import 'dart:convert';


class PermissionModel {
  final String id;
  final String key;
  final String label;
  final String description;
  final String category;
  final DateTime createdAt;
  final DateTime updatedAt;

  PermissionModel({
    required this.id,
    required this.key,
    required this.label,
    required this.description,
    required this.category,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PermissionModel.fromJson(Map<String, dynamic> json) {
    return PermissionModel(
      id: json['_id'] ?? '',
      key: json['key'] ?? '',
      label: json['label'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'key': key,
    'label': label,
    'description': description,
    'category': category,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };
}


class RoleModel {
  final String id;
  final String name;
  final String description;
  final List<String> permissionKeys;
  final List<PermissionModel> permissions;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int v;

  RoleModel({
    required this.id,
    required this.name,
    required this.description,
    required this.permissionKeys,
    required this.permissions,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  factory RoleModel.fromJson(Map<String, dynamic> json) {
    return RoleModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      permissionKeys: List<String>.from(json['permissionKeys'] ?? []),
      permissions: (json['permissions'] as List? ?? [])
          .map((e) => PermissionModel.fromJson(e))
          .toList(),
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
      v: json['__v'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'name': name,
    'description': description,
    'permissionKeys': permissionKeys,
    'permissions': permissions.map((e) => e.toJson()).toList(),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    '__v': v,
  };
}


class ResetTokenModel {
  final String token;
  final DateTime expiresAt;

  ResetTokenModel({
    required this.token,
    required this.expiresAt,
  });

  factory ResetTokenModel.fromJson(Map<String, dynamic> json) {
    return ResetTokenModel(
      token: json['token'] ?? '',
      expiresAt:
      DateTime.tryParse(json['expiresAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'token': token,
    'expiresAt': expiresAt.toIso8601String(),
  };
}


class ImageModel {
  final String originalName;
  final String key;
  final String url;
  final DateTime expiry;

  ImageModel({
    required this.originalName,
    required this.key,
    required this.url,
    required this.expiry,
  });

  factory ImageModel.fromJson(Map<String, dynamic> json) {
    return ImageModel(
      originalName: json['originalName'] ?? '',
      key: json['key'] ?? '',
      url: json['url'] ?? '',
      expiry: DateTime.tryParse(json['expiry'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'originalName': originalName,
    'key': key,
    'url': url,
    'expiry': expiry.toIso8601String(),
  };
}


class ProfileModel {
  final String id;
  final String name;
  final String email;
  final bool isVerified;
  final bool isActive;
  final RoleModel? role;
  final ResetTokenModel? resetToken;
  final ImageModel? image;
  final List<String> permissions;
  final List<String> buildingsAllow;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int v;
  final String organization;

  ProfileModel({
    required this.id,
    required this.name,
    required this.email,
    required this.isVerified,
    required this.isActive,
    this.role,
    this.resetToken,
    this.image,
    required this.permissions,
    required this.buildingsAllow,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
    required this.organization,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      isVerified: json['isVerified'] ?? false,
      isActive: json['isActive'] ?? false,
      role: json['role'] != null ? RoleModel.fromJson(json['role']) : null,
      resetToken: json['resetToken'] != null
          ? ResetTokenModel.fromJson(json['resetToken'])
          : null,
      image: json['image'] != null ? ImageModel.fromJson(json['image']) : null,
      permissions: List<String>.from(json['permissions'] ?? []),
      buildingsAllow: List<String>.from(json['buildingsAllow'] ?? []),
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
      v: json['__v'] ?? 0,
      organization: json['organization'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'name': name,
    'email': email,
    'isVerified': isVerified,
    'isActive': isActive,
    'role': role?.toJson(),
    'resetToken': resetToken?.toJson(),
    'image': image?.toJson(),
    'permissions': permissions,
    'buildingsAllow': buildingsAllow,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    '__v': v,
    'organization': organization,
  };


  String get imageUrl => image?.url ?? '';

  bool hasPermission(String key) {
    return role?.permissionKeys.contains(key) ?? false;
  }

  factory ProfileModel.empty() {
    return ProfileModel(
      id: '',
      name: '',
      email: '',
      isVerified: false,
      isActive: false,
      role: null,
      resetToken: null,
      image: null,
      permissions: [],
      buildingsAllow: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      v: 0,
      organization: '',
    );
  }
}


class ProfileResponse {
  final bool success;
  final int code;
  final ProfileModel data;

  ProfileResponse({
    required this.success,
    required this.code,
    required this.data,
  });

  factory ProfileResponse.fromJson(Map<String, dynamic> json) {
    return ProfileResponse(
      success: json['success'] ?? false,
      code: json['code'] ?? 0,
      data: json['data'] != null
          ? ProfileModel.fromJson(json['data'])
          : ProfileModel.empty(),
    );
  }

  Map<String, dynamic> toJson() => {
    'success': success,
    'code': code,
    'data': data.toJson(),
  };
}