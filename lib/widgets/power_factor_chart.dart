import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../services/energy_services.dart';

class PowerFactorChart extends StatefulWidget {
  const PowerFactorChart({Key? key}) : super(key: key);

  @override
  State<PowerFactorChart> createState() => _PowerFactorChartState();
}

class _PowerFactorChartState extends State<PowerFactorChart> {
  List<ChartData> data = [];
  bool isLoading = false;

  String selectedFilter = "Today";
  final List<String> filterOptions = ["Today", "Yesterday", "Week", "30 Days", "6 Months"];

  String dateFormat(DateTime date) =>
      "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

  Map<String, String> getDateRange(String dateFilter) {
    DateTime today = DateTime.now();
    DateTime now = DateTime(today.year, today.month, today.day);
    DateTime fromDate, toDate;

    switch (dateFilter) {
      case 'Today':
        fromDate = toDate = now;
        break;
      case 'Yesterday':
        fromDate = toDate = now.subtract(const Duration(days: 1));
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
        fromDate = DateTime(now.year, now.month - 6, now.day);
        toDate = now;
        break;
      default:
        fromDate = toDate = now;
    }

    return {
      'fromDate': dateFormat(fromDate),
      'toDate': dateFormat(toDate),
    };
  }

  Future<void> loadPowerFactorData() async {
    setState(() => isLoading = true);

    final dates = getDateRange(selectedFilter);

    try {
      Map<String, dynamic> response;

      if (selectedFilter == 'Today' || selectedFilter == 'Yesterday') {
        response = await EnergyService.fetchEnergyHourly(date: dates['fromDate']!);
      } else {
        response = await EnergyService.fetchEnergy(
          fromDate: dates['fromDate']!,
          toDate: dates['toDate']!,
        );
      }

      if (!mounted) return;

      final apiData = response['data'];
      final phase1List = (apiData['phaseOneData'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      final phase2List = (apiData['phaseTwoData'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      final phase3List = (apiData['phaseThreeData'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      final threePhaseList = (apiData['threePhaseData'] as List?)?.cast<Map<String, dynamic>>() ?? [];

      bool isHourly = phase1List.isNotEmpty && phase1List[0].containsKey('hour');

      final maxLength = [
        phase1List.length,
        phase2List.length,
        phase3List.length,
        threePhaseList.length,
      ].reduce((a, b) => a > b ? a : b);

      List<ChartData> chartData = [];

      for (int i = 0; i < maxLength; i++) {
        final phase1 = _getPowerFactorFromList(phase1List, i, isHourly);
        final phase2 = _getPowerFactorFromList(phase2List, i, isHourly);
        final phase3 = _getPowerFactorFromList(phase3List, i, isHourly);
        final threePhase = _getPowerFactorFromList(threePhaseList, i, isHourly);

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
            label = parts.length == 3
                ? "${_getMonthAbbr(int.parse(parts[1]))}-${parts[2]}"
                : dateStr;
          }
        }

        chartData.add(ChartData(label, phase1, phase2, phase3, threePhase));
      }

      setState(() => data = chartData);
    } catch (e, stackTrace) {
      debugPrint('Stack trace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading power factor data: $e'), backgroundColor: Colors.red),
        );
      }
    }

    setState(() => isLoading = false);
  }

  double? _getPowerFactorFromList(List<Map<String, dynamic>> list, int index, bool isHourly) {
    try {
      if (index < list.length) {
        final item = list[index];
        final pf = isHourly
            ? (item['avgPowerFactorPerHour'] ?? item['avgPowerFactor'] ?? item['powerFactor'] ?? item['pf'])
            : (item['dailyAvgPowerFactor'] ?? item['avgPowerFactor'] ?? item['powerFactor'] ?? item['pf']);
        if (pf == null) return null;
        return (pf is num) ? pf.toDouble() : double.tryParse(pf.toString()) ?? 0.0;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  String _getMonthAbbr(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  late ZoomPanBehavior _zoomPanBehavior;

  @override
  void initState() {
    super.initState();
    _zoomPanBehavior = ZoomPanBehavior(enablePanning: true, zoomMode: ZoomMode.x);
    loadPowerFactorData();
  }

  List<LineSeries<ChartData, String>> _buildSeries() {
    return [
      _lineSeries(const Color(0xFF7B61FF), (d) => d.phase1, "Phase A"),
      _lineSeries(const Color(0xFF00B4D8), (d) => d.phase2, "Phase B"),
      _lineSeries(const Color(0xFFFF6B6B), (d) => d.phase3, "Phase C"),
      _lineSeries(const Color(0xFFFFB347), (d) => d.phase4, "Three Phase"),
    ];
  }

  LineSeries<ChartData, String> _lineSeries(
      Color color, double? Function(ChartData) mapper, String name) {
    return LineSeries<ChartData, String>(
      name: name,
      dataSource: data,
      xValueMapper: (d, _) => d.time,
      yValueMapper: (d, _) => mapper(d),
      color: color,
      width: 2.5,
      markerSettings: MarkerSettings(
        isVisible: true,
        height: 7,
        width: 7,
        shape: DataMarkerType.circle,
        color: color,
        borderColor: color,
        borderWidth: 1.5,
      ),
    );
  }

  Widget _buildLegend() {
    const legendItems = [
      ["Phase A", Color(0xFF7B61FF)],
      ["Phase B", Color(0xFF00B4D8)],
      ["Phase C", Color(0xFFFF6B6B)],
      ["Three Phase", Color(0xFFFFB347)],
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: legendItems.map((item) {
          return Padding(
            padding: const EdgeInsets.only(right: 15),
            child: _LegendDot(item[0] as String, item[1] as Color),
          );
        }).toList(),
      ),
    );
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
          loadPowerFactorData();
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
            // ── Title + Filter Dropdown ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Power Factor (0-1)",
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
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF7B61FF)))
                  : data.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inbox, size: 48, color: Colors.grey.shade400),
                    const SizedBox(height: 8),
                    Text(
                      "No power factor data available",
                      style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
                    ),
                  ],
                ),
              )
                  : Row(
                children: [
                  RotatedBox(
                    quarterTurns: 3,
                    child: Text(
                      'Power Factor',
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
        maximum: 1,
        interval: 0.5,
        labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 11),
        axisLine: AxisLine(width: 1, color: Colors.grey.shade300),
        majorGridLines: MajorGridLines(
          width: 1,
          color: Colors.grey.shade200,
          dashArray: const [5, 5],
        ),
      ),
      series: _buildSeries(),
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
  ChartData(this.time, this.phase1, this.phase2, this.phase3, this.phase4);
  final String time;
  final double? phase1;
  final double? phase2;
  final double? phase3;
  final double? phase4;
}