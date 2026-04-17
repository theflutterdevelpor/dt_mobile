import 'package:dt_mobile/models/response/tempreture_response.dart';
import 'package:dt_mobile/services/temp_service.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class TemperatureChart extends StatefulWidget {
  final String deviceId;

  const TemperatureChart({
    Key? key,
    required this.deviceId,
  }) : super(key: key);

  @override
  State<TemperatureChart> createState() => _TemperatureChartState();
}

class _TemperatureChartState extends State<TemperatureChart> {
  List<ChartData> chartData = [];
  bool isLoading = false;

  String selectedFilter = "Today";
  final List<String> filterOptions = ["Today", "Yesterday", "Week", "30 Days","6 Month"];

  late ZoomPanBehavior _zoomPanBehavior;

  @override
  void initState() {
    super.initState();
    _zoomPanBehavior = ZoomPanBehavior(enablePanning: true, zoomMode: ZoomMode.x);
    _fetchData();
  }

  Map<String, DateTime> _getDateRange() {
    final now = DateTime.now();
    late DateTime from;

    switch (selectedFilter) {
      case "Week":
        from = now.subtract(const Duration(days: 7));
        break;
      case "Month":
        from = now.subtract(const Duration(days: 30));
        break;
      case "Yesterday":
        final yesterday = now.subtract(const Duration(days: 1));
        from = DateTime(yesterday.year, yesterday.month, yesterday.day);
        break;
      case "Today":
      default:
        from = DateTime(now.year, now.month, now.day);
        break;
    }

    return {"fromDate": from, "toDate": now};
  }

  Future<void> _fetchData() async {
    setState(() {
      isLoading = true;
      chartData = [];
    });

    try {
      final dates = _getDateRange();

      final TemperatureHistoryResponse? response =
      await TemperatureService.getHistory(
        deviceId: widget.deviceId,
        fromDate: dates['fromDate']!,
        toDate: dates['toDate']!,
      );

      if (!mounted) return;

      if (response != null && response.success && response.data.isNotEmpty) {
        chartData = response.data.map((TemperatureHistoryItem item) {
          return ChartData(_formatTime(item.createdAt), item.temperature);
        }).toList();
      }
    } catch (e, stackTrace) {
      debugPrint('Stack trace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading temperature data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    setState(() => isLoading = false);
  }

  String _formatTime(DateTime dt) {
    final local = dt.toLocal();
    final h = local.hour.toString().padLeft(2, '0');
    final m = local.minute.toString().padLeft(2, '0');
    return '$h:$m';
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
              selectedFilter,
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
          setState(() => selectedFilter = val);
          _fetchData();
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

  Widget _buildLegend() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children:  [
          _LegendDot("Temperature", Color(0xFFFF8A00)),
        ],
      ),
    );
  }

  Widget _buildChart() {
    final temps = chartData.map((e) => e.temp).toList();
    final double dataMin = temps.isEmpty ? 0 : temps.reduce((a, b) => a < b ? a : b);
    final double dataMax = temps.isEmpty ? 100 : temps.reduce((a, b) => a > b ? a : b);
    final double yMin = (dataMin - 5).clamp(0.0, double.infinity);
    final double yMax = dataMax + 5;

    return SfCartesianChart(
      plotAreaBorderWidth: 0,
      backgroundColor: Colors.white,
      zoomPanBehavior: _zoomPanBehavior,
      primaryXAxis: CategoryAxis(
        labelStyle: TextStyle(fontSize: 11, color: Colors.grey.shade600),
        majorGridLines: const MajorGridLines(width: 0),
        axisLine: AxisLine(width: 1, color: Colors.grey.shade300),
        autoScrollingDelta: 6,
        autoScrollingMode: AutoScrollingMode.start,
      ),
      primaryYAxis: NumericAxis(
        minimum: yMin,
        maximum: yMax,
        interval: (yMax - yMin) / 3,
        labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 11),
        axisLine: AxisLine(width: 1, color: Colors.grey.shade300),
        majorGridLines: MajorGridLines(
          width: 1,
          color: Colors.grey.shade200,
          dashArray: const [5, 5],
        ),
      ),
      series: <LineSeries<ChartData, String>>[
        LineSeries<ChartData, String>(
          name: 'Temperature',
          dataSource: chartData,
          xValueMapper: (d, _) => d.time,
          yValueMapper: (d, _) => d.temp,
          color: const Color(0xFFFF8A00),
          width: 2.5,
          markerSettings: const MarkerSettings(
            isVisible: true,
            height: 7,
            width: 7,
            shape: DataMarkerType.circle,
            color: Color(0xFFFF8A00),
            borderColor: Color(0xFFFF8A00),
            borderWidth: 1,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 4,
      shadowColor: Colors.black,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Temperature (°C)",
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _buildDropdown(),
              ],
            ),

            const SizedBox(height: 16),

            // ── Chart Area ──
            Expanded(
              child: isLoading
                  ? const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFFFF8A00),
                ),
              )
                  : chartData.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inbox,
                        size: 48, color: Colors.grey.shade400),
                    const SizedBox(height: 8),
                    Text(
                      "No temperature data available",
                      style: TextStyle(
                          fontSize: 16, color: Colors.grey.shade500),
                    ),
                  ],
                ),
              )
                  : Row(
                children: [
                  RotatedBox(
                    quarterTurns: 3,
                    child: Text(
                      'Temperature (°C)',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Expanded(child: _buildChart()),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ── Legend ──
            SizedBox(height: 30, child: _buildLegend()),
          ],
        ),
      ),
    );
  }
}

// ─── Supporting Classes ───────────────────────────────────────────────────

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
        const SizedBox(width: 5),
        Text(
          text,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
        ),
      ],
    );
  }
}

class ChartData {
  ChartData(this.time, this.temp);
  final String time;
  final double temp;
}