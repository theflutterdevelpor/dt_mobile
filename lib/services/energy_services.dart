import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/response/energy_response.dart';

class EnergyService {
  static const String baseUrl = 'http://3.231.62.206:5000/api/v1';


  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }


  static Future<Map<String, String>> getHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }


  static Future<Map<String, dynamic>> fetchEnergy({
    required String fromDate,
    required String toDate,
  }) async {
    debugPrint(" POST HIT => $baseUrl/org/energy-meter");

    try {
      final headers = await getHeaders();

      final response = await http.post(
        Uri.parse('$baseUrl/org/energy-meter'),
        headers: headers,
        body: jsonEncode({
          "fromDate": fromDate,
          "toDate": toDate,
        }),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception('Connection timeout'),
      );

      debugPrint(" STATUS CODE: ${response.statusCode}");
      debugPrint(" RESPONSE BODY: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
          "Failed to load data: ${response.statusCode}",
        );
      }
    } catch (e) {
      debugPrint(' API ERROR: $e');
      rethrow;
    }
  }


  static Future<EnergyDetailsResponse?> getEnergyDetails({
    required String deviceId,
    String timeAgo = '7d',
  }) async {
    try {
      final Uri url = Uri.parse('$baseUrl/org/em-details/$deviceId')
          .replace(queryParameters: {'timeAgo': timeAgo});

      final headers = await getHeaders();

      debugPrint("🔥 ENERGY DETAILS REQUEST: $url");
      debugPrint("🔑 Headers: $headers");

      final response = await http
          .get(url, headers: headers)
          .timeout(const Duration(seconds: 15));

      debugPrint("📥 STATUS: ${response.statusCode}");
      debugPrint("📄 BODY: ${response.body}");

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        final data = EnergyDetailsResponse.fromJson(jsonData);

        debugPrint("✅ SUCCESS: ${data.success}");
        debugPrint("📍 LOCATION: ${data.data.location}");
        debugPrint("⚡ TODAY USAGE: ${data.data.todayEnergyUsage}");
        debugPrint("🔋 BATTERY: ${data.data.battery}");
        debugPrint("📊 PHASE 1 COUNT: ${data.data.phaseOneData.length}");

        return data;
      } else {
        throw Exception("Server Error: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("🚨 ENERGY API ERROR: $e");
      rethrow;
    }
  }


  static Future<Map<String, dynamic>> fetchEnergyHourly({
    required String date,
  }) async {
    debugPrint(" POST HIT => $baseUrl/org/energy-meter/$date");

    try {
      final headers = await getHeaders();

      final response = await http.post(
        Uri.parse('$baseUrl/org/energy-meter/$date'),
        headers: headers,
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception('Connection timeout'),
      );

      debugPrint(" STATUS CODE: ${response.statusCode}");
      debugPrint(" RESPONSE BODY: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
          "Failed to load hourly data: ${response.statusCode}",
        );
      }
    } catch (e) {
      debugPrint(' API ERROR: $e');
      rethrow;
    }
  }
}