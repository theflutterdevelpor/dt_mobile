import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/response/energy_response.dart';
import '../../services/energy_services.dart';

class AqiSensorScreen extends StatefulWidget {
  const AqiSensorScreen({Key? key}) : super(key: key);

  @override
  State<AqiSensorScreen> createState() => _AqiSensorScreenState();
}

class _AqiSensorScreenState extends State<AqiSensorScreen> {
  EnergyDetailsResponse? energyResponse;
  bool isLoading = true;
  String? errorMessage;

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
        if (data.threePhaseData.isNotEmpty) {
          latestThreePhase = data.threePhaseData.last;
        }

        setState(() {
          energyResponse = res;
          isLoading = false;
        });
      } else {
        setState(() => errorMessage = "No data received");
      }
    } catch (e) {
      setState(() => errorMessage = "Failed to load data: $e");
    }
  }

  String formatDate(DateTime? date) {
    if (date == null) return '--';
    return DateFormat("dd MMM yyyy, hh:mm a").format(date);
  }

  @override
  Widget build(BuildContext context) {
    final data = energyResponse?.data;
    final phase = latestThreePhase;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'AQI Sensor',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: fetchData),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null || data == null
          ? Center(child: Text(errorMessage!))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ================== AQI Index Card ==================
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 4,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('IAQ Index', style: TextStyle(fontSize: 14, color: Colors.grey)),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          (phase?.avgPower ?? 0).toStringAsFixed(0), // AQI ke liye avgPower use kiya (tum adjust kar sakte ho)
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'µg/m³',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ================== Other Parameters ==================
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 4,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Other Parameters', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _paramItem('TVOC', '${(phase?.avgReactivePower ?? 0).toStringAsFixed(0)} µg/m³'),
                        _paramItem('Temperature', '25.49°C'),
                        _paramItem('Humidity', '49.5%'),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _paramItem('PM 1.0', '14.9 µg/m³'),
                        _paramItem('PM 2.5', '63.1 µg/m³'),
                        _paramItem('PM 10', '92.2 µg/m³'),
                      ],
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

  Widget _paramItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}