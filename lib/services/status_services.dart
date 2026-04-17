// import 'dart:convert';
// import 'package:dt_mobile/models/response/status_response.dart' hide Complaint;
// import 'package:http/http.dart' as http;
// import 'package:dt_mobile/models/response/complain_response.dart';// <- import the new model
// import 'package:shared_preferences/shared_preferences.dart';
//
// class MaintenanceApi {
//   final String baseUrl = 'http://3.231.62.206:5000/api/v1';
//
//   // 🔹 Get token
//   static Future<String?> getToken() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString('auth_token');
//   }
//
//   // 🔹 Common headers
//   static Future<Map<String, String>> getHeaders() async {
//     final token = await getToken();
//
//     return {
//       'Content-Type': 'application/json',
//       if (token != null) 'Authorization': 'Bearer $token',
//     };
//   }
//
//   // 🔹 Get all complaints
//   Future<List<Complaint>> getComplaints({
//     required String fromDate,
//     required String toDate,
//   }) async {
//     try {
//       final headers = await getHeaders();
//
//       final response = await http.get(
//         Uri.parse(
//           '$baseUrl/org/complain/get-all?fromDate=$fromDate&toDate=$toDate',
//         ),
//         headers: headers,
//       );
//
//       print('📥 Get Complaints Response: ${response.statusCode}');
//
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//
//         if (data['success'] == true && data['data'] != null) {
//           return (data['data'] as List)
//               .map((e) => Complaint.fromJson(e))
//               .toList();
//         }
//       }
//       return [];
//     } catch (e) {
//       print('❌ Error getting complaints: $e');
//       return [];
//     }
//   }
//
//   // 🔹 Change complaint status using StatusChangeResponse
//   Future<StatusChangeResponse> changeComplaintStatus({
//     required String complaintId,
//     required String status,
//   }) async {
//     try {
//       final headers = await getHeaders();
//
//       final response = await http.post(
//         Uri.parse('$baseUrl/org/complain/change-status/$complaintId'),
//         headers: headers,
//         body: json.encode({'status': status}),
//       );
//
//       print('📤 Change Status: $complaintId → $status');
//       print('📥 Response: ${response.statusCode}');
//       print('📄 Body: ${response.body}');
//
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         return StatusChangeResponse.fromJson(data);
//       }
//
//       return StatusChangeResponse(success: false, code: response.statusCode, message: 'Failed to change status');
//     } catch (e) {
//       print('❌ Error changing complaint status: $e');
//       return StatusChangeResponse(success: false, code: 500, message: e.toString());
//     }
//   }
//
//   // 🔹 Get complaint by ID
//   Future<Complaint?> getComplaintById(String complaintId) async {
//     try {
//       final headers = await getHeaders();
//
//       final response = await http.get(
//         Uri.parse('$baseUrl/org/complain/get-by-id/$complaintId'),
//         headers: headers,
//       );
//
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//
//         if (data['success'] == true && data['data'] != null) {
//           return Complaint.fromJson(data['data']);
//         }
//       }
//       return null;
//     } catch (e) {
//       print('❌ Error getting complaint by ID: $e');
//       return null;
//     }
//   }
// }
