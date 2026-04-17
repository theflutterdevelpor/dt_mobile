import 'dart:convert';
import 'package:dt_mobile/models/response/aqi_aggregated_model.dart';
import 'package:http/http.dart' as http;
import 'package:dt_mobile/models/response/aqi_response.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://3.231.62.206:5000/api/v1';

  static Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null) {
        print('❌ No auth_token found in SharedPreferences');
      } else {
        print('✅ Token retrieved successfully');
      }
      return token;
    } catch (e) {
      print('❌ Error getting token: $e');
      return null;
    }
  }

  static Future<Map<String, String>> getHeaders() async {
    final token = await getToken();
    if (token == null || token.isEmpty) {
      throw Exception('User not authenticated ❌');
    }
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  static Future<List<Map<String, dynamic>>> fetchAqiDevicesList() async {
    try {
      print('═══════════════════════════════════════');
      print('FETCHING AQI DEVICES LIST');
      print('═══════════════════════════════════════');

      final token = await getToken();
      if (token == null) throw Exception('Authentication token not found');

      final uri = Uri.parse('$baseUrl/org/devices').replace(
        queryParameters: {'name': 'Aqi Sensor'},
      );

      print('REQUEST URL: $uri');

      final response = await http.get(uri, headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      });

      print('STATUS CODE: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData['success'] == true && jsonData['data'] != null) {
          final List<dynamic> devicesJson = jsonData['data'];

          final devices = devicesJson
              .where((d) =>
          d['deviceId'] != null &&
              (d['deviceId'] as String).isNotEmpty)
              .map((device) => {
            'deviceId': device['deviceId'] as String,
            'name': (device['name'] as String?)?.isNotEmpty == true
                ? device['name']
                : device['deviceId'] ?? 'Unknown Device',
            '_id': device['_id'] ?? '',
            'status': device['status'] ?? 'unknown',
          })
              .toList();

          print('Found ${devices.length} AQI devices');
          for (var d in devices) {
            print('  - ${d['name']} (${d['deviceId']}) [${d['status']}]');
          }

          return devices;
        } else {
          throw Exception('No AQI devices found');
        }
      } else {
        throw Exception(
            'Failed to fetch AQI devices: ${response.statusCode}');
      }
    } catch (e, st) {
      print('❌ EXCEPTION in fetchAqiDevicesList: $e');
      print('Stack: $st');
      rethrow;
    }
  }

  static Future<AqiData?> fetchAqiDevice(
      String deviceId, {
        String? toDate,
      }) async {
    try {
      print('═══════════════════════════════════════');
      print('AQI API REQUEST — Device: $deviceId');
      print('═══════════════════════════════════════');

      final token = await getToken();
      if (token == null) throw Exception('Authentication token not found');

      final tokenPreview =
      token.length > 20 ? token.substring(0, 20) : token;
      print('Token: $tokenPreview...');

      final uri = Uri.parse('$baseUrl/aqi-latest/$deviceId').replace(
        queryParameters: toDate != null ? {'toDate': toDate} : null,
      );

      print('REQUEST URL: $uri');

      final response = await http.get(uri, headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      });

      print('STATUS CODE: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData['success'] == true && jsonData['data'] != null) {
          final aqiData = AqiData.fromJson(jsonData['data']);
          print('✅ Parsed: ${aqiData.deviceId}');
          return aqiData;
        } else {
          print('⚠️ No data in response for $deviceId');
          return null;
        }
      } else {
        throw Exception(
            'Failed to load AQI data: ${response.statusCode}');
      }
    } catch (e, st) {
      print('❌ EXCEPTION in fetchAqiDevice($deviceId): $e');
      print('Stack: $st');
      rethrow;
    }
  }

  static Future<List<AqiData>> fetchAllAqiDevices({
    String? toDate,
  }) async {
    try {
      print('═══════════════════════════════════════');
      print('FETCHING ALL AQI DEVICES (Parallel)');
      print('═══════════════════════════════════════');

      final token = await getToken();
      if (token == null) throw Exception('Authentication token not found');

      final devicesList = await fetchAqiDevicesList();
      if (devicesList.isEmpty) throw Exception('No AQI devices available');

      final deviceIds =
      devicesList.map((d) => d['deviceId'] as String).toList();
      print('Fetching ${deviceIds.length} devices in parallel...');

      final results = await Future.wait(
        deviceIds.map((id) async {
          try {
            return await fetchAqiDevice(id, toDate: toDate);
          } catch (e) {
            print('⚠️ FAILED: $id — $e');
            return null;
          }
        }),
      );

      final aqiDataList = results.whereType<AqiData>().toList();

      print('✅ Success: ${aqiDataList.length}/${deviceIds.length} devices');

      if (aqiDataList.isEmpty) {
        throw Exception('Failed to load any device sensor data');
      }

      return aqiDataList;
    } catch (e, st) {
      print('❌ EXCEPTION in fetchAllAqiDevices: $e');
      print('Stack: $st');
      rethrow;
    }
  }

  static Future<List<AqiData>> fetchMultipleAqiDevices({
    required List<String> deviceIds,
    String? toDate,
  }) async {
    try {
      print('═══════════════════════════════════════');
      print('FETCHING ${deviceIds.length} SPECIFIC DEVICES (Parallel)');
      print('═══════════════════════════════════════');

      final results = await Future.wait(
        deviceIds.map((id) async {
          try {
            return await fetchAqiDevice(id, toDate: toDate);
          } catch (e) {
            print('⚠️ FAILED: $id — $e');
            return null;
          }
        }),
      );

      final aqiDataList = results.whereType<AqiData>().toList();
      print('✅ Total loaded: ${aqiDataList.length}/${deviceIds.length}');
      return aqiDataList;
    } catch (e, st) {
      print('❌ EXCEPTION in fetchMultipleAqiDevices: $e');
      print('Stack: $st');
      return [];
    }
  }

  static Future<AqiResponse?> fetchAqiResponse(
      String deviceId, {
        String? toDate,
      }) async {
    try {
      print('Fetching full AQI response for: $deviceId');

      final token = await getToken();
      if (token == null) throw Exception('Authentication token not found');

      final uri = Uri.parse('$baseUrl/aqi-latest/$deviceId').replace(
        queryParameters: toDate != null ? {'toDate': toDate} : null,
      );

      final response = await http.get(uri, headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      });

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return AqiResponse.fromJson(jsonData);
      } else {
        print('❌ Failed: ${response.statusCode}');
        return null;
      }
    } catch (e, st) {
      print('❌ EXCEPTION in fetchAqiResponse: $e');
      print('Stack: $st');
      return null;
    }
  }

  static Future<AqiAggregatedResponse> fetchAqiAggregatedData({
    required String fromDate,
    required String toDate,
    required bool aggregated,
    String? deviceId,
  }) async {
    try {
      print('═══════════════════════════════════════');
      print('FETCHING AGGREGATED AQI DATA');
      print(deviceId != null
          ? 'Device: $deviceId'
          : 'All Devices');
      print('═══════════════════════════════════════');

      final token = await getToken();
      if (token == null) throw Exception('Authentication token not found');

      final queryParams = <String, String>{
        'fromDate': fromDate,
        'toDate': toDate,
        'aggregated': aggregated.toString(),
      };
      if (deviceId != null && deviceId.isNotEmpty) {
        queryParams['deviceId'] = deviceId;
      }

      final uri = Uri.parse('$baseUrl/aqi').replace(
        queryParameters: queryParams,
      );

      print('REQUEST URL: $uri');

      final response = await http.get(uri, headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      }).timeout(const Duration(seconds: 15));

      print('STATUS CODE: ${response.statusCode}');
      print('RESPONSE SIZE: ${response.body.length} bytes');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final aqiResponse = AqiAggregatedResponse.fromJson(jsonData);
        print('✅ Loaded ${aqiResponse.data.length} data points');
        return aqiResponse;
      } else {
        throw Exception(
            'Failed (${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      print('❌ ERROR in fetchAqiAggregatedData: $e');
      rethrow;
    }
  }

  static Future<List<String>> fetchAvailableAqiDevices() async {
    try {
      print('═══════════════════════════════════════');
      print('FETCHING AVAILABLE AQI DEVICE IDs');
      print('═══════════════════════════════════════');

      final devicesList = await fetchAqiDevicesList();
      final deviceIds =
      devicesList.map((d) => d['deviceId'] as String).toList();

      print('Found ${deviceIds.length} devices: $deviceIds');
      return deviceIds;
    } catch (e) {
      print('❌ Error in fetchAvailableAqiDevices: $e');
      rethrow;
    }
  }
}