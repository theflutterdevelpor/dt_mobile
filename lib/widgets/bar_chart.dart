import 'package:dt_mobile/services/energy_services.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class barchart extends StatefulWidget {
  const barchart({Key? key}) : super(key: key);

  @override
  State<barchart> createState() => _BarChartState();
}

class _BarChartState extends State<barchart> {
  List<ChartData> data = [];
  bool isLoading = false;
  late TooltipBehavior _tooltip;
  final List<String> filterOptions = [
    "Today",
    "Yesterday",
    "Week",
    "30 Days",
    "6 Months",
  ];

  String selectedValue = "Today";

  String dateFormat(DateTime date) =>
      "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

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
        fromDate = now.subtract(Duration(days: 1));
        toDate = now.subtract(Duration(days: 1));
        break;

      case 'Week':
        fromDate = now.subtract(Duration(days: 6));
        toDate = now;
        break;

      case '30 Days':
        fromDate = now.subtract(Duration(days: 29));
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
      'fromDate': dateFormat(fromDate),
      'toDate': dateFormat(toDate),
    };
  }

  Future<void> loadEnergyData() async {
    setState(() => isLoading = true);

    final dates = getDateRange(selectedValue);

    try {
      Map<String, dynamic> response;


      if (selectedValue == 'Today' || selectedValue == 'Yesterday') {
        response = await EnergyService.fetchEnergyHourly(
          date: dates['fromDate']!,
        );
      } else {
        response = await EnergyService.fetchEnergy(
          fromDate: dates['fromDate']!,
          toDate: dates['toDate']!,
        );
      }

      final apiData = response['data'];
      debugPrint(" API CALL STARTED");
      debugPrint("Filter: $selectedValue");


      final phase1List = (apiData['phaseOneData'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      final phase2List = (apiData['phaseTwoData'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      final phase3List = (apiData['phaseThreeData'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      final threePhaseList = (apiData['threePhaseData'] as List?)?.cast<Map<String, dynamic>>() ?? [];


      bool isHourly = phase1List.isNotEmpty && phase1List[0].containsKey('hour');

      debugPrint("Is Hourly: $isHourly");
      debugPrint("Phase 1 length: ${phase1List.length}");


      final maxLength = [phase1List.length, phase2List.length, phase3List.length, threePhaseList.length]
          .reduce((a, b) => a > b ? a : b);


      List<ChartData> chartData = [];
      for (int i = 0; i < maxLength; i++) {
        final phase1 = _getEnergyFromList(phase1List, i, isHourly);
        final phase2 = _getEnergyFromList(phase2List, i, isHourly);
        final phase3 = _getEnergyFromList(phase3List, i, isHourly);
        final threePhase = _getEnergyFromList(threePhaseList, i, isHourly);

        String label = "Day ${i + 1}";

        if (isHourly) {

          if (i < phase1List.length) {
            final hour = phase1List[i]['hour'] ?? i;
            label = "$hour-${(hour + 1) % 24}";
          }
        } else {

          if (i < phase1List.length) {
            final dateStr = phase1List[i]['date']?.toString().split('T')[0] ?? "Day ${i + 1}";

            final parts = dateStr.split('-');
            if (parts.length == 3) {
              final month = _getMonthAbbr(int.parse(parts[1]));
              label = "$month-${parts[2]}";
            } else {
              label = dateStr;
            }
          }
        }

        chartData.add(ChartData(label, phase1, phase2, phase3, threePhase));
      }

      data = chartData;
      debugPrint("✅ Chart data loaded: ${data.length} entries");
    } catch (e) {
      debugPrint('❌ API ERROR: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }

    setState(() => isLoading = false);
  }


  double _getEnergyFromList(List<Map<String, dynamic>> list, int index, bool isHourly) {
    try {
      if (index < list.length) {
        final energy = isHourly
            ? list[index]['sumOfEnergyPerHour']  // Hourly
            : list[index]['dailySumOfEnergy'];    // Daily
        return (energy ?? 0).toDouble();
      }
      return 0.0;
    } catch (e) {
      debugPrint('Error extracting energy at index $index: $e');
      return 0.0;
    }
  }

  // ✅ Month abbreviation helper
  String _getMonthAbbr(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  @override
  void initState() {
    _tooltip = TooltipBehavior(enable: true);
    loadEnergyData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SizedBox(
          width: screenWidth * 0.95,
          height: screenHeight * 0.55,
          child: Card(
            color: Colors.white,
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ///  TITLE + DROPDOWN
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.bolt, color: Colors.green),
                          SizedBox(width: 6),
                          Text(
                            "Energy",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 6),
                          Text(
                            "(KWh)",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),

                      /// DROPDOWN
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black12),
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white,
                        ),
                        child: PopupMenuButton<String>(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                selectedValue,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const Icon(Icons.keyboard_arrow_down, size: 20),
                            ],
                          ),
                          onSelected: (String value) {
                            setState(() {
                              selectedValue = value;
                            });
                            loadEnergyData();
                          },
                          itemBuilder: (BuildContext context) {
                            return filterOptions.map((String choice) {
                              return PopupMenuItem<String>(
                                value: choice,
                                child: Text(
                                  choice,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              );
                            }).toList();
                          },
                          padding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),


                  Expanded(
                    child: isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : data.isEmpty
                        ? const Center(child: Text("No data available"))
                        : Stack(
                      children: [
                        // Fixed Y-Axis background
                        Positioned(
                          left: 0,
                          top: 0,
                          bottom: 0,
                          width: 50,
                          child: Container(
                            color: Colors.white,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: List.generate(
                                6,
                                    (index) {
                                  final isHourly = selectedValue == 'Today' || selectedValue == 'Yesterday';
                                  final maxValue = isHourly ? 25 : 250;
                                  final interval = isHourly ? 5 : 50;
                                  final value = maxValue - (index * interval);
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: Text(
                                      value.toStringAsFixed(0),
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Colors.black,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                        // Scrollable chart with transparent Y-axis
                        Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: SizedBox(
                              width: data.length * 50.0,
                              child: SfCartesianChart(
                                tooltipBehavior: _tooltip,
                                primaryXAxis: CategoryAxis(
                                  labelRotation: -45,
                                ),
                                primaryYAxis: NumericAxis(
                                  minimum: 0,
                                  maximum: selectedValue == 'Today' || selectedValue == 'Yesterday' ? 25 : 250,
                                  interval: selectedValue == 'Today' || selectedValue == 'Yesterday' ? 5 : 50,
                                  majorGridLines: const MajorGridLines(
                                    dashArray: [5, 5],
                                    color: Colors.grey,
                                  ),
                                  axisLine: const AxisLine(width: 0),
                                  labelStyle: const TextStyle(
                                    color: Colors.transparent,
                                  ),
                                ),
                                series: <CartesianSeries>[
                                  _barSeries(Colors.teal, (d) => d.phase1, "Phase 1"),
                                  _barSeries(Color(0xFF4169E1), (d) => d.phase2, "Phase 2"),
                                  _barSeries(Colors.green, (d) => d.phase3, "Phase 3"),
                                  _barSeries(Color(0xFFff8c42), (d) => d.phase4, "Three Phase"),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  ///  FIXED LEGEND
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: const [
                      _LegendDot("Phase 1", Colors.teal),
                      _LegendDot("Phase 2", Color(0xFF4169E1)),
                      _LegendDot("Phase 3", Colors.green),
                      _LegendDot("Three Phase", Color(0xFFff8c42)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  ColumnSeries<ChartData, String> _barSeries(
      Color color,
      double Function(ChartData) mapper,
      String name,
      ) {
    return ColumnSeries<ChartData, String>(
      dataSource: data,
      xValueMapper: (d, _) => d.month,
      yValueMapper: (d, _) => mapper(d),
      name: name,
      color: color,
      borderRadius: BorderRadius.circular(4),
    );
  }
}

///  LEGEND DOT
class _LegendDot extends StatelessWidget {
  final String text;
  final Color color;

  const _LegendDot(this.text, this.color);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(radius: 5, backgroundColor: color),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}


class ChartData {
  ChartData(this.month, this.phase1, this.phase2, this.phase3, this.phase4);

  final String month;
  final double phase1;
  final double phase2;
  final double phase3;
  final double phase4;
}