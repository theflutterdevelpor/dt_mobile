
import 'package:dt_mobile/models/response/profile_response.dart';
import 'package:dt_mobile/services/notification_service.dart';
import 'package:dt_mobile/services/profile_services.dart';
import 'package:dt_mobile/widgets/apparent_power.dart';
import 'package:dt_mobile/widgets/aqi_chart.dart';
import 'package:dt_mobile/widgets/aqi_humidity.dart';
import 'package:dt_mobile/widgets/aqi_tempreture.dart';
import 'package:dt_mobile/widgets/aqiindex_chart.dart';
import 'package:dt_mobile/widgets/aqitvoc_chart.dart';
import 'package:dt_mobile/widgets/co2_chart.dart';
import 'package:dt_mobile/widgets/co_chart.dart';
import 'package:dt_mobile/widgets/contact_chart.dart';
import 'package:dt_mobile/widgets/current_chart.dart';
import 'package:dt_mobile/widgets/eco2_chart.dart';
import 'package:dt_mobile/widgets/energy_power_chart.dart';
import 'package:dt_mobile/widgets/frequency_chart.dart';
import 'package:dt_mobile/widgets/humidity_chart.dart';
import 'package:dt_mobile/widgets/motion_chart.dart';
import 'package:dt_mobile/widgets/notification.dart';
import 'package:dt_mobile/widgets/pm10_chart.dart';
import 'package:dt_mobile/widgets/pm1_chart.dart';
import 'package:dt_mobile/widgets/pm25_chart.dart';
import 'package:dt_mobile/widgets/power_bar_chart.dart';
import 'package:dt_mobile/widgets/power_factor_chart.dart';
import 'package:dt_mobile/widgets/reactive_power.dart';
import 'package:dt_mobile/widgets/smoke_chart.dart';
import 'package:dt_mobile/widgets/socket_energychart.dart';
import 'package:dt_mobile/widgets/socket_statuschart.dart';
import 'package:dt_mobile/widgets/socket_voltagechart.dart';
import 'package:dt_mobile/widgets/tempreture_chart.dart';
import 'package:dt_mobile/widgets/voltage_chart.dart';
import 'package:flutter/material.dart';
import 'package:dt_mobile/services/auth_services.dart';

class chartPage extends StatefulWidget {
  const chartPage({super.key});

  @override
  State<chartPage> createState() => _chartPageState();
}

class _chartPageState extends State<chartPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<Map<String, dynamic>> buildings = [];
  List<Map<String, dynamic>> floors = [];


  String? selectedBuildingId;
  String selectedBuildingName = 'Select Building';

  String? selectedFloorId;
  String selectedFloorLabel = 'Select Floor';
  bool isLoading = false;
  int _unreadCount = 0;


  @override
  void initState() {
    super.initState();
    fetchBuildings();
    _fetchUnreadCount();
  }


  Future<void> _fetchUnreadCount() async {
    int count = await NotificationApi.getUnreadCount();
    if (mounted) {
      setState(() {
        _unreadCount = count;
      });
    }
  }


  Future<void> fetchBuildings() async {
    setState(() => isLoading = true);

    try {
      debugPrint(" HIT: /org/buildings API");
      final response = await ApiService.getRequest('/org/buildings');
      debugPrint(" SUCCESS: /org/buildings Module ki API HIT HO GAYI hai ");


      if (response['success'] == true && response['data'] != null) {
        final List data = response['data'];

        buildings = List<Map<String, dynamic>>.from(data);

        if (buildings.isNotEmpty) {
          final firstBuilding = buildings.first;

          selectedBuildingId = firstBuilding['_id'];
          selectedBuildingName = firstBuilding['name'];

          floors =
          List<Map<String, dynamic>>.from(firstBuilding['floors'] ?? []);

          if (floors.isNotEmpty) {
            selectedFloorId = floors.first['_id'];
            selectedFloorLabel = floors.first['label'];
          }
        }
      }
    } catch (e) {
      debugPrint(' Building API Error: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }
  //
  // Widget _buildDropdown({
  //   required String value,
  //   required List<String> items,
  //   required ValueChanged<String?> onChanged,
  // }) {
  //   return Container(
  //     height: 48,
  //     padding: const EdgeInsets.symmetric(horizontal: 12),
  //     decoration: BoxDecoration(
  //       border: Border.all(color: Colors.grey.shade300),
  //       borderRadius: BorderRadius.circular(6),
  //     ),
  //     child: DropdownButtonHideUnderline(
  //       child: DropdownButton<String>(
  //         value: value,
  //         isExpanded: true,
  //         icon: const Icon(Icons.keyboard_arrow_down),
  //         items: items
  //             .map(
  //               (item) => DropdownMenuItem(
  //             value: item,
  //             child: Text(item),
  //           ),
  //         )
  //             .toList(),
  //         onChanged: onChanged,
  //       ),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          "Analytics",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => NotificationScreen()),
                  ).then((_) => _fetchUnreadCount());
                },
                icon: const Icon(Icons.notifications_none),
              ),
              if (_unreadCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      _unreadCount > 9 ? '9+' : '$_unreadCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => _scaffoldKey.currentState?.openEndDrawer(),
              child: FutureBuilder<ProfileModel?>(
                future: ProfileApiService.getProfile(),
                builder: (context, snapshot) {
                  final profile = snapshot.data;
                  return CircleAvatar(
                    backgroundColor: Colors.green.shade100,
                    backgroundImage: (profile?.image?.url != null &&
                        profile!.image!.url.isNotEmpty)
                        ? NetworkImage(profile.image!.url)
                        : null,
                    child: (profile?.image?.url == null ||
                        profile?.image?.url.isEmpty == true)
                        ? Text(
                      profile?.name.isNotEmpty == true
                          ? profile!.name[0].toUpperCase()
                          : 'A',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    )
                        : null,
                  );
                },
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: 100),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  "Monitoring Dashboard",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),

                const SizedBox(height: 16),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 40,
                        width: double.infinity,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: buildings.isEmpty ? null : selectedBuildingId,
                              hint: const Text("Select Building"),
                              isExpanded: true,
                              icon: const Icon(Icons.keyboard_arrow_down),
                              items: buildings.map((b) {
                                return DropdownMenuItem<String>(
                                  value: b['_id'],
                                  child: Text(
                                    b['name'],
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value == null) return;
                                final building =
                                buildings.firstWhere((b) => b['_id'] == value);

                                setState(() {
                                  selectedBuildingId = value;
                                  floors = List<Map<String, dynamic>>.from(
                                      building['floors'] ?? []);
                                  selectedFloorId =
                                  floors.isNotEmpty ? floors.first['_id'] : null;
                                });
                              },
                            ),
                          ),
                        ),
                      ),


                      const SizedBox(height: 12),

                      /// FLOOR DROPDOWN
                      SizedBox(
                        height: 40,
                        width: double.infinity,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: floors.isEmpty ? null : selectedFloorId,
                              hint: const Text("Select Floor"),
                              isExpanded: true,
                              icon: const Icon(Icons.keyboard_arrow_down),
                              items: floors.map((f) {
                                return DropdownMenuItem<String>(
                                  value: f['_id'],
                                  child: Text(
                                    f['label'],
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedFloorId = value;
                                });
                              },
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                        // ====== NEW CARD ======
                        Card(
                          color: Colors.white,
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(
                    "Electrical Parameters",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                   Divider(
                    thickness: 1,
                    color: Colors.grey,
                  ),
                   SizedBox(height: 8),
                  SizedBox(
                    height: 350,
                    child: VoltageChart(),
                  ),
                  SizedBox(height: 10,),
                  SizedBox(
                    height: 350,
                    child: CurrentChart(),
                  ),
                  SizedBox(height: 10,),
                  SizedBox(
                    height: 350,
                    child: FrequencyChart(),
                  ),
                  SizedBox(height: 10,),
                  SizedBox(
                    height: 350,
                    child: PowerFactorChart(),
                  ),
                  SizedBox(height: 10,),
                  SizedBox(
                    height: 350,
                    child: PowerBarChart(),
                  ),
                  SizedBox(height: 10,),
                  SizedBox(
                    height: 350,
                    child: ReactiveBarChart(),
                  ),
                  SizedBox(height: 10,),
                  SizedBox(
                    height: 350,
                    child: ApparentPowerChart(),
                  ),
                  SizedBox(height: 10,),
                  SizedBox(
                    height: 350,
                    child: EnergyPowerChart(),
                  ),
                ],
              ),
            ),
                        ),
                        SizedBox(height: 20,),
                        Card(
                          color: Colors.white,
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Environmental Parameters",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Divider(
                    thickness: 1,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 8),
                  SizedBox(
                    height: 350,
                    child: TemperatureChart(deviceId: 'DHT22-N_0001',),
                  ),
                  SizedBox(height: 10,),
                  SizedBox(
                    height: 350,
                    child: HumidityChart(deviceId: 'DHT22-N_0001',),
                  ),
                  SizedBox(height: 10,),
                  SizedBox(
                    height: 350,
                    child: CO2Chart(deviceId: 'MQ7-N_0003',),
                  ),
                  SizedBox(height: 10,),
                  SizedBox(
                    height: 350,
                    child: COChart(deviceId: 'MQ7-N_0003',),
                  ),
                  SizedBox(height: 10,),
                  SizedBox(
                    height: 350,
                    child: SmokeChart(),
                  ),
                  SizedBox(height: 10,),
                  SizedBox(
                    height: 350,
                    child: AQIChart(),
                  ),
                  SizedBox(height: 10,),
                  SizedBox(
                    height: 350,
                    child: MotionSensorChart( deviceId: 'PIR-N_0004',),
                  ),
                  SizedBox(height: 10,),
                  SizedBox(
                    height: 350,
                    child: ContactSensorChart(),
                  ),
                ],
              ),
            ),
                        ),
                      SizedBox(height: 20,),
                      Card(
                          color: Colors.white,
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 Text(
                  "Socket Controls",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Divider(
                  thickness: 1,
                  color: Colors.grey,
                ),
                SizedBox(height: 8),
                SizedBox(
                  height: 350,
                  child: SocketStatusChart(),
                ),
                SizedBox(height: 10,),
                SizedBox(
                  height: 350,
                  child: SocketEnergyChart(),
                ),
                SizedBox(height: 10,),
                SizedBox(
                  height: 350,
                  child: SocketVoltageChart(),
                ),


              ],
            ),
                        ),
                      ),




                      SizedBox(height: 20,),
                      Card(
                        color: Colors.white,
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "AQI Sensor Parameter",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Divider(
                                thickness: 1,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 8),
                              SizedBox(
                                height: 350,
                                child: AqiTemperatureChart(),
                              ),
                              SizedBox(height: 10,),
                              SizedBox(
                                height: 350,
                                child: AqiHumidityChart(),
                              ),
                              SizedBox(height: 10,),
                              SizedBox(
                                height: 350,
                                child: AqiIndexChart(),
                              ),

                              SizedBox(height: 10,),
                              SizedBox(
                                height: 350,
                                child: TvocChart(),
                              ),
                              SizedBox(height: 10,),
                              SizedBox(
                                height: 350,
                                child: ECo2Chart(),
                              ),
                              SizedBox(height: 10,),
                              SizedBox(
                                height: 350,
                                child: Pm1Chart(),
                              ),
                              SizedBox(height: 10,),
                              SizedBox(
                                height: 350,
                                child: Pm25Chart(),
                              ),
                              SizedBox(height: 10,),
                              SizedBox(
                                height: 350,
                                child: Pm10Chart(),
                              ),



                            ],
                          ),
                        ),
                      ),
          ],
                    ),
                  ),
                ]
                )
    ]
        )
      )
    );
  }
}
