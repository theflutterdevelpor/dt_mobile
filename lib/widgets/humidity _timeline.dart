import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class HumidityTimeline extends StatefulWidget {
  const HumidityTimeline({Key? key}) : super(key: key);

  @override
  State<HumidityTimeline> createState() => _HumidityTimelineState();
}

class _HumidityTimelineState extends State<HumidityTimeline> {
  late List<ChartData> data;
  late TooltipBehavior _tooltip;

  final List<String> filterOptions = [
    "Today", "Yesterday", "Week", "30 Days"
  ];

  String selectedValue = "Today";

  @override
  void initState() {
    super.initState();
    data = _getDataForFilter("Today");
    _tooltip = TooltipBehavior(enable: true);
  }

  List<ChartData> _getDataForFilter(String filter) {
    switch (filter) {
      case "Today":
        return [
          ChartData("00:00", 65.5), ChartData("01:00", 67.8),
          ChartData("02:00", 68.2), ChartData("03:00", 69.5),
          ChartData("04:00", 70.0), ChartData("05:00", 71.8),
          ChartData("06:00", 70.5), ChartData("07:00", 68.0),
          ChartData("08:00", 65.5), ChartData("09:00", 62.0),
          ChartData("10:00", 58.5), ChartData("11:00", 55.5),
          ChartData("12:00", 52.0), ChartData("13:00", 50.5),
          ChartData("14:00", 49.0), ChartData("15:00", 48.8),
          ChartData("16:00", 49.5), ChartData("17:00", 52.0),
          ChartData("18:00", 55.0), ChartData("19:00", 58.0),
          ChartData("20:00", 60.0), ChartData("21:00", 62.0),
          ChartData("22:00", 63.5), ChartData("23:00", 64.5),
        ];

      case "Yesterday":
        return [
          ChartData("00:00", 64.0), ChartData("01:00", 65.5),
          ChartData("02:00", 66.0), ChartData("03:00", 67.5),
          ChartData("04:00", 68.0), ChartData("05:00", 69.5),
          ChartData("06:00", 68.0), ChartData("07:00", 66.5),
          ChartData("08:00", 64.0), ChartData("09:00", 61.0),
          ChartData("10:00", 57.5), ChartData("11:00", 54.0),
          ChartData("12:00", 51.5), ChartData("13:00", 49.0),
          ChartData("14:00", 48.0), ChartData("15:00", 47.5),
          ChartData("16:00", 48.0), ChartData("17:00", 51.0),
          ChartData("18:00", 54.0), ChartData("19:00", 57.0),
          ChartData("20:00", 59.0), ChartData("21:00", 61.0),
          ChartData("22:00", 62.5), ChartData("23:00", 63.5),
        ];

      case "Week":
        return [
          ChartData("Mon", 62.5), ChartData("Tue", 60.0),
          ChartData("Wed", 58.0), ChartData("Thu", 55.5),
          ChartData("Fri", 53.0), ChartData("Sat", 51.0),
          ChartData("Sun", 52.5),
        ];

      case "30 Days":
        final now = DateTime.now();
        return List.generate(30, (index) {
          final date = now.subtract(Duration(days: 29 - index));
          final dayFormat = DateFormat('dd/MM');
          double baseTemp = 60.0;
          double humidity = baseTemp -
              (index % 7) * 2.5 +
              (index % 3) * 1.5;
          return ChartData(dayFormat.format(date), humidity);
        });

      default:
        return [];
    }
  }

  void _updateData(String filter) {
    setState(() {
      selectedValue = filter;
      data = _getDataForFilter(filter);
    });
  }

  Widget _buildDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
        color: Colors.grey.shade100,
      ),
      child: PopupMenuButton<String>(
        padding: EdgeInsets.zero,
        color: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              selectedValue,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down, size: 18, color: Colors.black54),
          ],
        ),
        onSelected: (val) => _updateData(val),
        itemBuilder: (context) => filterOptions
            .map((choice) => PopupMenuItem<String>(
          value: choice,
          child: Text(
            choice,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ))
            .toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Center(
      child: SizedBox(
        width: screenWidth * 0.95,
        height: screenHeight * 0.45,
        child: Card(
          color: Colors.white,
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Humidity Trend",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    _buildDropdown(),
                  ],
                ),
                const SizedBox(height: 30),
                Expanded(
                  child: Row(
                    children: [
                      SizedBox(
                        width: 35,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            RotatedBox(
                              quarterTurns: 3,
                              child: const Text(
                                "Humidity (%)",
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: SizedBox(
                            width: selectedValue == "Today" || selectedValue == "Yesterday"
                                ? 1200
                                : (selectedValue == "Week" ? 600 : 900),
                            height: 250,
                            child: SfCartesianChart(
                              tooltipBehavior: _tooltip,
                              plotAreaBorderWidth: 0,
                              margin: const EdgeInsets.only(right: 10),
                              primaryXAxis: CategoryAxis(
                                majorGridLines: const MajorGridLines(width: 0),
                                axisLine: const AxisLine(width: 1, color: Colors.black26),
                                labelStyle: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.black54,
                                ),
                                labelRotation: selectedValue == "Today" || selectedValue == "Yesterday"
                                    ? 45
                                    : (selectedValue == "30 Days" ? 90 : 0),
                                interval: selectedValue == "30 Days" ? 5 : 1,
                              ),
                              primaryYAxis: NumericAxis(
                                minimum: 30,
                                maximum: 80,
                                interval: 10,
                                labelStyle: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.black54,
                                ),
                                majorGridLines: const MajorGridLines(
                                  width: 1,
                                  color: Colors.black12,
                                ),
                                axisLine: const AxisLine(width: 1, color: Colors.black26),
                              ),
                              series: [
                                LineSeries<ChartData, String>(
                                  dataSource: data,
                                  xValueMapper: (d, _) => d.category,
                                  yValueMapper: (d, _) => d.value,
                                  name: "Humidity",
                                  color: Colors.blue,
                                  width: 2,
                                  markerSettings: const MarkerSettings(
                                    isVisible: true,
                                    shape: DataMarkerType.circle,
                                    color: Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      "Humidity (%)",
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ChartData {
  ChartData(this.category, this.value);
  final String category;
  final double value;
}