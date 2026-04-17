import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/response/gas_response.dart';
import '../../services/gas_services.dart';
import '../../widgets/co2_chart.dart';

class GasSensorScreen extends StatefulWidget {
  const GasSensorScreen({Key? key}) : super(key: key);

  @override
  State<GasSensorScreen> createState() => _GasSensorScreenState();
}

class _GasSensorScreenState extends State<GasSensorScreen> {
  GasLatestResponse? sensorResponse;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final res = await GasService.getSensorByNodeId(
        nodeId: "MQ7-N_0003",
        timeAgo: "1d",
      );

      if (res != null && res.success == true && res.data != null) {
        setState(() {
          sensorResponse = res;
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = "No data received from server";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Failed to load data: $e";
        isLoading = false;
      });
    }
  }

  String formatDate(DateTime? date) {
    if (date == null) return '--';
    return DateFormat("MMMM d, yyyy").format(date);
  }

  // Safe Date Formatter for String dates (installationDate & lastCalibration)
  String formatDateString(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '--';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat("MMMM d, yyyy").format(date);
    } catch (e) {
      return dateStr.split('T').first.split(' ').first;
    }
  }

  Color _getCOColor(double co) {
    if (co < 5) return Colors.green;
    if (co < 15) return Colors.lightGreen;
    if (co < 35) return Colors.orange;
    return Colors.red;
  }

  Color _getCO2Color(double co2) {
    if (co2 < 600) return Colors.green;
    if (co2 < 1000) return Colors.orange;
    return Colors.red;
  }

  String getGasLevelStatus(double co) {
    if (co < 5) return "Excellent";
    if (co < 15) return "Good";
    if (co < 35) return "Moderate";
    return "Hazardous";
  }

  @override
  Widget build(BuildContext context) {
    final data = sensorResponse?.data;
    final coLevel = data?.co ?? 0.0;
    final co2Level = data?.co2 ?? 0.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: Colors.lightBlueAccent,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.gas_meter, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Gas Sensor (${data?.nodeId ?? '--'})',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Last updated: ${formatDate(data?.updatedAt)}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 11),
                ),
              ],
            ),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : data == null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(errorMessage ?? "No Data Available"),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: fetchData,
              child: const Text("Retry"),
            ),
          ],
        ),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Latest Readings Card
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 2,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'LATEST READINGS',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${co2Level.toStringAsFixed(2)} ppm',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w400,
                                  color: _getCO2Color(co2Level),
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text('CO₂ Level', style: TextStyle(fontSize: 13, color: Colors.grey)),
                            ],
                          ),
                        ),
                        Container(width: 1, height: 50, color: Colors.grey[300]),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${coLevel.toStringAsFixed(2)} ppm',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w400,
                                  color: _getCOColor(coLevel),
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text('CO Level', style: TextStyle(fontSize: 13, color: Colors.grey)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Sensor Information Card
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 4,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Sensor Information',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: _infoColumn(Icons.location_on, 'Location', data.location ?? '--',
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: _infoColumn(
                            Icons.refresh,
                            'Last Calibration',
                            formatDate(data.lastCalibration ),   // Fixed here
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _infoColumn(
                            Icons.calendar_today,
                            'Installation Date',
                            formatDate(data.installationDate), // Fixed here
                          ),
                        ),
                        const SizedBox(width: 30),
                        Expanded(
                          child: _infoColumn(Icons.battery_full, 'Battery', data.battery ?? '--'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            SizedBox(
              height: 300,
              child: CO2Chart(deviceId: 'MQ7-N_0003'),
            ),
            const SizedBox(height: 10),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 4,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Gas Statistics',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 12),
                    _buildStatRow('CO Level', '${coLevel.toStringAsFixed(2)} ppm'),
                    _buildStatRow('CO₂ Level', '${co2Level.toStringAsFixed(2)} ppm'),
                    _buildStatRow('Sensor Type', data.type ?? 'MQ7'),
                    _buildStatRow('Status', getGasLevelStatus(coLevel)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),


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
                      message: 'Sensor data updated successfully',
                      time: 'Just now',
                      color: Colors.orange,
                      icon: Icons.info_outline,
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

  Widget _infoColumn(IconData icon, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.grey[400], size: 16),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey[800])),
          ],
        ),
        const SizedBox(height: 4),
        Text(value, style:  TextStyle(fontSize: 11, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
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
