import 'dart:convert';
import 'package:dt_mobile/models/response/device_response.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class DeviceService {
  static const String baseUrl = 'http://3.231.62.206:5000/api/v1';


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

  // =================== GET DEVICES ===================
  static Future<List<DeviceModel>> getDevices() async {
    final uri = Uri.parse('$baseUrl/org/devices');
    final headers = await getHeaders();


    print("REQUEST URL: $uri");
    print("HEADERS: $headers");

    final response = await http.get(uri, headers: headers);

    print("STATUS CODE: ${response.statusCode}");
    print("RESPONSE BODY: ${response.body}");

    final body = jsonDecode(response.body);

    if (response.statusCode == 200 && body['success'] == true) {
      final deviceResponse = DeviceListResponse.fromJson(body);
      return deviceResponse.devices;
    } else {
      throw Exception(body['message'] ?? "Failed to load devices");
    }
  }


  static Future<List<DeviceModel>> getFilteredDevicesLocal({
    required String buildingId,
    String? floorId,
    String? deviceName,
  }) async {
    final devices = await getDevices();

    print("🔍 FILTERING WITH:");
    print("   Building ID: $buildingId");
    print("   Floor ID: $floorId");
    print("   Device Name: $deviceName");
    print("   Total Devices: ${devices.length}");

    final filtered = devices.where((d) {
      print("\n📱 Checking Device: ${d.name}");
      print("   Device Building ID: ${d.building?.id}");
      print("   Device Floor ID: ${d.floor?.id}");

      final buildingMatch = d.building?.id == buildingId;
      final floorMatch = floorId == null ||
          d.floor?.id == floorId ||
          d.floor == null;
      final deviceMatch = deviceName == null ||
          d.name.toLowerCase().contains(deviceName.toLowerCase());

      final matches = buildingMatch && floorMatch && deviceMatch;

      if (matches) {
        print("✅ MATCHED: ${d.name} (${d.deviceId}) - Floor: ${d.floor?.label ?? 'No Floor'}");
      }

      print("   Building Match: $buildingMatch");
      print("   Floor Match: $floorMatch");
      print("   Device Match: $deviceMatch");
      print("   RESULT: ${buildingMatch && floorMatch && deviceMatch}");

      return buildingMatch && floorMatch && deviceMatch;
    }).toList();

    print("\n✅ FILTERED COUNT: ${filtered.length}");
    return filtered;
  }


}
