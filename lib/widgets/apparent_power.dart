import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../services/energy_services.dart';

class ApparentPowerChart extends StatefulWidget {
  const ApparentPowerChart({Key? key}) : super(key: key);

  @override
  State<ApparentPowerChart> createState() => _ApparentPowerChartState();
}

class _ApparentPowerChartState extends State<ApparentPowerChart> {
  List<ChartData> data = [];
  bool isLoading = false;
  double maxYValue = 20.0;

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

  Future<void> loadApparentPowerData() async {
    setState(() => isLoading = true);

    final dates = getDateRange(selectedFilter);

    try {
      Map<String, dynamic> response;

      if (selectedFilter == 'Today' || selectedFilter == 'Yesterday') {
        response = await EnergyService.fetchEnergyHourly(
          date: dates['fromDate']!,
        );
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
        threePhaseList.length
      ].reduce((a, b) => a > b ? a : b);

      if (maxLength == 0) {
        setState(() {
          data = [];
          isLoading = false;
        });
        return;
      }

      List<ChartData> chartData = [];
      double maxValue = 0.0;

      for (int i = 0; i < maxLength; i++) {
        final phase1 = _getApparentPowerFromList(phase1List, i, isHourly);
        final phase2 = _getApparentPowerFromList(phase2List, i, isHourly);
        final phase3 = _getApparentPowerFromList(phase3List, i, isHourly);
        final threePhase = _getApparentPowerFromList(threePhaseList, i, isHourly);

        maxValue = [maxValue, phase1, phase2, phase3, threePhase].reduce((a, b) => a > b ? a : b);

        String label = "Day ${i + 1}";

        if (isHourly) {
          if (i < phase1List.length) {
            final hour = phase1List[i]['hour'] ?? i;
            label = "$hour-${(hour + 1) % 24}";
          } else if (i < threePhaseList.length) {
            final hour = threePhaseList[i]['hour'] ?? i;
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
          } else if (i < threePhaseList.length) {
            final dateStr = threePhaseList[i]['date']?.toString().split('T')[0] ?? "Day ${i + 1}";
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

      maxYValue = maxValue > 0 ? ((maxValue / 10).ceil() * 10).toDouble() : 20.0;
      if (maxYValue < 10) maxYValue = 10;
      // Make maxYValue a multiple of 3 so interval stays clean (no decimals)
      final remainder = maxYValue % 3;
      if (remainder != 0) maxYValue += (3 - remainder);

      setState(() {
        data = chartData;
      });
    } catch (e, stackTrace) {
      debugPrint('APPARENT POWER API ERROR: $e');
      debugPrint('Stack trace: $stackTrace');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading apparent power data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    setState(() => isLoading = false);
  }

  double _getApparentPowerFromList(List<Map<String, dynamic>> list, int index, bool isHourly) {
    try {
      if (index < list.length) {
        final item = list[index];

        final apparentPower = isHourly
            ? (item['avgApparentPowerPerHour'] ??
            item['avgApparentPower'] ??
            item['apparentPower'] ??
            item['kVA'] ??
            item['avgPowerPerHour'] ??
            item['avgPower'])
            : (item['dailyAvgApparentPower'] ??
            item['avgApparentPower'] ??
            item['apparentPower'] ??
            item['kVA'] ??
            item['dailyAvgPower'] ??
            item['avgPower']);

        if (apparentPower == null) return 0.0;

        final value = (apparentPower is num)
            ? apparentPower.toDouble()
            : double.tryParse(apparentPower.toString()) ?? 0.0;
        return value;
      }
      return 0.0;
    } catch (e) {
      debugPrint('Error extracting apparent power at index $index: $e');
      return 0.0;
    }
  }

  String _getMonthAbbr(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  late ZoomPanBehavior _zoomPanBehavior;

  @override
  void initState() {
    super.initState();
    _zoomPanBehavior = ZoomPanBehavior(enablePanning: true, zoomMode: ZoomMode.x);
    loadApparentPowerData();
  }

  ColumnSeries<ChartData, String> _barSeries(
      Color color, double? Function(ChartData) mapper, String name) {
    return ColumnSeries<ChartData, String>(
      dataSource: data,
      xValueMapper: (d, _) => d.month,
      yValueMapper: (d, _) => mapper(d),
      name: name,
      color: color,
      borderRadius: BorderRadius.circular(6),
      emptyPointSettings: const EmptyPointSettings(mode: EmptyPointMode.gap),
    );
  }

  List<ColumnSeries<ChartData, String>> _buildSeries() {
    return [
      _barSeries(const Color(0xFF7B61FF), (d) => d.phase1 ?? 0, "Phase A"),
      _barSeries(const Color(0xFF00B4D8), (d) => d.phase2 ?? 0, "Phase B"),
      _barSeries(const Color(0xFFFF6B6B), (d) => d.phase3 ?? 0, "Phase C"),
      _barSeries(const Color(0xFFFFB347), (d) => d.phase4 ?? 0, "Three Phase"),
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
          loadApparentPowerData();
        },
        itemBuilder: (context) => filterOptions
            .map((choice) => PopupMenuItem<String>(
          value: choice,
          child: Text(
            choice,
            style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black87),
          ),
        ))
            .toList(),
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
        children: legendItems
            .map((item) => Padding(
          padding: const EdgeInsets.only(right: 15),
          child: _LegendDot(item[0] as String, item[1] as Color),
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title + Dropdown
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Apparent Power\n"
                      "(kVA)",
                  style: TextStyle(
                      color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                _buildDropdown(),
              ],
            ),
            const SizedBox(height: 16),
            // Chart
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
                      "No power data available",
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
                      'Apparent Power (kVA)',
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
            // Legend
            SizedBox(height: 30, child: _buildLegend()),
          ],
        ),
      ),
    );
  }

  Widget _buildChart() {
    return SfCartesianChart(
      plotAreaBorderWidth: 0,
      backgroundColor: Colors.transparent,
      zoomPanBehavior: _zoomPanBehavior,
      primaryXAxis: CategoryAxis(
        labelStyle: const TextStyle(fontSize: 11, color: Colors.black87),
        majorGridLines: const MajorGridLines(width: 0),
        axisLine: const AxisLine(width: 1, color: Colors.black26),
        autoScrollingDelta: 6,
        autoScrollingMode: AutoScrollingMode.start,
      ),
      primaryYAxis: NumericAxis(
        minimum: 0,
        maximum: 15,
        interval: 5,
        labelStyle: const TextStyle(color: Colors.black87, fontSize: 11),
        axisLine: const AxisLine(width: 1, color: Colors.black26),
        majorGridLines:
        const MajorGridLines(width: 1, color: Colors.black12, dashArray: [5, 5]),
      ),
      series: _buildSeries(),
    );
  }
}

// Legend Dot
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
            decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
        const SizedBox(width: 5),
        Text(text, style: TextStyle(fontSize: 11, color: Colors.grey.shade700)),
      ],
    );
  }
}

// Chart Data
class ChartData {
  ChartData(this.month, this.phase1, this.phase2, this.phase3, this.phase4);
  final String month;
  final double? phase1;
  final double? phase2;
  final double? phase3;
  final double? phase4;
}