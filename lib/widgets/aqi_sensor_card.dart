import 'package:dt_mobile/models/response/aqi_response.dart';
import 'package:dt_mobile/services/aqi_service.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class AirQualityScreen extends StatefulWidget {
  const AirQualityScreen({Key? key}) : super(key: key);

  @override
  State<AirQualityScreen> createState() => _AirQualityScreenState();
}

class _AirQualityScreenState extends State<AirQualityScreen> {
  List<AqiData> devices = [];
  AqiData? selectedAqi;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadAqiData();
  }

  Future<void> loadAqiData() async {
    try {
      devices = await ApiService.fetchAllAqiDevices();
      if (devices.isNotEmpty) {
        selectedAqi = devices.first;
      }
    } catch (e) {
      debugPrint('Error loading AQI devices: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  String getAqiStatus(int? iaq) {
    final value = iaq ?? 0;
    if (value <= 1) return 'Good';
    if (value <= 2) return 'Moderate';
    if (value <= 3) return 'Unhealthy';
    if (value <= 4) return 'Very Unhealthy';
    return 'Hazardous';
  }

  Color getAqiColor(int? iaq) {
    final value = iaq ?? 0;
    if (value <= 1) return Colors.green;
    if (value <= 2) return Colors.orange;
    if (value <= 3) return Colors.red;
    if (value <= 4) return Colors.purple;
    return Colors.brown;
  }

  double getAqiPercent(int? iaq) {
    final value = iaq ?? 0;
    return (value / 5).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (selectedAqi == null) {
      return const Center(child: Text("No AQI data available"));
    }


    final aqi = selectedAqi!;

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final iconSize = screenWidth * 0.05;
    final headerFont = screenWidth * 0.055;
    final valueFont = screenWidth * 0.045;
    final unitFont = screenWidth * 0.026;

    return SizedBox(
      width: double.infinity,
      child: Card(
        margin: EdgeInsets.all(screenWidth * 0.01),
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: Colors.white,
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.03),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [


                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            'assets/icons/airindicator.png',
                            width: iconSize,
                            height: iconSize,
                            color: Colors.green,
                          ),
                          SizedBox(width: screenWidth * 0.015),
                          Flexible(
                            child: Text(
                              'Air Quality',
                              style: TextStyle(
                                fontSize: headerFont,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(
                      width: screenWidth * 0.38,
                      height: screenHeight * 0.055,
                      child: DropdownButtonFormField<String>(
                        value: aqi.deviceId,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.03,
                            vertical: screenHeight * 0.012,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.grey.shade400),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.grey.shade400),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
                          ),
                        ),
                        icon: Icon(Icons.keyboard_arrow_down),
                        items: devices.map((d) {
                          return DropdownMenuItem(
                            value: d.deviceId,
                            child: Text(d.deviceId),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue == null) return;
                          setState(() {
                            selectedAqi =
                                devices.firstWhere((e) => e.deviceId == newValue);
                          });
                        },
                      ),
                    ),

                  ],
                ),

                SizedBox(height: screenHeight * 0.02),

                // ================= CIRCLE + INFO =================
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CircularPercentIndicator(
                      radius: screenWidth * 0.18,
                      lineWidth: screenWidth * 0.03,
                      percent: getAqiPercent(aqi.iaq),
                      progressColor: getAqiColor(aqi.iaq),
                      center: Text(
                        getAqiStatus(aqi.iaq),
                        style: TextStyle(
                          fontSize: screenWidth * 0.03,
                          fontWeight: FontWeight.w600,
                          color: getAqiColor(aqi.iaq),
                        ),
                      ),
                    ),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Image.asset('assets/icons/thermometer.png',
                              width: iconSize,
                              height: iconSize,
                              color: Colors.green,
                            ),
                            SizedBox(width: screenWidth * 0.02),
                            Text('Temperature',
                                style: TextStyle(
                                    fontSize: screenWidth * 0.032,
                                    color: Colors.grey)),
                          ],
                        ),
                        SizedBox(height: screenHeight * 0.005),
                        Text(
                          '${aqi.temperature} °C',
                          style: TextStyle(
                            fontSize: screenWidth * 0.05,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        SizedBox(height: screenHeight * 0.02),

                        Row(
                          children: [
                            Image.asset('assets/icons/humidity.png',
                              width: iconSize,
                              height: iconSize,
                              color: Colors.green,
                            ),
                            SizedBox(width: screenWidth * 0.02),
                            Text('Humidity',
                                style: TextStyle(
                                    fontSize: screenWidth * 0.032,
                                    color: Colors.grey)),
                          ],
                        ),
                        SizedBox(height: screenHeight * 0.005),
                        Text(
                          '${aqi.humidity} %',
                          style: TextStyle(
                            fontSize: screenWidth * 0.05,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                SizedBox(height: screenHeight * 0.02),
                Divider(),
                SizedBox(height: screenHeight * 0.01),

                // ================= GRID =================
                GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  crossAxisSpacing: screenWidth * 0.02,
                  mainAxisSpacing: screenWidth * 0.02,
                  childAspectRatio: 1.0,
                  children: [
                    MetricCard(title: 'IAQ Index', value: aqi.iaq.toString(), unit: 'μg/m³', iconAssetPath: 'assets/icons/air1.png'),
                    MetricCard(title: 'TVOC', value: aqi.tvoc.toString(), unit: 'μg/m³', iconAssetPath: 'assets/icons/air1.png'),
                    MetricCard(title: 'eCO2', value: aqi.co2.toString(), unit: 'ppm', iconAssetPath: 'assets/icons/air1.png'),
                    MetricCard(title: 'PM 1.0', value: aqi.pm1.toString(), unit: 'μg/m³', iconAssetPath: 'assets/icons/air1.png'),
                    MetricCard(title: 'PM 2.5', value: aqi.pm2_5.toString(), unit: 'μg/m³', iconAssetPath: 'assets/icons/air1.png'),
                    MetricCard(title: 'PM 10', value: aqi.pm10.toString(), unit: 'μg/m³', iconAssetPath: 'assets/icons/air1.png'),
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

// ================= METRIC CARD =================

class MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final String iconAssetPath;

  const MetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.unit,
    required this.iconAssetPath,
  });

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: EdgeInsets.all(w * 0.02),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Image.asset(iconAssetPath,
                  width: w * 0.035,
                  height: w * 0.035,
                  color: Colors.green),
              SizedBox(width: w * 0.015),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: w * 0.028, color: Colors.grey.shade600),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                value,
                style: TextStyle(fontSize: w * 0.045, fontWeight: FontWeight.bold),
              ),
              SizedBox(width: w * 0.01),
              Text(
                unit,
                style: TextStyle(fontSize: w * 0.022, color: Colors.grey.shade500),
              ),
            ],
          )
        ],
      ),
    );
  }
}