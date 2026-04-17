class LoginResponse {
  final bool success;
  final int code;
  final LoginData? data;
  final String? message;

  LoginResponse({
    required this.success,
    required this.code,
    this.data,
    this.message,
  });


  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      success: json['success'] ?? false,
      code: json['code'] ?? 0,
      data: json['data'] != null ? LoginData.fromJson(json['data']) : null,
      message: json['message'],
    );
  }
}

class LoginData {
  final String token;
  final String userId;
  final String name;
  final String email;
  final String role;
  final String organizationId;
  final String organizationName;

  LoginData({
    required this.token,
    required this.userId,
    required this.name,
    required this.email,
    required this.role,
    required this.organizationId,
    required this.organizationName,
  });


  factory LoginData.fromJson(Map<String, dynamic> json) {
    return LoginData(
      token: json['token'] ?? '',
      userId: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role']['name'] ?? 'User',
      organizationId: json['organization']['_id'] ?? '',
      organizationName: json['organization']['name'] ?? '',
    );
  }
}