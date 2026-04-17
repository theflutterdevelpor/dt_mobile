import 'package:dt_mobile/models/response/device_response.dart';
import 'package:dt_mobile/models/response/profile_response.dart';
import 'package:dt_mobile/pages/report_screens/schedule.dart';
import 'package:dt_mobile/pages/report_screens/sensor_detail_screen.dart';
import 'package:dt_mobile/services/device_service.dart';
import 'package:dt_mobile/services/notification_service.dart';
import 'package:dt_mobile/services/profile_services.dart';
import 'package:dt_mobile/widgets/notification.dart';
import 'package:dt_mobile/widgets/profile_drawer.dart';
import 'package:flutter/material.dart';
import 'package:dt_mobile/services/auth_services.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  List<Map<String, dynamic>> buildings = [];
  List<Map<String, dynamic>> floors = [];
  List<DeviceModel> allDevices = [];

  String? selectedBuildingId;
  String? selectedFloorId;
  String selectedSensorLabel = 'All';
  int _unreadCount = 0;

  bool isLoading = true;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final Map<String, String?> sensorMap = {
    'All': null,
    'Energy': 'Energy Meter',
    'Temperature': 'Temperature Sensor',
    'Gas': 'Gas Sensor',
    'Motion': 'Motion Sensor',
  };


  bool get isFloorEnabled => selectedBuildingId != null;

  bool get isSensorEnabled => selectedFloorId != null;

  bool get showCard =>
      selectedBuildingId != null &&
          selectedFloorId != null &&
          selectedSensorLabel != 'All';

  @override
  void initState() {
    super.initState();
    fetchBuildingsAndDevices();
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

  Future<void> fetchBuildingsAndDevices() async {
    setState(() => isLoading = true);

    try {
      final buildingResponse = await ApiService.getRequest('/org/buildings');

      allDevices = await DeviceService.getDevices();

      if (buildingResponse['success'] == true &&
          buildingResponse['data'] != null) {
        setState(() {
          buildings =
          List<Map<String, dynamic>>.from(buildingResponse['data']);

          selectedBuildingId = null;
          selectedFloorId = null;
          selectedSensorLabel = 'All';

          floors = [];

          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error: $e");
      setState(() => isLoading = false);
    }
  }

  void updateFloorsForBuilding(String buildingId) {
    final floorsMap = <String, Map<String, dynamic>>{};

    for (var device in allDevices) {
      if (device.building?.id == buildingId && device.floor != null) {
        floorsMap[device.floor!.id] = {
          '_id': device.floor!.id,
          'label': device.floor!.label,
        };
      }
    }

    setState(() {
      floors = floorsMap.values.toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      endDrawer: const ProfileDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text("Configuration"),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => SchedulePage()));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white70,
                foregroundColor: Colors.black,
              ),
              child: const Text("Schedule"),
            ),
          ],
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
                        profile!.image!.url!.isNotEmpty)
                        ? NetworkImage(profile.image!.url!)
                        : null,
                    child: (profile?.image?.url == null ||
                        profile?.image?.url?.isEmpty == true)
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

      /// BODY
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            if (isLoading)
              const CircularProgressIndicator()
            else
              Column(
                children: [

                  buildDropdown(
                    value: selectedBuildingId,
                    hint: "Select Building",
                    items: buildings.map((e) => e['_id']).toList(),
                    labelMap: {
                      for (var b in buildings) b['_id']: b['name']
                    },
                    onChanged: (value) {
                      setState(() {
                        selectedBuildingId = value;

                        selectedFloorId = null;
                        selectedSensorLabel = 'All';

                        updateFloorsForBuilding(value);
                      });
                    },
                  ),

                  const SizedBox(height: 12),

                  buildDropdown(
                    value: selectedFloorId,
                    hint: "Select Floor",
                    items: floors.map((e) => e['_id']).toList(),
                    labelMap: {
                      for (var f in floors) f['_id']: f['label']
                    },
                    onChanged: isFloorEnabled
                        ? (value) {
                      setState(() {
                        selectedFloorId = value;

                        /// reset sensor
                        selectedSensorLabel = 'All';
                      });
                    }
                        : null,
                  ),

                  const SizedBox(height: 12),

                  buildDropdown(
                    value: selectedSensorLabel,
                    hint: "Select Sensor",
                    items: sensorMap.keys.toList(),
                    onChanged: isSensorEnabled
                        ? (value) {
                      setState(() {
                        selectedSensorLabel = value;
                      });
                    }
                        : null,
                  ),
                ],
              ),

            const SizedBox(height: 20),

            Expanded(
              child: showCard
                  ? SensorDetailScreen(
                buildingId: selectedBuildingId,
                floorId: selectedFloorId,
                deviceName:
                sensorMap[selectedSensorLabel],
              )
                  : Center(
                child: Column(
                  mainAxisAlignment:
                  MainAxisAlignment.center,
                  children: [
                    Icon(Icons.filter_list,
                        size: 60,
                        color: Colors.grey[400]),
                    const SizedBox(height: 10),
                    Text(
                      "Please select Building, Floor and Sensor",
                      style: TextStyle(
                          color: Colors.grey[600]),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// REUSABLE DROPDOWN
  Widget buildDropdown({
    required String hint,
    required List items,
    required Function(dynamic)? onChanged,
    String? value,
    Map<dynamic, String>? labelMap,
  }) {
    bool isEnabled = onChanged != null;

    return Container(
      decoration: BoxDecoration(
        color: isEnabled ? Colors.white : Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
        border:
        Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton(
          value: value,
          hint: Padding(
            padding:
            const EdgeInsets.symmetric(horizontal: 12),
            child: Text(hint),
          ),
          isExpanded: true,
          items: items.map((id) {
            return DropdownMenuItem(
              value: id,
              child: Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                    labelMap?[id] ?? id.toString()),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}