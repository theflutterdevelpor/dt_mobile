import 'dart:convert';
import 'dart:io';
import 'package:dt_mobile/models/response/complain_response.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class MaintenanceApi {
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

  static Future<Map<String, dynamic>> createComplaint({
    required Map<String, String> fields,
    required List<File> images,
  }) async {
    final uri = Uri.parse("$baseUrl/org/complain");
    final request = http.MultipartRequest('POST', uri);


    request.fields.addAll(fields);


    for (final image in images) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          image.path,
        ),
      );
    }


    final token = await getToken();
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }


    print("POST /org/complain");
    print("FIELDS: ${request.fields}");
    print("FILES: ${request.files.length}");

    final streamedResponse = await request.send();
    final responseBody = await streamedResponse.stream.bytesToString();

    print("STATUS: ${streamedResponse.statusCode}");
    print("BODY: $responseBody");

    return jsonDecode(responseBody);
  }


  Future<List<Complaint>> getComplaints({
    required String fromDate,
    required String toDate,
  }) async {
    final uri = Uri.parse("$baseUrl/org/complain").replace(
      queryParameters: {
        "fromDate": fromDate,
        "toDate": toDate,
      },
    );

    final headers = await getHeaders();

    //  DEBUG LOGS (VERY IMPORTANT)
    print("REQUEST URL: $uri");
    print("HEADERS: $headers");

    final response = await http.get(uri, headers: headers);

    print("STATUS CODE: ${response.statusCode}");
    print("RESPONSE BODY: ${response.body}");

    final body = jsonDecode(response.body);

    if (response.statusCode == 200 && body['success'] == true) {
      final List list = body['data'] ?? [];
      return list.map((e) => Complaint.fromJson(e)).toList();
    } else {
      throw Exception(body['message'] ?? "Failed to load complaints");
    }
  }


  Future<bool> changeComplaintStatus({
    required String complaintId,
    required String status,
  }) async {
    final headers = await getHeaders();

    final uri = Uri.parse("$baseUrl/org/complain/change-status/$complaintId");

    final response = await http.post(
      uri,
      headers: headers,
      body: jsonEncode({
        "status": status,
      }),
    );

    print("CHANGE STATUS REQUEST URL: $uri");
    print("HEADERS: $headers");
    print("BODY: ${jsonEncode({"status": status})}");
    print("STATUS CODE: ${response.statusCode}");
    print("RESPONSE BODY: ${response.body}");

    return response.statusCode == 200;
  }
}
