class UserResponse {
  final bool success;
  final int code;
  final int total;
  final UserData? data;

  UserResponse({
    required this.success,
    required this.code,
    required this.total,
    required this.data,
  });

  factory UserResponse.fromJson(Map<String, dynamic> json) {
    return UserResponse(
      success: json['success'] ?? false,
      code: json['code'] ?? 0,
      total: json['total'] ?? 0,
      data: json['data'] != null ? UserData.fromJson(json['data']) : null,
    );
  }
}

class RoleModel {
  final String id;
  final String? name;

  RoleModel({
    required this.id,
    this.name,
  });

  factory RoleModel.fromJson(dynamic json) {

    if (json == null) {
      return RoleModel(id: '');
    }


    if (json is String) {
      return RoleModel(id: json);
    }


    if (json is Map<String, dynamic>) {
      return RoleModel(
        id: json['_id'] ?? '',
        name: json['name'],
      );
    }


    return RoleModel(id: '');
  }
}


class Organization {
  final String id;
  final String? name;

  Organization({
    required this.id,
    this.name,
  });


  factory Organization.fromJson(dynamic json) {

    if (json is String) {
      return Organization(id: json);
    }


    return Organization(
      id: json['_id'] ?? '',
      name: json['name'],
    );
  }
}

class UserData {
  final String id;
  final String name;
  final String email;
  // final String password;
  final bool isActive;
  final bool isVerified;
  final RoleModel role;
  final String createdAt;
  final String updatedAt;
  final ImageData? image;
  final String? resetToken;
  final Organization? organization;
  final List<String> permissions;
  final List<String> buildingsAllow;

  UserData({
    required this.id,
    required this.name,
    required this.email,
    // required this.password,
    required this.isActive,
    required this.isVerified,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
    this.image,
    this.resetToken,
    this.organization,
    required this.permissions,
    required this.buildingsAllow,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    print("🧩 Parsing user: ${json['name']}");
    return UserData(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      // password: json['password'] ?? '',
      isActive: json['isActive'] ?? false,
      isVerified: json['isVerified'] ?? false,
      role: RoleModel.fromJson(json['role']),
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      image: json['image'] != null ? ImageData.fromJson(json['image']) : null,
      resetToken: json['resetToken'] != null
          ? (json['resetToken'] is Map ? json['resetToken']['token'] : json['resetToken'])
          : null,
      organization: json['organization'] != null
          ? Organization.fromJson(json['organization'])
          : null,
      permissions: (json['permissions'] as List? ?? []).map((e) => e.toString()).toList(),
      buildingsAllow: List<String>.from(json['buildingsAllow'] ?? []),
    );
  }
}

class ImageData {
  final String? originalName;
  final String? key;
  final String? url;
  final String? expiry;

  ImageData({
    this.originalName,
    this.key,
    this.url,
    this.expiry,
  });

  factory ImageData.fromJson(Map<String, dynamic> json) {
    return ImageData(
      originalName: json['originalName'],
      key: json['key'],
      url: json['url'],
      expiry: json['expiry'],
    );
  }
}