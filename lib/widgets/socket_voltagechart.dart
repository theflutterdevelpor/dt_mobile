import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class SocketVoltageChart extends StatefulWidget {
  const SocketVoltageChart({Key? key}) : super(key: key);

  @override
  State<SocketVoltageChart> createState() => _SocketVoltageChartState();
}

class _SocketVoltageChartState extends State<SocketVoltageChart> {
  late List<ChartData> data;
  late TooltipBehavior _tooltip;

  final List<String> filterOptions = [
    "Today", "Yesterday", "Week", "30 Days", "6 Month"
  ];

  String selectedValue = "Today";

  @override
  void initState() {
    super.initState();

    data = [
      ChartData("0", 230),
      ChartData("1", 235),
      ChartData("2", 5),
      ChartData("3", 8),
      ChartData("4", 230),
    ];

    _tooltip = TooltipBehavior(enable: true);
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
        onSelected: (val) {
          setState(() => selectedValue = val);
        },
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
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title + Dropdown Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Socket Voltage\n(V)",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        height: 1.4,
                      ),
                    ),
                    _buildDropdown(),
                  ],
                ),

                const SizedBox(height: 16),

                // Chart Area
                Expanded(
                  child: Row(
                    children: [
                      // Y-axis label
                      SizedBox(
                        width: 32,
                        child: Center(
                          child: RotatedBox(
                            quarterTurns: 3,
                            child: const Text(
                              "Voltage (V)",
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w400,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Line Chart
                      Expanded(
                        child: SfCartesianChart(
                          tooltipBehavior: _tooltip,
                          plotAreaBorderWidth: 0,
                          margin: const EdgeInsets.only(right: 8),
                          primaryXAxis: CategoryAxis(
                            majorGridLines: const MajorGridLines(width: 0),
                            axisLine: const AxisLine(width: 1, color: Colors.black26),
                            labelStyle: const TextStyle(
                              fontSize: 11,
                              color: Colors.black54,
                            ),
                          ),
                          primaryYAxis: NumericAxis(
                            minimum: 0,
                            maximum: 500,
                            interval: 250,
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
                              name: "Socket Voltage",
                              color: const Color(0xFF4CAF8C), // Green color like image
                              width: 2,
                              markerSettings: const MarkerSettings(
                                isVisible: true,
                                shape: DataMarkerType.circle,
                                width: 8,
                                height: 8,
                                color: Colors.white,
                                borderWidth: 2,
                                borderColor: Color(0xFF4CAF8C),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // Legend
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Transform.rotate(
                      angle: 0.785,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFF4CAF8C),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      "Socket Voltage",
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