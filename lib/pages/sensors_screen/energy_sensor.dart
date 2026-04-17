import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/response/energy_response.dart';
import '../../services/energy_services.dart';
import '../../widgets/energy_power_chart.dart';

class EnergySensorScreen extends StatefulWidget {

  const EnergySensorScreen({Key? key, }) : super(key: key);

  @override
  State<EnergySensorScreen> createState() => _EnergySensorScreenState();
}

class _EnergySensorScreenState extends State<EnergySensorScreen> {
  EnergyDetailsResponse? energyResponse;
  bool isLoading = true;
  String? errorMessage;
  PhaseData? latestPhase;
  PhaseData? latestPhase1;
  PhaseData? latestPhase2;
  PhaseData? latestPhase3;
  PhaseData? latestThreePhase;



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
      final res = await EnergyService.getEnergyDetails(
        deviceId: "SEM00001",
        timeAgo: "7d",
      );

      if (res != null && res.success == true) {


        final data = res.data;

        if (data.phaseOneData.isNotEmpty) {
          latestPhase1 = data.phaseOneData.last;
        }
        if (data.phaseTwoData.isNotEmpty) {
          latestPhase2 = data.phaseTwoData.last;
        }
        if (data.phaseThreeData.isNotEmpty) {
          latestPhase3 = data.phaseThreeData.last;
        }
        if (data.threePhaseData.isNotEmpty) {
          latestThreePhase = data.threePhaseData.last;
        }
        setState(() {
          energyResponse = res;
          isLoading = false;
        });
        debugPrint("✅ Data Loaded Successfully");
      } else {
        setState(() {
          errorMessage = "No data received or API failed";
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
    return DateFormat("dd MMM yyyy, hh:mm a").format(date);
  }
  double? getPhaseTwoVoltage() {
    if (energyResponse?.data.phaseTwoData.isNotEmpty ?? false) {
      return energyResponse!.data.phaseTwoData.last.avgVoltage;
    }
    return null;
  }

  double? getPhaseThreeVoltage() {
    if (energyResponse?.data.phaseThreeData.isNotEmpty ?? false) {
      return energyResponse!.data.phaseThreeData.last.avgVoltage;
    }
    return null;
  }





  @override
  Widget build(BuildContext context) {
    final data = energyResponse?.data;
    final phase = latestPhase;




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
                color: Colors.orange,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.bolt, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Energy Sensor (${latestThreePhase?.deviceId})',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Last updated:${formatDate(latestThreePhase?.date)}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 11),
                ),
              ],
            ),
          ],
        ),
        actions: [
          // IconButton(
          //   icon: const Icon(Icons.refresh, color: Colors.black),
          //   onPressed: fetchData,
          // ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(errorMessage!),
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
            Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,

              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                           Text(
                            'Today Energy Consumed',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800]
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                '${data?.todayEnergyUsage.toStringAsFixed(2)} ',
                                style:  TextStyle(
                                  color: Colors.green[500],
                                  fontSize: 38,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                              const SizedBox(width: 0.5,),
                              Text(
                                ' kWh',
                                style:  TextStyle(
                                  color: Colors.green[400],
                                  fontSize: 18,
                                  fontWeight: FontWeight.normal,
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
                      'Sensor Information',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: _infoColumn(Icons.location_on, 'Location', data?.location ?? '--',
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: _infoColumn(
                            Icons.refresh,
                            'Last Calibration',
                            formatDate(data?.lastCalibration ),   // Fixed here
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
                            formatDate(data?.installationDate), // Fixed here
                          ),
                        ),
                        const SizedBox(width: 30),
                        Expanded(
                          child: _infoColumn(Icons.battery_full, 'Battery', data?.battery ?? '--'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 3,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Real-time Monitoring',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFE6A817),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _metricTile(
                            label: 'Actual Power',
                            value:  (latestThreePhase?.avgPower ?? 0.0).toStringAsFixed(2),
                            unit: 'kW',
                          ),
                        ),
                        Expanded(
                          child: _metricTile(
                            label: 'Reactive Power',
                            value: (latestThreePhase?.avgReactivePower ?? 0.0).toStringAsFixed(2),
                            unit: 'kVAR',
                          ),
                        ),
                        Expanded(
                          child: _metricTile(
                            label: 'Apparent Power',
                            value: (latestThreePhase?.avgApparentPower ?? 0.0).toStringAsFixed(2),
                            unit: 'kVA',
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 28, thickness: 1, color: Color(0xFFEEEEEE)),
                    Row(
                      children: [
                        Expanded(
                          child: _metricTile(
                            label: 'Voltage',
                            value: (latestThreePhase?.avgVoltage ?? 0.0).toStringAsFixed(2),
                            unit: 'V',
                          ),
                        ),
                        Expanded(
                          child: _metricTile(
                            label: 'Current',
                            value: (latestThreePhase?.avgCurrent ?? 0.0).toStringAsFixed(2),
                            unit: 'A',
                          ),
                        ),
                        Expanded(
                          child: _metricTile(
                            label: 'Frequency',
                            value: (latestThreePhase?.avgFrequency ?? 0.0).toStringAsFixed(2),
                            unit: 'Hz',
                          ),
                        ),
                        Expanded(
                          child: _metricTile(
                            label: 'Power Factor',
                            value: (latestThreePhase?.avgPowerFactor ?? 0.0).toStringAsFixed(2),
                            unit: '',
                          ),
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
              child: EnergyPowerChart(),
            ),

            const SizedBox(height: 10),


        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 3,
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Statistics',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 16),

                _buildStatRow('Daily Average', '0.00kWh'),
                _buildStatRow('Daily Min', '0.00 kWh'),
                _buildStatRow('Daily Max', '0.00 kWh'),


                _buildStatRow('Phase 1 Voltage', '${(latestPhase1?.avgVoltage?? 0).toStringAsFixed(2)} V'),
                _buildStatRow('Phase 2 Voltage', '${(latestPhase2?.avgVoltage ?? 0).toStringAsFixed(2)} V'),
                _buildStatRow('Phase 3 Voltage', '${(latestPhase3?.avgVoltage ?? 0).toStringAsFixed(2)} V'),
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
          ],
        ),
      ),
    );
  }

  Widget _metricTile({
    required String label,
    required String value,
    required String unit,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.grey,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 6),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            children: [
              TextSpan(
                text: value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              if (unit.isNotEmpty)
                TextSpan(
                  text: ' $unit',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
        ],
      ),
    );
  }
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