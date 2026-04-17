import 'dart:convert';
import 'dart:io';
import 'package:dt_mobile/models/response/profile_response.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ProfileApiService {
  static const String baseUrl = 'http://3.231.62.206:5000/api/v1';


  static Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('auth_token');
    } catch (e) {
      print("Get Token Exception: $e");
      return null;
    }
  }

  static Future<Map<String, String>> getHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }



  static Future<ProfileModel?> getProfile() async {
    try {
      final headers = await getHeaders();

      final response = await http.get(
        Uri.parse("$baseUrl/admin/profile"),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final profileResponse = ProfileResponse.fromJson(jsonResponse);
        return profileResponse.data;
      } else {
        print("Get Profile Error - Status: ${response.statusCode}, Body: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Get Profile Exception: $e");
      return null;
    }
  }

  static Future<Map<String, dynamic>> updateProfile({
    String? name,
    String? password,
    File? imageFile,
  }) async {
    try {
      final token = await getToken();

      final request = http.MultipartRequest(
        'PUT',
        Uri.parse("$baseUrl/admin/profile"),
      );

      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }


      if (name != null && name.isNotEmpty) {
        request.fields['name'] = name;
      }
      if (password != null && password.isNotEmpty) {
        request.fields['password'] = password;
      }


      if (imageFile != null && await imageFile.exists()) {
        request.files.add(
          await http.MultipartFile.fromPath('file', imageFile.path),
        );
        print("✅ Image attached: ${imageFile.path}");
      }

      print("📤 Sending update request...");
      print("Fields: ${request.fields.keys}");

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print("📡 Response Status: ${response.statusCode}");
      print("📡 Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return {
          'success': true,
          'data': jsonResponse['data'],
          'message': 'Profile updated successfully',
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to update profile',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      print("Update Profile Exception: $e");
      return {
        'success': false,
        'message': 'An error occurred: $e',
      };
    }
  }


  // static Future<bool> uploadProfileImage({
  //   required String filePath,
  // }) async {
  //   try {
  //     final token = await getToken();
  //
  //     final request = http.MultipartRequest(
  //       'POST',
  //       Uri.parse("$baseUrl/admin/upload-image"),
  //     );
  //
  //     if (token != null) {
  //       request.headers['Authorization'] = 'Bearer $token';
  //     }
  //
  //     request.files.add(
  //       await http.MultipartFile.fromPath('image', filePath),
  //     );
  //
  //     final streamedResponse = await request.send();
  //
  //     return streamedResponse.statusCode == 200;
  //   } catch (e) {
  //     print("Upload Profile Image Exception: $e");
  //     return false;
  //   }
  // }


  static Future<Map<String, dynamic>> deleteProfileImage() async {
    try {
      final headers = await getHeaders();

      final response = await http.delete(
        Uri.parse("$baseUrl/admin/delete-image"),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return {
          'success': true,
          'data': jsonResponse['data'],
          'message': 'Image deleted successfully',
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to delete image',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      print("Delete Profile Image Exception: $e");
      return {
        'success': false,
        'message': 'An error occurred: $e',
      };
    }
  }


  static Future<Map<String, dynamic>> deleteAccount() async {
    try {
      final profile = await getProfile();
      if (profile == null) {
        return {
          'success': false,
          'message': 'Unable to get user profile',
        };
      }

      final headers = await getHeaders();

      final response = await http.delete(
        Uri.parse("$baseUrl/admin/delete/${profile.id}"),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('auth_token');

        final jsonResponse = jsonDecode(response.body);
        return {
          'success': true,
          'message': jsonResponse['message'] ?? 'Account deleted successfully',
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to delete account',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      print("Delete Account Exception: $e");
      return {
        'success': false,
        'message': 'An error occurred: $e',
      };
    }
  }


  static Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    return updateProfile(
      password: newPassword,
    );
  }

  static Future<ProfileModel?> refreshProfile() async {
    return await getProfile();
  }

  static Future<bool> isAuthenticated() async {
    final token = await getToken();
    if (token == null || token.isEmpty) return false;

    final profile = await getProfile();
    return profile != null;
  }

  static Future<bool> updateProfileWithMap({
    required Map<String, dynamic> body,
  }) async {
    final result = await updateProfile(
      name: body['name'],
     password: body['password'],
    );
    return result['success'] == true;
  }
}