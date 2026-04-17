import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/response/notification_response.dart';

class NotificationApi {

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


  static Future<NotificationResponse> getMyNotifications() async {
    final uri = Uri.parse("$baseUrl/org/get-my-notifications");
    final headers = await getHeaders();

    print("GET NOTIFICATIONS URL: $uri");
    print("HEADERS: $headers");

    final response = await http.get(uri, headers: headers);

    print("STATUS CODE: ${response.statusCode}");
    print("BODY: ${response.body}");

    final body = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return NotificationResponse.fromJson(body);
    } else {
      throw Exception(body['message'] ?? "Failed to load notifications");
    }
  }


  static Future<bool> markAsRead({
    required String notificationId,
  }) async {
    final uri = Uri.parse("$baseUrl/org/read-notification/$notificationId");
    final headers = await getHeaders();

    print("PUT READ NOTIFICATION URL: $uri");
    print("HEADERS: $headers");

    final response = await http.put(uri, headers: headers);

    print("STATUS CODE: ${response.statusCode}");
    print("BODY: ${response.body}");

    return response.statusCode == 200;
  }


  static Future<bool> markManyAsRead({
    required List<String> ids,
  }) async {
    final uri = Uri.parse("$baseUrl/org/read-many-notification");
    final headers = await getHeaders();

    print("POST READ MANY URL: $uri");
    print("HEADERS: $headers");
    print("BODY: ${jsonEncode({'ids': ids})}");

    final response = await http.post(
      uri,
      headers: headers,
      body: jsonEncode({'ids': ids}),
    );

    print("STATUS CODE: ${response.statusCode}");
    print("BODY: ${response.body}");

    return response.statusCode == 200;
  }

  static Future<int> getUnreadCount() async {
    try {
      final response = await getMyNotifications();
      int unreadCount = response.data.where((n) => !n.read).length;
      return unreadCount;
    } catch (e) {
      return 0;
    }
  }
}