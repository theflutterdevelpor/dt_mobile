import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dt_mobile/models/response/tempreture_response.dart';

class TemperatureService {
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


  static Future<TemperatureLatestResponse?> getLatest({
    required String nodeId,
    required String timeAgo,
  }) async {
    final uri = Uri.parse(
      "$baseUrl/org/temperature-sensor/$nodeId",
    ).replace(
      queryParameters: {
        'details': 'true',
        'timeAgo': timeAgo,
      },
    );

    final headers = await getHeaders();

    print("🌡️ TEMP REQUEST URL: $uri");
    print("📋 TEMP HEADERS: $headers");

    try {
      final response = await http
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 15));

      print("📥 TEMP STATUS CODE: ${response.statusCode}");
      print("📄 TEMP RESPONSE BODY: ${response.body}");

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        if (body['success'] == true) {
          return TemperatureLatestResponse.fromJson(body);
        } else {
          print("⚠️ TEMP API returned success: false");
        }
      } else if (response.statusCode == 401) {
        print("🔒 TEMP UNAUTHORIZED — token expired or missing");
      } else if (response.statusCode == 404) {
        print("❌ TEMP NOT FOUND — nodeId '$nodeId' does not exist");
      } else {
        print("❗ TEMP ERROR ${response.statusCode}: ${response.body}");
      }
    } catch (e) {
      print("🚨 TEMP EXCEPTION: $e");
    }

    return null;
  }




  // static Future<TemperatureLatestResponse?> fetchLatest() async {
  //   final uri = Uri.parse(
  //     "$baseUrl/org/temperature-sensor/DHT22-N_0001",
  //   ).replace(
  //     queryParameters: {
  //       'details': 'true',
  //       'timeAgo': '1d',
  //     },
  //   );
  //
  //   final headers = await getHeaders();
  //
  //   print("🌡️ TEMP REQUEST URL: $uri");
  //   print("📋 TEMP HEADERS: $headers");
  //
  //   try {
  //     final response = await http.get(uri, headers: headers);
  //
  //     print("📥 TEMP STATUS CODE: ${response.statusCode}");
  //     print("📄 TEMP RESPONSE BODY: ${response.body}");
  //
  //     if (response.statusCode == 200) {
  //       final body = jsonDecode(response.body) as Map<String, dynamic>;
  //       if (body['success'] == true) {
  //         return TemperatureLatestResponse.fromJson(body);
  //       } else {
  //         print("⚠️ TEMP API returned success: false");
  //       }
  //     } else if (response.statusCode == 401) {
  //       print("🔒 TEMP UNAUTHORIZED — token expired or missing");
  //     } else if (response.statusCode == 404) {
  //       print("❌ TEMP NOT FOUND — check nodeId");
  //     } else {
  //       print("❗ TEMP ERROR ${response.statusCode}: ${response.body}");
  //     }
  //   } catch (e) {
  //     print("🚨 TEMP EXCEPTION: $e");
  //   }
  //
  //   return null;
  // }


  static Future<TemperatureHistoryResponse?> getHistory({
    required String deviceId,
    required DateTime fromDate,
    required DateTime toDate,
  }) async {
    String fmt(DateTime d) =>
        "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";

    final uri = Uri.parse(
      "$baseUrl/org/temperature-sensor",
    ).replace(
      queryParameters: {
        'deviceId': deviceId,
        'fromDate': fmt(fromDate),
        'toDate': fmt(toDate),
      },
    );

    final headers = await getHeaders();

    print("📡 TEMP HISTORY REQUEST: $uri");

    final response = await http.get(uri, headers: headers);

    print("📥 TEMP HISTORY STATUS: ${response.statusCode}");
    print("📄 TEMP HISTORY BODY: ${response.body}");

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      if (body['success'] == true) {
        return TemperatureHistoryResponse.fromJson(body);
      }
    }
    return null;
  }
}

