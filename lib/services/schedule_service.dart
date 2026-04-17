import 'dart:convert';
import 'package:dt_mobile/models/response/schedule_response.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ScheduleApiService {
  static const String baseUrl =
      'http://3.231.62.206:5000/api/v1';


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


  static Future<ScheduleResponseModel?> createSchedule({
    required Map<String, dynamic> body,
  }) async {
    try {
      final headers = await getHeaders();

      print("📤 Sending body: ${jsonEncode(body)}");

      final response = await http.post(
        Uri.parse("$baseUrl/org/schedules"),
        headers: headers,
        body: jsonEncode(body),
      );

      print("📥 Response: ${response.statusCode} - ${response.body}");


      final decoded = jsonDecode(response.body);

      if (response.statusCode == 200 ||
          response.statusCode == 201) {

        final data = decoded['data'] ?? decoded;

        return ScheduleResponseModel.fromJson(data);
      } else {
        print("Create Schedule Error: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Create Schedule Exception: $e");
      return null;
    }
  }


  static Future<List<ScheduleResponseModel>> getSchedules() async {
    try {
      final headers = await getHeaders();

      final response = await http.get(
        Uri.parse("$baseUrl/org/schedules"),
        headers: headers,
      );

      final decoded = jsonDecode(response.body);

      if (response.statusCode == 200) {

        final List data =
            decoded['data'] ?? decoded;

        return data
            .map((e) =>
            ScheduleResponseModel.fromJson(e))
            .toList();
      } else {
        print("Get Schedules Error: ${response.body}");
        return [];
      }
    } catch (e) {
      print("Get Schedules Exception: $e");
      return [];
    }
  }


  static Future<ScheduleResponseModel?> getScheduleById(
      String id) async {
    try {
      final headers = await getHeaders();

      final response = await http.get(
        Uri.parse("$baseUrl/org/schedules/$id"),
        headers: headers,
      );

      final decoded = jsonDecode(response.body);

      if (response.statusCode == 200) {

        final data = decoded['data'] ?? decoded;

        return ScheduleResponseModel.fromJson(data);
      } else {
        print("Get Schedule By ID Error: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Get Schedule By ID Exception: $e");
      return null;
    }
  }


  static Future<bool> updateSchedule({
    required String id,
    required Map<String, dynamic> body,
  }) async {
    try {
      final headers = await getHeaders();

      final response = await http.put(
        Uri.parse("$baseUrl/org/schedules/$id"),
        headers: headers,
        body: jsonEncode(body),
      );

      return response.statusCode == 200;
    } catch (e) {
      print("Update Schedule Exception: $e");
      return false;
    }
  }


  static Future<bool> deleteSchedule(String id) async {
    try {
      final headers = await getHeaders();

      final response = await http.delete(
        Uri.parse("$baseUrl/org/schedules/$id"),
        headers: headers,
      );

      return response.statusCode == 200;
    } catch (e) {
      print("Delete Schedule Exception: $e");
      return false;
    }
  }
}