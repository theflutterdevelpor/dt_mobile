import 'package:dt_mobile/services/energy_services.dart';
import 'package:flutter/material.dart';

class EnergyUsageRow extends StatefulWidget {
  const EnergyUsageRow({super.key});

  @override
  State<EnergyUsageRow> createState() => _EnergyUsageRowState();
}

class _EnergyUsageRowState extends State<EnergyUsageRow> {
  bool isLoading = true;
  String todayEnergy = "0";
  String monthlyEnergy = "0";
  String generatorUsage = "0";
  String errorMessage = "";

  @override
  void initState() {
    super.initState();
    fetchEnergyData();
  }

  Future<void> fetchEnergyData() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = "";
      });

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final monthStart = DateTime(now.year, now.month, 1);


      final todayStr = "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";
      final monthStartStr = "${monthStart.year}-${monthStart.month.toString().padLeft(2, '0')}-${monthStart.day.toString().padLeft(2, '0')}";

      debugPrint("🟢 Energy API HIT");


      final response = await EnergyService.fetchEnergy(
        fromDate: monthStartStr,
        toDate: todayStr,
      );

      if (response['success'] == true && response['data'] != null) {
        final data = response['data'];

        setState(() {

          todayEnergy = (data['todayEnergyUsage'] ?? 0.0).toStringAsFixed(2);

          // Monthly energy usage
          monthlyEnergy = (data['thisMonthEnergyUsage'] ?? 0.0).toStringAsFixed(2);


          generatorUsage = "0.00";

          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = "Data not found";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Error loading data";
        isLoading = false;
      });
      debugPrint('🔴 Energy Usage Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SizedBox(
        height: 60,
        child: Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
          ),
        ),
      );
    }

    if (errorMessage.isNotEmpty) {
      return SizedBox(
        height: 60,
        child: Center(
          child: Text(
            errorMessage,
            style: const TextStyle(
              color: Colors.red,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }
    return Row(
      children: [
        Expanded(
          child: _buildFlexCard(
            title: "Today's Electric usage",
            value: todayEnergy,
            unit: "w",
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildFlexCard(
            title: "Generator Usage",
            value: "2200",
            unit: "kwh",
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildFlexCard(
            title: "Monthly Electricity",
            value: monthlyEnergy,
            unit: "kwh",
          ),
        ),
      ],
    );
  }

  Widget _buildFlexCard({
    required String title,
    required String value,
    required String unit,
  }) {
    return Container(
      height: 58,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 8,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
              height: 1.2,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  height: 1,
                ),
              ),
              const SizedBox(width: 3),
              Text(
                unit,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}