import 'package:dt_mobile/models/response/tempreture_response.dart';
import 'package:dt_mobile/services/socket_service.dart';
import 'package:dt_mobile/services/temp_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

class IndoorClimateMini extends StatefulWidget {
  const IndoorClimateMini({super.key});

  @override
  State<IndoorClimateMini> createState() => _IndoorClimateMiniState();
}

class _IndoorClimateMiniState extends State<IndoorClimateMini> {
  TemperatureLatestResponse? latestData;
  bool isLoading = true;
  String? errorMessage;
  Timer? _reconnectTimer;
  bool isConnected = false;

  @override
  void initState() {
    super.initState();
    _initializeConnection();
  }

  Future<void> _initializeConnection() async {

    await _fetchInitialData();

    // Then connect socket
    await _connectSocket();
  }

  Future<void> _connectSocket() async {
    try {
      // Get token from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        print('❌ No token found - cannot connect to socket');
        return;
      }

      // Connect socket if not connected
      if (!SocketService.connected) {
        SocketService.connect(token);
      }

      // Wait a bit for connection to establish
      await Future.delayed(const Duration(milliseconds: 500));

      print('=======================================fdsfjdslfjds');

      if (SocketService.socket != null && SocketService.connected) {
        // Remove old listener if exists
        SocketService.socket!.off('temperatureUpdate');

        // Add new listener
        SocketService.socket!.on('temperatureUpdate', (data) => _onTempUpdate(data));

        print('✅ Temperature socket listener registered');
        print("Socket Connection: ${SocketService.connected}");
        setState(() {
          isConnected = SocketService.connected;
        });
      } else {
        print('⚠️ Socket not connected - will retry');
        _scheduleReconnect();
      }
    } catch (e) {
      print('❌ Socket connection error: $e');
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) {
        _connectSocket();
      }
    });
  }

  void _onTempUpdate(dynamic data) {
    if (!mounted) return;

    try {
      print('📥 Received temperature update');

      final jsonData = data is String ? jsonDecode(data) : data;
      final updatedResponse = TemperatureLatestResponse.fromJson(jsonData);

      setState(() {
        latestData = updatedResponse;
        errorMessage = null;
      });

      print('✅ Temperature updated: ${updatedResponse.data.temperature}°C');
    } catch (e) {
      print('❌ Error parsing socket data: $e');
    }
  }

  @override
  void dispose() {
    _reconnectTimer?.cancel();

    SocketService.socket?.off('temperatureUpdate', _onTempUpdate);

    super.dispose();
  }

  Future<void> _fetchInitialData() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final data = await TemperatureService.getLatest( nodeId: 'GHT-N_0005',  timeAgo: '12h');

      if (!mounted) return;

      setState(() {
        latestData = data;
        isLoading = false;
        if (data == null) {
          errorMessage = 'No data available';
        }
      });
    } catch (e) {
      print('❌ Error fetching initial data: $e');

      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load temperature data';
      });
    }
  }

  String formatDate(DateTime date) {
    return DateFormat('hh:mm a, dd/MM/yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    // Loading state
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    // Error state
    if (errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, color: Colors.red[300], size: 32),
              const SizedBox(height: 8),
              Text(
                errorMessage!,
                style: TextStyle(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: _fetchInitialData,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    // No data state
    if (latestData == null) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(
          child: Text('No temperature data available'),
        ),
      );
    }

    final data = latestData!.data;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                "Last Updated: ${formatDate(data.updatedAt)}",
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 8),
              // Connection indicator
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isConnected ? Colors.green : Colors.grey,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Temperature
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Temperature",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "${data.temperature.toStringAsFixed(1)}°C",
                        style: const TextStyle(
                          fontSize: 45,
                          height: 1,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(width: 32),
              // Humidity
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Humidity",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        data.humidity.toStringAsFixed(0),
                        style: const TextStyle(
                          fontSize: 45,
                          height: 1,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(bottom: 6, left: 2),
                        child: Text(
                          "%",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}