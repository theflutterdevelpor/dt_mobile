class DashboardResponse {
  final bool success;
  final int code;
  final DashboardData? data;
  final String? message;

  DashboardResponse({
    required this.success,
    required this.code,
    this.data,
    this.message,
  });

  factory DashboardResponse.fromJson(Map<String, dynamic> json) {
    return DashboardResponse(
      success: json['success'] ?? false,
      code: json['code'] ?? 0,
      data: json['data'] != null ? DashboardData.fromJson(json['data']) : null,
      message: json['message'],
    );
  }
}

class DashboardData {
  final int devices;
  final int buildings;
  final int floors;
  final int spaces;
  final int pendingComplaints;
  final int resolvedComplaints;
  final int inProgressComplaints;
  final int todayPendingComplaints;
  final int todayResolvedComplaints;
  final int todayInProgressComplaints;
  final int todayTotalComplaints;
  final int totalComplaints;

  DashboardData({
    required this.devices,
    required this.buildings,
    required this.floors,
    required this.spaces,
    required this.pendingComplaints,
    required this.resolvedComplaints,
    required this.inProgressComplaints,
    required this.todayPendingComplaints,
    required this.todayResolvedComplaints,
    required this.todayInProgressComplaints,
    required this.todayTotalComplaints,
    required this.totalComplaints,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      devices: json['devices'] ?? 0,
      buildings: json['buildings'] ?? 0,
      floors: json['floors'] ?? 0,
      spaces: json['spaces'] ?? 0,
      pendingComplaints: json['pendingComplaints'] ?? 0,
      resolvedComplaints: json['resolvedComplaints'] ?? 0,
      inProgressComplaints: json['inProgressComplaints'] ?? 0,
      todayPendingComplaints: json['todayPendingComplaints'] ?? 0,
      todayResolvedComplaints: json['todayResolvedComplaints'] ?? 0,
      todayInProgressComplaints: json['todayInProgressComplaints'] ?? 0,
      todayTotalComplaints: json['todayTotalComplaints'] ?? 0,
      totalComplaints: json['totalComplaints'] ?? 0,
    );
  }
}