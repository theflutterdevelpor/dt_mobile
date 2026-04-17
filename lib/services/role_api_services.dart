import 'dart:convert';
import 'package:dt_mobile/models/response/permission_model.dart';
import 'package:dt_mobile/models/response/role_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';


class RoleApiService {
  static const String baseUrl = 'http://3.231.62.206:5000/api/v1';


  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }


  static Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }


  static Future<RoleResponse> getRoles() async {
    try {
      final headers = await _getHeaders();

      final response = await http.get(
        Uri.parse('$baseUrl/roles'),
        headers: headers,
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception('Connection timeout'),
      );

      debugPrint('Roles API Status Code: ${response.statusCode}');
      debugPrint('Roles API Response: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return RoleResponse.fromJson(jsonData);
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Please login again');
      } else {
        throw Exception('Failed to load roles: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching roles: $e');
      throw Exception('Error fetching roles: $e');
    }
  }


  static Future<PermissionResponse> getPermissions() async {
    try {
      final headers = await _getHeaders();

      final response = await http.get(
        Uri.parse('$baseUrl/permissions'),
        headers: headers,
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception('Connection timeout'),
      );

      debugPrint('Permissions API Status Code: ${response.statusCode}');
      debugPrint('Permissions API Response: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return PermissionResponse.fromJson(jsonData);
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Please login again');
      } else {
        throw Exception('Failed to load permissions: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching permissions: $e');
      throw Exception('Error fetching permissions: $e');
    }
  }


  static Future<Map<String, dynamic>> createRole({
    required String name,
    required List<String> permissionIds,
    required List<String> permissionKeys,
    String? description,
    String? organizationId,
  }) async {
    try {
      final headers = await _getHeaders();


      String? orgId = organizationId;
      if (orgId == null) {
        final prefs = await SharedPreferences.getInstance();
        orgId = prefs.getString('organization_id');
      }

      final body = {
        'name': name,
        'permissions': permissionIds,
        "permissionKeys": permissionKeys,

        if (description != null && description.isNotEmpty) 'description': description,
        if (orgId != null) 'organizationId': orgId,
      };

      debugPrint('Creating role with body: ${json.encode(body)}');

      final response = await http.post(
        Uri.parse('$baseUrl/roles'),
        headers: headers,
        body: json.encode(body),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception('Connection timeout'),
      );

      debugPrint('Create Role Status Code: ${response.statusCode}');
      debugPrint('Create Role Response: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Please login again');
      } else {
        final errorBody = json.decode(response.body);
        throw Exception(errorBody['message'] ?? 'Failed to create role: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error creating role: $e');
      throw Exception('Error creating role: $e');
    }
  }


  static Future<Map<String, dynamic>> updateRole({
    required String roleId,
    required String name,
    required List<String> permissionIds,
    String? description,
  }) async {
    try {
      final headers = await _getHeaders();

      final body = {
        'name': name,
        'permissions': permissionIds,
        if (description != null && description.isNotEmpty) 'description': description,
      };

      debugPrint('Updating role $roleId with body: ${json.encode(body)}');

      final response = await http.put(
        Uri.parse('$baseUrl/roles/$roleId'),
        headers: headers,
        body: json.encode(body),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception('Connection timeout'),
      );

      debugPrint('Update Role Status Code: ${response.statusCode}');
      print('Update Role Response: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Please login again');
      } else {
        final errorBody = json.decode(response.body);
        throw Exception(errorBody['message'] ?? 'Failed to update role: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error updating role: $e');
      throw Exception('Error updating role: $e');
    }
  }


  static Future<Map<String, dynamic>> deleteRole(String roleId) async {
    try {
      final headers = await _getHeaders();

      final response = await http.delete(
        Uri.parse('$baseUrl/roles/$roleId'),
        headers: headers,
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception('Connection timeout'),
      );

      debugPrint('Delete Role Status Code: ${response.statusCode}');
      debugPrint('Delete Role Response: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Please login again');
      } else {
        final errorBody = json.decode(response.body);
        throw Exception(errorBody['message'] ?? 'Failed to delete role: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error deleting role: $e');
      throw Exception('Error deleting role: $e');
    }
  }


  static Future<Role> getRoleById(String roleId) async {
    try {
      final headers = await _getHeaders();

      final response = await http.get(
        Uri.parse('$baseUrl/roles/$roleId'),
        headers: headers,
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception('Connection timeout'),
      );

      debugPrint('Get Role By ID Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return Role.fromJson(jsonData['data']);
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Please login again');
      } else {
        throw Exception('Failed to load role: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching role by ID: $e');
      throw Exception('Error fetching role: $e');
    }
  }
}