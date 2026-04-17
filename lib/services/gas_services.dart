import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dt_mobile/models/response/gas_response.dart';

import '../models/response/gas_model.dart';

class GasService {
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


  static Future<GasHistoryResponse?> getHistory({
    required String deviceId,
    required String fromDate,
    required String toDate,
  }) async {
    final uri = Uri.parse("$baseUrl/org/gas-sensor").replace(
      queryParameters: {
        'deviceId': deviceId,
        'fromDate': fromDate,
        'toDate': toDate,
      },
    );

    final headers = await getHeaders();

    print("📡 GAS HISTORY REQUEST: $uri");

    final response = await http.get(uri, headers: headers);

    print("📥 GAS HISTORY STATUS: ${response.statusCode}");
    print("📄 GAS HISTORY BODY: ${response.body}");

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      if (body['success'] == true) {
        return GasHistoryResponse.fromJson(body);
      }
    }
    return null;
  }


  static Future<GasLatestResponse?> getSensorByNodeId({
    required String nodeId,
    bool details = true,
    String? timeAgo,
  }) async {
    final queryParams = <String, String>{
      'details': details.toString(),
      if (timeAgo != null) 'timeAgo': timeAgo,
    };

    // Correct Endpoint according to your screenshot
    final uri = Uri.parse("$baseUrl/org/gas-sensor/$nodeId")
        .replace(queryParameters: queryParams);

    final headers = await getHeaders();

    print("📡 GET SENSOR BY NODE ID REQUEST: $uri");

    try {
      final response = await http.get(uri, headers: headers);

      print("📥 STATUS: ${response.statusCode}");

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['success'] == true) {
          return GasLatestResponse.fromJson(body);
        }
      } else {
        print("❌ ERROR BODY: ${response.body}");
      }
    } catch (e) {
      print("🚨 EXCEPTION: $e");
    }
    return null;
  }

  static Future<GasLatestResponse?> getLatest({
    required String deviceId,
  }) async {
    final uri = Uri.parse("$baseUrl/org/gas-sensor/$deviceId").replace(
      queryParameters: {
        'details': 'true',
        'timeAgo': '12h',
      },
    );

    final headers = await getHeaders();

    print("📡 GAS LATEST REQUEST: $uri");

    final response = await http.get(uri, headers: headers);

    print("📥 GAS LATEST STATUS: ${response.statusCode}");

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      if (body['success'] == true) {
        return GasLatestResponse.fromJson(body);
      }
    }
    return null;
  }
}