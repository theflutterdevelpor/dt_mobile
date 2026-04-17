import 'package:dt_mobile/services/gas_services.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class CO2Chart extends StatefulWidget {
  final String deviceId;

  const CO2Chart({Key? key, required this.deviceId}) : super(key: key);

  @override
  State<CO2Chart> createState() => _CO2ChartState();
}

class _CO2ChartState extends State<CO2Chart> {
  List<ChartData> data = [];
  bool isLoading = false;

  String selectedFilter = "Today";
  final List<String> filterOptions = ["Today", "Yesterday", "Week", "30 Days","6 Month"];


  String dateFormat(DateTime date) =>
      "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

  Map<String, String> getDateRange(String filter) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    DateTime fromDate, toDate;

    switch (filter) {
      case 'Yesterday':
        final yesterday = today.subtract(const Duration(days: 1));
        fromDate = toDate = yesterday;
        break;
      case 'Week':
        fromDate = today.subtract(const Duration(days: 6));
        toDate = today;
        break;
      case '30 Days':
        fromDate = today.subtract(const Duration(days: 29));
        toDate = today;
        break;
      case 'Today':
      default:
        fromDate = toDate = today;
    }

    return {
      'fromDate': dateFormat(fromDate),
      'toDate': dateFormat(toDate),
    };
  }


  Future<void> loadCO2Data() async {
    setState(() => isLoading = true);

    final dates = getDateRange(selectedFilter);

    try {
      final response = await GasService.getHistory(
        deviceId: widget.deviceId,
        fromDate: dates['fromDate']!,
        toDate: dates['toDate']!,
      );

      if (!mounted) return;

      if (response == null || response.data == null || response.data!.isEmpty) {
        setState(() {
          data = [];
          isLoading = false;
        });
        return;
      }

      bool isHourly = selectedFilter == 'Today' || selectedFilter == 'Yesterday';

      final List<ChartData> chartData = response.data!.asMap().entries.map((entry) {
        final int i = entry.key;
        final item = entry.value;

        final double? co2 = item.co2?.toDouble();
        final String label = _buildLabel(item, i, isHourly);

        return ChartData(label, co2);
      }).toList();

      final validData = chartData.where((d) => d.co2 != null).toList();

      setState(() => data = validData);
    } catch (e, stackTrace) {
      debugPrint('CO2 chart error: $e');
      debugPrint('Stack trace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading CO₂ data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    setState(() => isLoading = false);
  }

  String _buildLabel(dynamic item, int index, bool isHourly) {
    try {
      final DateTime? dt = item.createdAt != null
          ? DateTime.tryParse(item.createdAt.toString())?.toLocal()
          : null;

      if (dt == null) return "—";

      if (isHourly) {
        final h = dt.hour.toString().padLeft(2, '0');
        final m = dt.minute.toString().padLeft(2, '0');
        return '$h:$m';
      } else {
        return "${_getMonthAbbr(dt.month)}-${dt.day.toString().padLeft(2, '0')}";
      }
    } catch (_) {
      return "Day ${index + 1}";
    }
  }

  String _getMonthAbbr(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }


  late ZoomPanBehavior _zoomPanBehavior;

  @override
  void initState() {
    super.initState();
    _zoomPanBehavior = ZoomPanBehavior(enablePanning: true, zoomMode: ZoomMode.x);
    loadCO2Data();
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
          loadCO2Data();
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

  Widget _buildChart() {
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
        minimum: 0,
        maximum: 0.1,
        interval: 0.025,
        labelFormat: '{value}',
        labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 11),
        axisLine: AxisLine(width: 1, color: Colors.grey.shade300),
        majorGridLines: MajorGridLines(
          width: 1,
          color: Colors.grey.shade300,
          dashArray: const [5, 5],
        ),
      ),
      series: <LineSeries<ChartData, String>>[
        LineSeries<ChartData, String>(
          dataSource: data,
          xValueMapper: (ChartData d, _) => d.time,
          yValueMapper: (ChartData d, _) => d.co2,
          color: const Color(0xFF6B7BFF),
          width: 2,

          markerSettings: const MarkerSettings(
            isVisible: true,
            height: 6,
            width: 6,
            shape: DataMarkerType.circle,
            borderWidth: 1,
            color: Color(0xFF6B7BFF),
          ),
        )
      ],
    );
  }

  Widget _buildLegend() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: const [
          _LegendDot("CO₂", Color(0xFF6B7BFF)),
        ],
      ),
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

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "CO₂ (PPM)",
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

            Expanded(
              child: isLoading
                  ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF6B7BFF)),
              )
                  : data.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inbox, size: 48, color: Colors.grey.shade400),
                    const SizedBox(height: 8),
                    Text(
                      "No CO₂ data available",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              )
                  : Row(
                children: [
                  RotatedBox(
                    quarterTurns: 3,
                    child: Text(
                      'CO₂ (PPM)',
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

            SizedBox(height: 30, child: _buildLegend()),
          ],
        ),
      ),
    );
  }
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
  ChartData(this.time, this.co2);
  final String time;
  final double? co2;
}