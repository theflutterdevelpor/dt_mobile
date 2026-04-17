
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/response/motion_response.dart';
import '../../services/motion_service.dart';
import '../../widgets/motion_chart.dart';


class MotionSensorScreen extends StatefulWidget {
  const MotionSensorScreen({Key? key}) : super(key: key);

  @override
  State<MotionSensorScreen> createState() => _MotionSensorScreenState();
}

class _MotionSensorScreenState extends State<MotionSensorScreen> {
  Data? sensorData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    print("🚀 Screen Loaded - Calling API...");
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      print("📡 API CALL STARTED...");

      final res = await MotionSensorService.getMotionSensorDetails(
        deviceId: "PIR-N_0004",
        timeAgo: "1d",
      );

      print("📥 API RESPONSE RECEIVED");

      if (res != null) {
        print("✅ SUCCESS: ${res.success}");
        print("📊 CODE: ${res.code}");
        print("📍 LOCATION: ${res.data.location}");
        print("🔋 BATTERY: ${res.data.battery}");
        print("📈 TOTAL EVENTS: ${res.data.total}");
        print("📦 MOTION DATA: ${res.data.motionData}");
        print("🔔 NOTIFICATIONS: ${res.data.notification}");

        setState(() {
          sensorData = res.data;
          isLoading = false;
        });
      } else {
        print("❌ RESPONSE IS NULL");
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print("🚨 ERROR: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  String formatDateTime(DateTime date) {
    return DateFormat("MMMM d, yyyy 'at' hh:mm:ss a").format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: Colors.purple, // Changed to purple for motion sensor
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.sensors, color: Colors.white, size: 18), // Changed icon
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Motion Sensor',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  sensorData != null
                      ? 'Last updated: ${formatDateTime(sensorData!.installationDate)}'
                      : '--',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : sensorData == null
          ? const Center(child: Text("No Data"))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Motion Detection Card
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    // Motion Detection Section
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Motion Detected',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                            ),
                          ),
                          const SizedBox(height: 7),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                "March 23,2025\n10:40",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.green[500],
                                ),
                              ),

                            ],
                          ),
                        ],
                      ),
                    ),


                  ],
                ),
              ),
            ),
            const SizedBox(height: 5),

            // Sensor Information Card
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sensor Information',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.location_on, color: Colors.grey[400], size: 16),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Location',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                sensorData?.location ?? "__",
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.refresh, color: Colors.grey[400], size: 16),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Last Calibration',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                sensorData?.lastCalibration.toString().split(' ').first ?? "--",
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.calendar_today, color: Colors.grey[400], size: 16),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Installation Date',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                sensorData?.installationDate.toString().split(' ').first ?? "--",
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 30),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.battery_full, color: Colors.grey[400], size: 16),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Battery',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                sensorData?.battery ?? "--",
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.green[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),


            const MotionSensorChart(deviceId: 'PIR-N_0004',),

            const SizedBox(height: 10),

            // Statistics Card
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Motion Statistics',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildStatRow('Daily Average:',
                        "300",
                        Colors.grey),
                    _buildStatRow('Daily Min:',
                        "250",
                        Colors.grey),
                    _buildStatRow('Daily Max:',
                        "500",
                        Colors.grey),

                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Recent Alerts Card
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Recent Alerts',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildAlertItem(
                      type: 'Information',
                      message: 'Motion sensor data updated successfully',
                      time: 'Just now',
                      color: Colors.purple,
                      icon: Icons.notifications_active,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, Color labelColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: labelColor, fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertItem({
    required String type,
    required String message,
    required String time,
    required Color color,
    required IconData icon,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    type,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    time,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                message,
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}