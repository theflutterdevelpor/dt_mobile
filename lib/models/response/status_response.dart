//
// class StatusChangeResponse {
//   final bool success;
//   final int code;
//   final String? message;
//
//   StatusChangeResponse({
//     required this.success,
//     required this.code,
//     this.message,
//   });
//
//   factory StatusChangeResponse.fromJson(Map<String, dynamic> json) {
//     return StatusChangeResponse(
//       success: json['success'] ?? false,
//       code: json['code'] ?? 0,
//       message: json['message']?.toString(),
//     );
//   }
// }
//
//
// class Complaint {
//   final String id;
//   final String complaintId; // backend: compliantId
//   final String name;
//   final String contact;
//   final String email;
//   final String title;
//   final String description;
//   final String status;
//   final String priority;
//   final String organization;
//   final String building;
//   final String floor;
//   final String space;
//   final List<String> images;
//   final DateTime createdAt;
//   final DateTime updatedAt;
//
//   Complaint({
//     required this.id,
//     required this.complaintId,
//     required this.name,
//     required this.contact,
//     required this.email,
//     required this.title,
//     required this.description,
//     required this.status,
//     required this.priority,
//     required this.organization,
//     required this.building,
//     required this.floor,
//     required this.space,
//     required this.images,
//     required this.createdAt,
//     required this.updatedAt,
//   });
//
//   factory Complaint.fromJson(Map<String, dynamic> json) {
//     return Complaint(
//       id: json['_id']?.toString() ?? '',
//       complaintId:
//       json['compliantId']?.toString() ?? json['_id']?.toString() ?? '',
//       name: json['name']?.toString() ?? '',
//       contact: json['contact']?.toString() ?? '',
//       email: json['email']?.toString() ?? '',
//       title: json['title']?.toString() ?? '',
//       description: json['description']?.toString() ?? '',
//       status: json['status']?.toString() ?? 'open',
//       priority: json['priority']?.toString() ?? '',
//       organization: json['organization']?.toString() ?? '',
//       building: json['building']?.toString() ?? '',
//       floor: json['floor']?.toString() ?? '',
//       space: json['space']?.toString() ?? '',
//       images: (json['images'] as List?)
//           ?.map((e) => e.toString())
//           .toList() ??
//           [],
//       createdAt:
//       DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
//           DateTime.now(),
//       updatedAt:
//       DateTime.tryParse(json['updatedAt']?.toString() ?? '') ??
//           DateTime.now(),
//     );
//   }
// }
//
