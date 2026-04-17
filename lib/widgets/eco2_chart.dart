import 'package:dt_mobile/services/aqi_service.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ECo2Chart extends StatefulWidget {
  const ECo2Chart({Key? key}) : super(key: key);

  @override
  State<ECo2Chart> createState() => _ECo2ChartState();
}

class _ECo2ChartState extends State<ECo2Chart> {
  List<ChartData> data = [];
  bool isLoading = false;
  String? errorMessage;
  bool _isDisposed = false;

  late ZoomPanBehavior _zoomPanBehavior;

  final List<String> filterOptions = [
    "Today", "Yesterday", "Week", "30 Days", "6 Month"
  ];
  String selectedValue = "Today";

  @override
  void initState() {
    super.initState();
    _zoomPanBehavior = ZoomPanBehavior(
      enablePanning: true,
      zoomMode: ZoomMode.x,
    );
    _loadData(selectedValue);
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  Map<String, String> _getDateRange(String filter) {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    late DateTime from;
    late DateTime to = now;

    switch (filter) {
      case 'Today':
        from = todayStart;
        break;
      case 'Yesterday':
        from = todayStart.subtract(const Duration(days: 1));
        to = todayStart.subtract(const Duration(seconds: 1));
        break;
      case 'Week':
        from = now.subtract(const Duration(days: 6));
        break;
      case '30 Days':
        from = now.subtract(const Duration(days: 29));
        break;
      case '6 Month':
        from = DateTime(now.year, now.month - 6, now.day);
        break;
      default:
        from = todayStart;
    }

    String fmt(DateTime d) =>
        '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    return {'fromDate': fmt(from), 'toDate': fmt(to)};
  }

  int _getAutoScrollDelta() {
    switch (selectedValue) {
      case 'Today':
      case 'Yesterday':
        return data.length > 12 ? 12 : data.length;
      case 'Week':
        return data.length > 7 ? 7 : data.length;
      case '30 Days':
        return data.length > 10 ? 10 : data.length;
      case '6 Month':
        return data.length > 30 ? 30 : data.length;
      default:
        return 12;
    }
  }

  double _getXAxisInterval() {
    switch (selectedValue) {
      case 'Today':
      case 'Yesterday':
        return 1;
      case 'Week':
        return 1;
      case '30 Days':
        return 3;
      case '6 Month':
        return 10;
      default:
        return 1;
    }
  }

  Future<void> _loadData(String filter) async {
    if (!mounted || _isDisposed) return;
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final range = _getDateRange(filter);

      final response = await ApiService.fetchAqiAggregatedData(
        fromDate: range['fromDate']!,
        toDate: range['toDate']!,
        aggregated: true,
      );

      if (!mounted || _isDisposed) return;

      if (response.data.isEmpty) {
        setState(() {
          data = [];
          errorMessage = 'No data available for selected period';
        });
        return;
      }

      final validPoints = response.data
          .where((d) => d.avgCo2 != null)
          .toList();

      if (validPoints.isEmpty) {
        setState(() {
          data = [];
          errorMessage = 'No eCO2 data available for selected period.';
        });
        return;
      }

      validPoints.sort((a, b) => a.hour.compareTo(b.hour));

      setState(() {
        final Map<String, ChartData> uniqueData = {};

        for (var d in validPoints) {
          final dt = d.hour;
          String label;

          switch (filter) {
            case 'Today':
            case 'Yesterday':
              label = '${dt.hour.toString().padLeft(2, '0')}:00';
              break;
            case 'Week':
              const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
              label = days[dt.weekday - 1];
              break;
            case '30 Days':
              label = '${dt.day}/${dt.month}';
              break;
            case '6 Month':
              const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
              label = '${months[dt.month - 1]} ${dt.year}';
              break;
            default:
              label = '${dt.day}/${dt.month}';
          }

          if (uniqueData.containsKey(label)) {
            final avg = (uniqueData[label]!.value + d.avgCo2!) / 2;
            uniqueData[label] = ChartData(label, avg);
          } else {
            uniqueData[label] = ChartData(label, d.avgCo2!);
          }
        }

        if (!mounted || _isDisposed) return;

        data = uniqueData.values.toList();

        if (filter == 'Today' || filter == 'Yesterday') {
          data.sort((a, b) {
            final hourA = int.tryParse(a.time.split(':')[0]) ?? 0;
            final hourB = int.tryParse(b.time.split(':')[0]) ?? 0;
            return hourA.compareTo(hourB);
          });
        }
      });
    } catch (e) {
      if (mounted && !_isDisposed) {
        setState(() => errorMessage = 'Failed to load data: $e');
      }
    } finally {
      if (mounted && !_isDisposed) {
        setState(() => isLoading = false);
      }
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
          _loadData(val);
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
          elevation: 4,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ─── Header ───
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "eCo2 ppm",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    _buildDropdown(),
                  ],
                ),
                const SizedBox(height: 12),

                // ─── Body ───
                Expanded(
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : errorMessage != null
                      ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline,
                            color: Colors.red, size: 36),
                        const SizedBox(height: 8),
                        Text(errorMessage!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: Colors.red, fontSize: 13)),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () => _loadData(selectedValue),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                      : data.isEmpty
                      ? const Center(
                      child: Text('No data available',
                          style:
                          TextStyle(color: Colors.black45)))
                      : _buildChart(),
                ),

                const SizedBox(height: 8),

                // ─── Legend ───
                SizedBox(
                  height: 28,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      _LegendDot("eCo2 ppm", Color(0xFF4CAF50)),
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

  Widget _buildChart() {
    final maxVal =
    data.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    final yMax = ((maxVal * 1.2) / 10000).ceil() * 10000.0;
    final yInterval = yMax / 2;

    return SfCartesianChart(
      plotAreaBorderWidth: 0,
      zoomPanBehavior: _zoomPanBehavior,

      tooltipBehavior: TooltipBehavior(
        enable: true,
        activationMode: ActivationMode.singleTap,
        builder: (dynamic data, dynamic point, dynamic series,
            int pointIndex, int seriesIndex) {
          return Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 4)
              ],
            ),
            child: Text(
              '${data.time}\neCO2: ${data.value.toStringAsFixed(1)} ppm',
              style: const TextStyle(fontSize: 12, color: Colors.black87),
            ),
          );
        },
      ),

      primaryXAxis: CategoryAxis(
        autoScrollingDelta: _getAutoScrollDelta(),
        autoScrollingMode: AutoScrollingMode.start,
        interval: _getXAxisInterval(),
        labelRotation: -45,
        majorGridLines: const MajorGridLines(width: 0),
        axisLine: const AxisLine(color: Colors.black26, width: 1),
        labelStyle:
        const TextStyle(fontSize: 10, color: Colors.black87),
        edgeLabelPlacement: EdgeLabelPlacement.shift,
      ),

      primaryYAxis: NumericAxis(
          minimum: 0,
          maximum: 20000,
          interval: 10000,
        axisLabelFormatter: (AxisLabelRenderDetails details) {
          final val = details.value;
          final label = val >= 1000
              ? '${(val / 1000).toStringAsFixed(0)}k'
              : val.toStringAsFixed(0);
          return ChartAxisLabel(label, details.textStyle);
        },
        title: AxisTitle(
          text: 'eCo2 ppm',
          textStyle:
          const TextStyle(fontSize: 11, color: Colors.black54),
        ),
        majorGridLines: const MajorGridLines(
          width: 1,
          dashArray: [5, 5],
          color: Colors.black12,
        ),
        axisLine: const AxisLine(color: Colors.black26, width: 1),
        labelStyle:
        const TextStyle(fontSize: 10, color: Colors.black87),
      ),

      series: <CartesianSeries<ChartData, String>>[
        LineSeries<ChartData, String>(
          name: 'eCo2 ppm',
          dataSource: data,
          xValueMapper: (ChartData d, _) => d.time,
          yValueMapper: (ChartData d, _) => d.value,
          color: const Color(0xFF4CAF50), // ✅ green color jaise pic mein
          width: 2,
          markerSettings: const MarkerSettings(
            isVisible: true,
            height: 7,
            width: 7,
            shape: DataMarkerType.circle,
            color: Color(0xFF4CAF50),
            borderColor: Colors.white,
            borderWidth: 2,
          ),
          enableTooltip: true,
          animationDuration: 800,
        ),
      ],
    );
  }
}

// ─── Legend ───
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
        Text(text,
            style: const TextStyle(fontSize: 11, color: Colors.black87)),
      ],
    );
  }
}

class ChartData {
  final String time;
  final double value;
  ChartData(this.time, this.value);
}