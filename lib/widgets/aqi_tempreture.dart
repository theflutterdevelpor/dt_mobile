import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../services/aqi_service.dart'; // Fixed import

class AqiTemperatureChart extends StatefulWidget {
  const AqiTemperatureChart({Key? key}) : super(key: key);

  @override
  State<AqiTemperatureChart> createState() => _AqiTemperatureChartState();
}

class _AqiTemperatureChartState extends State<AqiTemperatureChart> {
  List<ChartData> data = [];
  bool isLoading = false;
  String? errorMessage;
  bool _isDisposed = false;

  String selectedFilter = "Today";
  final List<String> filterOptions = ["Today", "Yesterday", "Week", "30 Days", "6 Month"];

  late ZoomPanBehavior _zoomPanBehavior;

  @override
  void initState() {
    super.initState();
    _zoomPanBehavior = ZoomPanBehavior(
      enablePanning: true,
      zoomMode: ZoomMode.x,
    );
    _loadData(selectedFilter);
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  String dateFormat(DateTime date) =>
      "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

  Map<String, String> getDateRange(String dateFilter) {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    late DateTime fromDate;
    late DateTime toDate = now;

    switch (dateFilter) {
      case 'Today':
        fromDate = todayStart;
        toDate = now;
        break;
      case 'Yesterday':
        fromDate = todayStart.subtract(const Duration(days: 1));
        toDate = todayStart.subtract(const Duration(seconds: 1));
        break;
      case 'Week':
        fromDate = now.subtract(const Duration(days: 6));
        toDate = now;
        break;
      case '30 Days':
        fromDate = now.subtract(const Duration(days: 29));
        toDate = now;
        break;
      case '6 Month':
        fromDate = DateTime(now.year, now.month - 6, now.day);
        toDate = now;
        break;
      default:
        fromDate = todayStart;
        toDate = now;
    }

    return {
      'fromDate': dateFormat(fromDate),
      'toDate': dateFormat(toDate),
    };
  }

  String _formatLabel(DateTime date, String filter) {
    switch (filter) {
      case 'Today':
      case 'Yesterday':
        return '${date.hour.toString().padLeft(2, '0')}:00';
      case 'Week':
        const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        return days[date.weekday - 1];
      case '30 Days':
        return '${date.day}/${date.month}';
      case '6 Month':
        const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
          'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        return '${months[date.month - 1]} ${date.year}';
      default:
        return '${date.day}/${date.month}';
    }
  }

  int _getAutoScrollDelta() {
    switch (selectedFilter) {
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
    switch (selectedFilter) {
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
    print('═══════════════════════════════════════');
    print('Loading Temperature Data for filter: $filter');
    print('═══════════════════════════════════════');

    if (!mounted || _isDisposed) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final range = getDateRange(filter);
      print('📅 Date Range: ${range['fromDate']} to ${range['toDate']}');

      final response = await ApiService.fetchAqiAggregatedData(
        fromDate: range['fromDate']!,
        toDate: range['toDate']!,
        aggregated: true,
      );

      if (!mounted || _isDisposed) return;

      print('📊 Total data points: ${response.data.length}');

      if (response.data.isEmpty) {
        setState(() {
          data = [];
          errorMessage = 'No data available for selected period';
        });
        return;
      }

      // Filter points with temperature data
      final validPoints = response.data
          .where((d) => d.avgTemperature != null)
          .toList()
        ..sort((a, b) => a.hour.compareTo(b.hour));

      print('🌡️ Points with temperature: ${validPoints.length}');

      if (validPoints.isEmpty) {
        setState(() {
          data = [];
          errorMessage = 'No temperature data available for selected period';
        });
        return;
      }

      // Process data for chart
      final Map<String, ChartData> uniqueData = {};

      for (var point in validPoints) {
        final label = _formatLabel(point.hour, filter);

        if (uniqueData.containsKey(label)) {
          // Average if duplicate
          final existing = uniqueData[label]!;
          final avgValue = (existing.temperature + point.avgTemperature!) / 2;
          uniqueData[label] = ChartData(
            label: label,
            temperature: avgValue,
          );
          print('🔄 Averaging duplicate "$label": ${existing.temperature.toStringAsFixed(1)} + ${point.avgTemperature!.toStringAsFixed(1)} = ${avgValue.toStringAsFixed(1)}');
        } else {
          uniqueData[label] = ChartData(
            label: label,
            temperature: point.avgTemperature!,
          );
        }
      }

      setState(() {
        data = uniqueData.values.toList();

        // Sort for time-based filters
        if (filter == 'Today' || filter == 'Yesterday') {
          data.sort((a, b) {
            final hourA = int.tryParse(a.label.split(':')[0]) ?? 0;
            final hourB = int.tryParse(b.label.split(':')[0]) ?? 0;
            return hourA.compareTo(hourB);
          });
        }
      });

      print('✅ Loaded ${data.length} unique temperature data points');
      if (data.isNotEmpty) {
        print('📈 Temperature range: ${data.map((d) => d.temperature).reduce((a, b) => a < b ? a : b).toStringAsFixed(1)}°C - ${data.map((d) => d.temperature).reduce((a, b) => a > b ? a : b).toStringAsFixed(1)}°C');
      }

    } catch (e, stackTrace) {
      print('❌ Error loading temperature data: $e');
      print('Stack trace: $stackTrace');
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
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
            const Icon(Icons.keyboard_arrow_down,
                size: 18, color: Colors.black54),
          ],
        ),
        onSelected: (val) {
          setState(() {
            selectedFilter = val;
          });
          _loadData(val);
        },
        itemBuilder: (context) => filterOptions.map((choice) {
          return PopupMenuItem<String>(
            value: choice,
            child: Text(
              choice,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          );
        }).toList(),
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Temperature (°C)",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    _buildDropdown(),
                  ],
                ),
                const SizedBox(height: 20),

                // Chart Body
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
                        Text(
                          errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: Colors.red, fontSize: 13),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () => _loadData(selectedFilter),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                      : data.isEmpty
                      ? const Center(
                    child: Text(
                      'No data available',
                      style: TextStyle(color: Colors.black45),
                    ),
                  )
                      : _buildChart(),
                ),

                const SizedBox(height: 16),

                // Legend
                SizedBox(
                  height: 30,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      _LegendDot("Temperature", Color(0xFF7B83EB)),
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
    // Calculate min and max temperature for Y-axis
    final temperatures = data.map((d) => d.temperature).toList();
    final minTemp = temperatures.reduce((a, b) => a < b ? a : b);
    final maxTemp = temperatures.reduce((a, b) => a > b ? a : b);

    // Add some padding to Y-axis range
    final yMin = (minTemp - 2).floorToDouble();
    final yMax = (maxTemp + 2).ceilToDouble();

    return SfCartesianChart(
      plotAreaBorderWidth: 0,
      zoomPanBehavior: _zoomPanBehavior,

      tooltipBehavior: TooltipBehavior(
        enable: true,
        activationMode: ActivationMode.singleTap,
        builder: (dynamic data, dynamic point, dynamic series, int pointIndex, int seriesIndex) {
          return Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5),
              boxShadow: [const BoxShadow(color: Colors.black26, blurRadius: 3)],
            ),
            child: Text(
              '${(data as ChartData).label}\nTemperature: ${data.temperature.toStringAsFixed(1)}°C',
              style: const TextStyle(fontSize: 12, color: Colors.black),
            ),
          );
        },
      ),

      primaryXAxis: CategoryAxis(
        autoScrollingDelta: _getAutoScrollDelta(),
        autoScrollingMode: AutoScrollingMode.start,
        interval: _getXAxisInterval(),
        labelRotation: selectedFilter == 'Today' || selectedFilter == 'Yesterday' ? 0 : -45,
        majorGridLines: const MajorGridLines(width: 0),
        axisLine: const AxisLine(color: Colors.black26,width: 1),
        labelStyle: const TextStyle(fontSize: 11, color: Colors.black87),
        edgeLabelPlacement: EdgeLabelPlacement.shift,
      ),

      primaryYAxis: NumericAxis(
        minimum: 0,
        maximum: 100,
        interval: 50,
        title: const AxisTitle(text: 'Temperature (°C)'),
        majorGridLines: const MajorGridLines(
          width: 1,
          dashArray: [5, 5],
          color: Colors.black12,
        ),
        axisLine: const AxisLine(color: Colors.black26,width: 1),
        labelStyle: const TextStyle(fontSize: 11, color: Colors.black87),
      ),

      series: <CartesianSeries<ChartData, String>>[
        LineSeries<ChartData, String>(
          name: 'Temperature',
          dataSource: data,
          xValueMapper: (ChartData data, _) => data.label,
          yValueMapper: (ChartData data, _) => data.temperature,
          color: const Color(0xFF7B83EB),
          width: 3,
          markerSettings: const MarkerSettings(
            isVisible: true,
            height: 8,
            width: 8,
            shape: DataMarkerType.circle,
            color: Color(0xFF7B83EB),
            borderColor: Colors.white,
            borderWidth: 2,
          ),
          enableTooltip: true,
          animationDuration: 800,
        ),
      ],
    );
  }

  double _calculateYAxisInterval(double min, double max) {
    final range = max - min;
    if (range <= 10) return 2;
    if (range <= 20) return 5;
    if (range <= 50) return 10;
    return 20;
  }
}

class ChartData {
  final String label;
  final double temperature;

  ChartData({
    required this.label,
    required this.temperature,
  });
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