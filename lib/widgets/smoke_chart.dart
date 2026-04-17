import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class SmokeChart extends StatefulWidget {
  const SmokeChart({Key? key}) : super(key: key);

  @override
  State<SmokeChart> createState() => _SmokeChartState();
}

class _SmokeChartState extends State<SmokeChart> {
  late List<ChartData> data;
  late TooltipBehavior _tooltip;

  final List<String> filterOptions = ["Today", "Yesterday", "Week", "30 Days","6 Month"];
  String selectedValue = "Today";

  @override
  void initState() {
    super.initState();
    _tooltip = TooltipBehavior(enable: true);

    data = [
      ChartData('0', 2.6),
      ChartData('1', 3.0),
      ChartData('2', 2.0),
      ChartData('3', 2.0),
      ChartData('4', 2.0),
      ChartData('5', 2.0),
      ChartData('6', 3.0),
    ];
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
          height: screenHeight * 0.55,
          child: Card(
            color: Colors.white,
            elevation: 4,
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
                        "Smoke\n(PPM)",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // DROPDOWN
                      _buildDropdown()
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Chart with Fixed Y-Axis
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        double chartWidth = constraints.maxWidth;

                        if (data.length > 12) {
                          chartWidth = data.length * 60.0;
                        }

                        return Row(
                          children: [
                            // Y-Axis Label
                            const SizedBox(
                              width: 40,
                              child: RotatedBox(
                                quarterTurns: 3,
                                child: Text(
                                  'Smoke (PPM)',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Fixed Y-Axis
                            SizedBox(
                              width: 40,
                              child: Stack(
                                children: [
                                  CustomPaint(
                                    painter: YAxisPainter(),
                                    size: const Size(40, double.infinity),
                                  ),
                                  const Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text('4', style: TextStyle(fontSize: 11)),
                                      Text('3', style: TextStyle(fontSize: 11)),
                                      Text('2', style: TextStyle(fontSize: 11)),
                                      Text('1', style: TextStyle(fontSize: 11)),
                                      Text('0', style: TextStyle(fontSize: 11)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            // Scrollable Chart
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
                                        color: Colors.black87,
                                      ),
                                      majorGridLines: const MajorGridLines(width: 0),
                                      labelRotation: 0,
                                      isVisible: true,
                                      interval: 1,
                                    ),
                                    primaryYAxis: NumericAxis(
                                      minimum: 0,
                                      maximum: 4,
                                      interval: 1,
                                      labelFormat: '{value}',
                                      isVisible: false,
                                      majorGridLines: const MajorGridLines(width: 1, color: Color(0xFFE8E8E8)),
                                    ),
                                    series: <LineSeries<ChartData, String>>[
                                      LineSeries<ChartData, String>(
                                        name: 'Smoke',
                                        dataSource: data,
                                        xValueMapper: (d, _) => d.time,
                                        yValueMapper: (d, _) => d.smoke,
                                        color: const Color(0xFFFFA500),
                                        width: 2.5,
                                        markerSettings: const MarkerSettings(
                                          isVisible: true,
                                          height: 8,
                                          width: 8,
                                          shape: DataMarkerType.circle,
                                          borderColor: Color(0xFFFFA500),
                                          borderWidth: 2,
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

                  // Legend
                  SizedBox(
                    height: 30,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        _LegendDot("Smoke", Color(0xFFFFA500)),
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

    canvas.drawLine(Offset(size.width - 2, 0), Offset(size.width - 2, size.height), paint);
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
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(fontSize: 11)),
      ],
    );
  }
}

class ChartData {
  ChartData(this.time, this.smoke);
  final String time;
  final double smoke;
}