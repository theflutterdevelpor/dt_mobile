import 'package:dt_mobile/services/auth_services.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:intl/intl.dart';

class DashboardCard extends StatefulWidget {
  const DashboardCard({super.key});

  @override
  State<DashboardCard> createState() => _DashboardCardState();
}

class _DashboardCardState extends State<DashboardCard> {
  String selectedDate = 'Today';

  double totalEnergy = 0.0;
  double percentage = 0.0;
  int maintenanceCompleted = 0;
  int maintenanceTotal = 0;
  bool isLoading = false;
  String? errorMessage;

  List<Map<String, dynamic>> floors = [];
  String? selectedFloorId;
  String selectedFloorLabel = 'Select Floor';

  final List<String> dates = ['Today', 'Yesterday', 'Week', '30 Days', '6 Months',];

  // ============ API ENDPOINT ============
  static const String energyMeterEndpoint = '/org/energy-meter';

  @override
  void initState() {
    super.initState();

    fetchFloors().then((_) {
      fetchEnergyData();
    });
  }

  // ============ DATE RANGE FUNCTION ============
  Map<String, String> getDateRange(String dateFilter) {
    DateTime today = DateTime.now();
    DateTime now = DateTime(today.year, today.month, today.day);

    DateTime fromDate, toDate;

    switch (dateFilter) {
      case 'Today':
        fromDate = now;
        toDate = now;
        break;

      case 'Yesterday':
        fromDate = now.subtract(const Duration(days: 1));
        toDate = now;
        break;

      case 'Week':
        fromDate = now.subtract(const Duration(days: 6));
        toDate = now;
        break;

      case '30 Days':
        fromDate = now.subtract(const Duration(days: 29));
        toDate = now;
        break;
      case '6 Months':
        fromDate = DateTime(
          now.year,
          now.month - 6,
          now.day,
        );
        toDate = now;
        break;

      default:
        fromDate = now;
        toDate = now;
    }

    return {
      'fromDate': DateFormat('yyyy-MM-dd').format(fromDate),
      'toDate': DateFormat('yyyy-MM-dd').format(toDate),
    };
  }

  Future<void> fetchFloors() async {
    try {
      print('🏢 Fetching Floors In Apis ...');

      final response = await ApiService.getRequest('/org/buildings');

      if (response['success'] == true && response['data'] != null) {
        final List buildings = response['data'];

        if (buildings.isEmpty) return;

        //  for now: FIRST BUILDING ke floors
        final List buildingFloors = buildings.first['floors'];

        setState(() {
          floors = List<Map<String, dynamic>>.from(buildingFloors);

          if (floors.isNotEmpty) {
            selectedFloorId = floors.first['_id'];
            selectedFloorLabel = floors.first['label'];
          }
        });
      }
    } catch (e) {
      print(' Floor API Error: $e');
    }
  }




  Future<void> fetchEnergyData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {

      Map<String, String> dateRange = getDateRange(selectedDate);


      final requestBody = {
        'fromDate': dateRange['fromDate'],
        'toDate': dateRange['toDate'],
        'floorId': selectedFloorId,
      };

      print('═══════════════════════════════════════');
      print('🔵 ENERGY METER API REQUEST');
      print('═══════════════════════════════════════');
      print('📍 Endpoint: $energyMeterEndpoint');
      print('📋 Body: $requestBody');
      print('═══════════════════════════════════════\n');


      final response = await ApiService.postRequest(
        energyMeterEndpoint,
        requestBody,
      );

      print('═══════════════════════════════════════');
      print('🟢 API RESPONSE');
      print('═══════════════════════════════════════');
      print('📥 Response: $response');
      print('═══════════════════════════════════════\n');


      if (response['success'] == true) {
        processEnergyData(response['data']);
      } else {
        setState(
              () => errorMessage =
              response['message'] ?? 'API Error - Success false',
        );
      }
    } catch (e) {
      print(' Error: $e\n');
      setState(() => errorMessage = 'Error: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  // ============ PROCESS DATA FUNCTION ============
  void processEnergyData(Map<String, dynamic> data) {
    try {
      //  ENERGY (USE BACKEND VALUE)
      double energy = (data['thisMonthEnergyUsage'] ?? 0).toDouble();

      //  PERCENTAGE
      double monthlyCapacity = 5000; // configurable
      double calculatedPercentage =
      (energy / monthlyCapacity * 100).clamp(0, 100);

      //  MAINTENANCE (USE DIRECT VALUES)
      int resolved = data['resolvedComplains'] ?? 0;
      int total = data['totalComplains'] ?? 0;

      setState(() {
        totalEnergy = energy;
        percentage = calculatedPercentage;
        maintenanceCompleted = resolved;
        maintenanceTotal = total;
      });

      print('Data Processed Successfully');
      print('Energy: $totalEnergy kWh');
      print('Percentage: $percentage%');
      print('Maintenance: $maintenanceCompleted/$maintenanceTotal\n');
    } catch (e) {
      print('Data Processing Error: $e\n');
      setState(() => errorMessage = 'Data Processing Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 287,
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: isLoading
              ? const Center(
            child: CircularProgressIndicator(),
          )
              : errorMessage != null
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 48,
                ),
                const SizedBox(height: 12),
                Text(
                  errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: fetchEnergyData,
                  child: const Text('Retry'),
                ),
              ],
            ),
          )
              : Column(
            children: [
              ///  TOP DROPDOWN ROW
              Row(
                children: [
                  // Building dropdown
                  Flexible(
                    flex: 2,
                    child: _buildDropdown(
                      value: selectedFloorLabel,
                      items: floors.map((f) => f['label'].toString()).toList(),
                      assetIcon: "assets/icons/icon2.png",
                      onChanged: (v) {
                        final selected = floors.firstWhere((f) => f['label'] == v);
                        setState(() {
                          selectedFloorLabel = v!;
                          selectedFloorId = selected['_id'];
                        });
                        fetchEnergyData(); // floor change hone par energy fetch
                      },
                      height: 36,
                    ),

                  ),
                  const SizedBox(width: 30),
                  // Date dropdown
                  IntrinsicWidth(
                    child: _buildDropdown(
                      value: selectedDate,
                      items: dates,
                      assetIcon: null,
                      onChanged: (v) {
                        setState(() => selectedDate = v!);
                        fetchEnergyData();
                      },
                      height: 36,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              ///  ENERGY + STATUS + CIRCLE
              Expanded(
                child: Row(
                  children: [
                    /// LEFT TEXT SIDE
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ENERGY CONSUMPTION',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 4),

                          Text(
                            '${totalEnergy.toStringAsFixed(2)} kWh',
                            style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 12),

                          Text(
                            'MAINTENANCE STATUS',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 4),

                          Text(
                            '$maintenanceCompleted/$maintenanceTotal',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          Text(
                            '(COMPLETED)',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 12),

                    /// RIGHT CIRCLE INDICATOR
                    CircularPercentIndicator(
                      radius: 55,
                      lineWidth: 12,
                      percent:
                      (percentage / 100).clamp(0.0, 1.0),
                      center: Text(
                        '${percentage.toStringAsFixed(1)}%',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      progressColor: percentage > 80
                          ? Colors.red
                          : Colors.green,
                      backgroundColor: Colors.green.shade100,
                      circularStrokeCap: CircularStrokeCap.round,
                      animation: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required String? assetIcon,
    required Function(String?) onChanged,
    required double height,
  }) {
    return PopupMenuButton<String>(
      offset: const Offset(0, 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 8,
      child: Container(
        height: height,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (assetIcon != null)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Image.asset(
                  assetIcon,
                  height: 18,
                  width: 18,
                  color: Colors.green,                 // <-- YOUR COLOR
                  colorBlendMode: BlendMode.srcIn,
                ),
              ),
            Flexible(
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down, size: 18),
          ],
        ),
      ),
      onSelected: onChanged,
      itemBuilder: (context) =>
          items.map((item) => PopupMenuItem(value: item, child: Text(item))).toList(),
    );
  }
}