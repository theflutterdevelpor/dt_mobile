import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/response/motion_response.dart';

class MotionSensorService {
  static const String baseUrl = "http://3.231.62.206:5000/api/v1";

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<Map<String, String>> getHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<ApiResponse?> getMotionSensorDetails({
    required String deviceId,
    String timeAgo = '1d',
    bool details = true,
  }) async {
    final uri = Uri.parse("$baseUrl/org/motion-sensor/$deviceId").replace(
      queryParameters: {
        'details': '$details',
        'timeAgo': timeAgo,
      },
    );

    final headers = await getHeaders();

    try {
      final response = await http
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 15));

      // Debug logs
      print("URL: $uri");
      print("STATUS: ${response.statusCode}");
      print("BODY: ${response.body}");

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;

        if (body['success'] == true) {
          return ApiResponse.fromJson(body);
        } else {
          throw Exception(body['message'] ?? "Unknown API error");
        }
      } else if (response.statusCode == 401) {
        throw Exception("Unauthorized - Token expired");
      } else {
        throw Exception(
          "Request failed | Status: ${response.statusCode}",
        );
      }
    } catch (e) {
      throw Exception("Exception: $e");
    }
  }
}