import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class TempTimeline extends StatefulWidget {
  const TempTimeline({Key? key}) : super(key: key);

  @override
  State<TempTimeline> createState() => _TempTimelineState();
}

class _TempTimelineState extends State<TempTimeline> {
  late List<ChartData> data;
  late TooltipBehavior _tooltip;

  final List<String> filterOptions = [
    "Today", "Yesterday", "Week",  "30 Days"
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
          ChartData("0:00", 22.5), ChartData("1:00", 21.8),
          ChartData("2:00", 21.2), ChartData("3:00", 20.5),
          ChartData("4:00", 20.0), ChartData("5:00", 19.8),
          ChartData("6:00", 20.5), ChartData("7:00", 22.0),
          ChartData("8:00", 24.5), ChartData("9:00", 26.0),
          ChartData("10:00", 27.5), ChartData("11:00", 28.5),
          ChartData("12:00", 29.0), ChartData("13:00", 29.5),
          ChartData("14:00", 30.0), ChartData("15:00", 29.8),
          ChartData("16:00", 29.0), ChartData("17:00", 28.0),
          ChartData("18:00", 27.0), ChartData("19:00", 26.0),
          ChartData("20:00", 25.0), ChartData("21:00", 24.0),
          ChartData("22:00", 23.0), ChartData("23:00", 22.5),
        ];

      case "Yesterday":
        return [
          ChartData("0:00", 23.0), ChartData("1:00", 22.5),
          ChartData("2:00", 22.0), ChartData("3:00", 21.5),
          ChartData("4:00", 21.0), ChartData("5:00", 20.5),
          ChartData("6:00", 21.0), ChartData("7:00", 22.5),
          ChartData("8:00", 25.0), ChartData("9:00", 27.0),
          ChartData("10:00", 28.5), ChartData("11:00", 29.0),
          ChartData("12:00", 29.5), ChartData("13:00", 30.0),
          ChartData("14:00", 30.5), ChartData("15:00", 30.0),
          ChartData("16:00", 29.5), ChartData("17:00", 28.5),
          ChartData("18:00", 27.5), ChartData("19:00", 26.5),
          ChartData("20:00", 25.5), ChartData("21:00", 24.5),
          ChartData("22:00", 23.5), ChartData("23:00", 23.0),
        ];

      case "Week":
        return [
          ChartData("Mon", 24.5), ChartData("Tue", 25.0),
          ChartData("Wed", 26.0), ChartData("Thu", 25.5),
          ChartData("Fri", 27.0), ChartData("Sat", 28.0),
          ChartData("Sun", 27.5),
        ];

      case "30 Days":
        final now = DateTime.now();
        return List.generate(30, (index) {
          final date = now.subtract(Duration(days: 29 - index));
          final dayFormat = DateFormat('dd/MM');
          double baseTemp = 24.0;
          double temp = baseTemp +
              (index % 7) * 0.8 +
              (index % 3) * 0.3;
          return ChartData(dayFormat.format(date), temp);
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
                      "Temperature Trend",
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
                                "Temperature (°C)",
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
                            minimum: 15,
                            maximum: 35,
                            interval: 5,
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
                              name: "Temperature",
                              color: Colors.green,
                              width: 2,
                              markerSettings: const MarkerSettings(
                                isVisible: true,
                                shape: DataMarkerType.circle,
                                color: Colors.green,
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
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      "Temperature (°C)",
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