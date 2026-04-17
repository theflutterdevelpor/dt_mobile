import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://3.231.62.206:5000/api/v1';

  // Token get karna
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // User ID get karna
  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id');
  }

  // Headers with token
  static Future<Map<String, String>> getHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Login API
  static Future<LoginApiResponse> loginApi(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/admin/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception('Connection timeout'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true) {
          final userData = data['data'];

          // Data save karna
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_token', userData['token'] ?? '');
          await prefs.setString('user_id', userData['_id'] ?? '');
          await prefs.setString('user_name', userData['name'] ?? '');
          await prefs.setString('user_email', userData['email'] ?? '');
          await prefs.setString('user_role', userData['role']['name'] ?? '');
          await prefs.setString('organization_id', userData['organization']['_id'] ?? '');
          await prefs.setString('organization_name', userData['organization']['name'] ?? '');

          return LoginApiResponse(
            success: true,
            message: 'Login successful',
            token: userData['token'],
            userId: userData['_id'],
          );
        } else {
          return LoginApiResponse(
            success: false,
            message: data['message'] ?? 'Login failed',
          );
        }
      } else {
        return LoginApiResponse(
          success: false,
          message: 'Server error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return LoginApiResponse(
        success: false,
        message: 'Error: ${e.toString()}',
      );
    }
  }

  // Logout
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_id');
    await prefs.remove('user_name');
    await prefs.remove('user_email');
    await prefs.remove('user_role');
    await prefs.remove('organization_id');
    await prefs.remove('organization_name');
  }

  // Generic GET request
  static Future<dynamic> getRequest(String endpoint) async {
    try {
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception('Connection timeout'),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: ${e.toString()}');
    }
  }

  // Generic POST request
  static Future<dynamic> postRequest(String endpoint, Map<String, dynamic> body) async {
    try {
      final headers = await getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: jsonEncode(body),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception('Connection timeout'),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: ${e.toString()}');
    }
  }
}

// Login Response Model
class LoginApiResponse {
  final bool success;
  final String message;
  final String? token;
  final String? userId;

  LoginApiResponse({
    required this.success,
    required this.message,
    this.token,
    this.userId,
  });
}