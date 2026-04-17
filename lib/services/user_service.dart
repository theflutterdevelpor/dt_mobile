import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dt_mobile/models/response/user_response.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserApiService {
  static const String baseUrl = 'http://3.231.62.206:5000/api/v1';



  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    debugPrint(' TOKEN: $token');
    return token;
  }

  static Future<String?> _getOrganizationId() async {
    final prefs = await SharedPreferences.getInstance();
    final orgId = prefs.getString('organization_id');
    debugPrint('ORG ID: $orgId');
    return orgId;
  }

  static Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    debugPrint(' HEADERS: $headers');
    return headers;
  }



  static Future<List<UserData>> getUsers() async {
    try {
      debugPrint('️ GET USERS: $baseUrl/org/users');

      final headers = await _getHeaders();

      final response = await http
          .get(Uri.parse('$baseUrl/org/users'), headers: headers)
          .timeout(const Duration(seconds: 30));

      debugPrint(' STATUS: ${response.statusCode}');
      debugPrint(' BODY: ${response.body}');

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final list = decoded['data'] as List? ?? [];

        debugPrint(' USERS COUNT: ${list.length}');


        return list.map((e) => UserData.fromJson(e)).toList();
      }

      if (response.statusCode == 401) {
        debugPrint(' Unauthorized');
        throw Exception('Session expired');
      }

      debugPrint(' Failed with status: ${response.statusCode}');
      throw Exception('Failed loading users');

    } catch (e, stack) {
      debugPrint(' GET USERS ERROR: $e');
      debugPrint(' STACK: $stack');
      rethrow;
    }
  }





  static Future<UserData> createUserWithImage({
    required String name,
    required String email,
    required String password,
    String? roleId,
    List<String>? permissions,
    String? organizationId,
    File? imageFile,
    List<String>? buildingsAllow,
  }) async {
    try {
      debugPrint('CREATE USER WITH IMAGE API');

      final token = await _getToken();
      final orgId = organizationId ?? await _getOrganizationId();

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/org/users'),
      );

      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      if (orgId != null) {
        request.headers['orgId'] = orgId;
      }

      request.fields['name'] = name;
      request.fields['email'] = email;
      request.fields['password'] = password;

      if (roleId != null && roleId.isNotEmpty) {
        request.fields['role'] = roleId;
      }


      if (buildingsAllow != null && buildingsAllow.isNotEmpty) {
        request.fields['buildingsAllow'] = json.encode(buildingsAllow);
        debugPrint(' BUILDINGS: ${json.encode(buildingsAllow)}');
      }


      if (imageFile != null && await imageFile.exists()) {
        final multipartFile = await http.MultipartFile.fromPath(
          'file',
          imageFile.path,
        );
        request.files.add(multipartFile);
        debugPrint(' IMAGE ATTACHED: ${imageFile.path}');
      } else {
        debugPrint('⚠ NO IMAGE SELECTED');
      }

      debugPrint(' HEADERS: ${request.headers}');
      debugPrint(' FIELDS: ${request.fields}');
      debugPrint(' FILES: ${request.files.length}');

      debugPrint(' SENDING REQUEST...');
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint(' RESPONSE STATUS: ${response.statusCode}');
      debugPrint(' RESPONSE BODY: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = json.decode(response.body);
        if (decoded['data'] != null) {
          debugPrint(' USER CREATED!');
          return UserData.fromJson(decoded['data']);
        }
      }

      debugPrint(' CREATE FAILED: ${response.statusCode}');
      throw Exception('Create failed: ${response.body}');

    } catch (e, stack) {
      debugPrint(' CREATE ERROR: $e');
      debugPrint(' STACK: $stack');
      rethrow;
    }
  }


  // ================= UPDATE USER =================

  static Future<UserData> updateUser({
    required String userId,
    required String name,
    required String email,
    String? roleId,
    List<String>? permissions,
    String? organizationId,
    File? imageFile,
    List<String>? buildingsAllow,
    bool? isActive
  }) async {
    try {
      debugPrint(' UPDATE USER: $userId');

      final token = await _getToken();
      final orgId = organizationId ?? await _getOrganizationId();

      var request = http.MultipartRequest(
        'PUT',
        Uri.parse('$baseUrl/org/users/$userId'),
      );

      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      if (orgId != null) {
        request.headers['orgId'] = orgId;
      }

      request.fields['name'] = name;
      request.fields['email'] = email;


      if (roleId != null && roleId.isNotEmpty) {
        request.fields['role'] = roleId;
      }
      if (isActive != null) {
        request.fields['isActive'] = isActive.toString();
      }

      if (buildingsAllow != null && buildingsAllow.isNotEmpty) {
        request.fields['buildingsAllow'] = json.encode(buildingsAllow);
        debugPrint(' BUILDINGS: ${json.encode(buildingsAllow)}');
      }

      if (imageFile != null && await imageFile.exists()) {
        final multipartFile = await http.MultipartFile.fromPath(
          'file',
          imageFile.path,
        );
        request.files.add(multipartFile);
        debugPrint(' IMAGE ATTACHED: ${imageFile.path}');
      } else {
        debugPrint('⚠️ NO IMAGE SELECTED');
      }

      debugPrint('📋 HEADERS: ${request.headers}');
      debugPrint('📋 FIELDS: ${request.fields}');
      debugPrint('📋 FILES: ${request.files.length}');

      debugPrint('📤 SENDING REQUEST...');
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('📡 RESPONSE STATUS: ${response.statusCode}');
      debugPrint('📦 RESPONSE BODY: ${response.body}');

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded['data'] != null) {
          debugPrint('✅ USER UPDATED!');
          return UserData.fromJson(decoded['data']);
        }
      }

      debugPrint('❌ UPDATE FAILED: ${response.statusCode}');
      throw Exception('Update failed: ${response.body}');

    } catch (e, stack) {
      debugPrint('🔥 UPDATE ERROR: $e');
      debugPrint('📍 STACK: $stack');
      rethrow;
    }
  }


  // ================= DELETE USER =================

  static Future<bool> deleteUser({
    required String userId,
  }) async {
    try {
      debugPrint('🗑️ DELETE USER: $userId');

      final token = await _getToken();
      final orgId = await _getOrganizationId();

      final headers = {
        if (token != null) 'Authorization': 'Bearer $token',
        if (orgId != null) 'orgId': orgId,
      };

      debugPrint('📋 HEADERS: $headers');

      final response = await http.Client().send(
        http.Request(
          'DELETE',
          Uri.parse('$baseUrl/org/users/$userId'),
        )
          ..headers.addAll(headers),
      );

      final httpResponse = await http.Response.fromStream(response);

      debugPrint('📡 RESPONSE STATUS: ${httpResponse.statusCode}');
      debugPrint('📦 RESPONSE BODY: ${httpResponse.body}');

      if (httpResponse.statusCode == 200) {
        final decoded = json.decode(httpResponse.body);
        if (decoded['success'] == true) {
          debugPrint('✅ USER DELETED!');
          return true;
        }
      }

      debugPrint('❌ DELETE FAILED: ${httpResponse.statusCode}');
      throw Exception('Delete failed: ${httpResponse.body}');

    } catch (e, stack) {
      debugPrint('🔥 DELETE ERROR: $e');
      debugPrint('📍 STACK: $stack');
      rethrow;
    }
  }
}
