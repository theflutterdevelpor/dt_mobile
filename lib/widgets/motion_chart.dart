import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:dt_mobile/services/auth_services.dart';
import 'package:intl/intl.dart';

class MotionSensorChart extends StatefulWidget {
  final String deviceId;
  const MotionSensorChart({Key? key, required this.deviceId}) : super(key: key);

  @override
  State<MotionSensorChart> createState() => _MotionSensorChartState();
}

class _MotionSensorChartState extends State<MotionSensorChart> {
  List<ChartData> data = [];
  late TooltipBehavior _tooltip;
  bool isLoading = false;
  String errorMsg = '';

  final List<String> filterOptions = ["Today", "Yesterday", "Week", "30 Days","6 Month"];
  String selectedValue = "Today";

  @override
  void initState() {
    super.initState();
    _tooltip = TooltipBehavior(enable: true);
    fetchData();
  }

  Map<String, String> getDateRange(String filter) {
    final now = DateTime.now();
    final formatter = DateFormat('yyyy-MM-dd');
    DateTime from;
    DateTime to = now;

    switch (filter) {
      case "Yesterday":
        from = now.subtract(const Duration(days: 1));
        to = from;
        break;
      case "7 days":
        from = now.subtract(const Duration(days: 7));
        break;
      case "one month":
        from = DateTime(now.year, now.month - 1, now.day);
        break;
      case "6 month":
        from = DateTime(now.year, now.month - 6, now.day);
        break;
      case "Today":
      default:
        from = now;
        break;
    }

    return {
      'fromDate': formatter.format(from),
      'toDate': formatter.format(to),
    };
  }

  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
      errorMsg = '';
    });

    try {
      final range = getDateRange(selectedValue);

      final response = await ApiService.getRequest(
        '/org/motion-sensor?deviceId=${widget.deviceId}&fromDate=${range['fromDate']}&toDate=${range['toDate']}',
      );

      if (response['success'] == true) {
        final List rawData = response['data'] ?? [];

        if (rawData.isEmpty) {
          setState(() => data = []);
        } else {
          setState(() {
            data = rawData.map((item) {
              final time = item['time'] ?? item['timestamp'] ?? '';
              final motion = (item['motion'] ?? item['value'] ?? 0) as int;
              return ChartData(time.toString(), motion);
            }).toList();
          });
        }
      }
    } catch (e) {
      setState(() => errorMsg = 'Failed: $e');
    } finally {
      setState(() => isLoading = false);
    }
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
        height: screenHeight * 0.40,
        child: Card(
          color: Colors.white,
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title + Dropdown
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Motion Sensor\n(0-1)",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    _buildDropdown(),
                  ],
                ),
                const SizedBox(height: 20),

                // Chart
                Expanded(
                  child: isLoading
                      ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF6B5FFF),
                    ),
                  )
                      : errorMsg.isNotEmpty
                      ? Center(
                      child: Text(errorMsg,
                          style: const TextStyle(color: Colors.red)))
                      : data.isEmpty
                      ? const Center(
                      child: Text('No data available',
                          style: TextStyle(color: Colors.grey)))
                      : LayoutBuilder(
                    builder: (context, constraints) {
                      double chartWidth = constraints.maxWidth;
                      if (data.length > 12) {
                        chartWidth = data.length * 60.0;
                      }

                      return Row(
                        children: [
                          const SizedBox(
                            width: 40,
                            child: RotatedBox(
                              quarterTurns: 3,
                              child: Text('Motion',
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 40,
                            child: Stack(
                              children: [
                                CustomPaint(
                                  painter: YAxisPainter(),
                                  size: const Size(40, double.infinity),
                                ),
                                const Column(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment:
                                  CrossAxisAlignment.end,
                                  children: [
                                    Text('1',
                                        style: TextStyle(fontSize: 11)),
                                    Text('0',
                                        style: TextStyle(fontSize: 11)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: SizedBox(
                                width: chartWidth,
                                child: SfCartesianChart(
                                  plotAreaBorderWidth: 0,
                                  tooltipBehavior: _tooltip,
                                  primaryXAxis: CategoryAxis(
                                    labelStyle: const TextStyle(
                                        fontSize: 10,
                                        color: Colors.black87),
                                    majorGridLines:
                                    const MajorGridLines(width: 0),
                                    isVisible: true,
                                    interval: 1,
                                  ),
                                  primaryYAxis: NumericAxis(
                                    minimum: 0,
                                    maximum: 1,
                                    interval: 1,
                                    isVisible: false,
                                    majorGridLines: const MajorGridLines(
                                        width: 1,
                                        color: Color(0xFFE8E8E8)),
                                  ),
                                  series: <ScatterSeries<ChartData, String>>[
                                    ScatterSeries<ChartData, String>(
                                      name: 'Motion',
                                      dataSource: data,
                                      xValueMapper: (d, _) => d.time,
                                      yValueMapper: (d, _) => d.motion,
                                      markerSettings: const MarkerSettings(
                                        isVisible: true,
                                        height: 10,
                                        width: 10,
                                        shape: DataMarkerType.circle,
                                        color: Color(0xFF6B5FFF),
                                        borderColor: Color(0xFF6B5FFF),
                                        borderWidth: 1.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),

                const SizedBox(height: 16),

                const SizedBox(
                  height: 30,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _LegendDot("Motion", Color(0xFF6B5FFF)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class YAxisPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE8E8E8)
      ..strokeWidth = 1;
    canvas.drawLine(
        Offset(size.width - 2, 0), Offset(size.width - 2, size.height), paint);
  }

  @override
  bool shouldRepaint(YAxisPainter oldDelegate) => false;
}

class _LegendDot extends StatelessWidget {
  final String text;
  final Color color;
  const _LegendDot(this.text, this.color);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(fontSize: 11)),
      ],
    );
  }
}

class ChartData {
  ChartData(this.time, this.motion);
  final String time;
  final int motion;
}