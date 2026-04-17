import 'package:dt_mobile/models/response/profile_response.dart';
import 'package:dt_mobile/pages/sensors_screen/humidity_sensor.dart';
import 'package:dt_mobile/pages/sensors_screen/tem_sensor.dart';
import 'package:dt_mobile/pages/wallet_screens/emergency_screen.dart';
import 'package:dt_mobile/services/auth_services.dart';
import 'package:dt_mobile/services/notification_service.dart';
import 'package:dt_mobile/services/profile_services.dart';
import 'package:dt_mobile/widgets/IndoorClimateCard.dart';
import 'package:dt_mobile/widgets/deviceitem_card.dart';
import 'package:dt_mobile/widgets/notification.dart';
import 'package:dt_mobile/widgets/profile_drawer.dart';
import 'package:dt_mobile/widgets/weather_card.dart';
import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

import '../sensors_screen/energy_sensor.dart';
import '../sensors_screen/gas_sensor.dart';
import '../sensors_screen/motion_sensor.dart';

class ControlPage extends StatefulWidget {
  const ControlPage({super.key});

  @override
  State<ControlPage> createState() => _ControlPageState();
}

class _ControlPageState extends State<ControlPage> {

  List<Map<String, dynamic>> buildings = [];
  List<Map<String, dynamic>> floors = [];

  String? selectedBuildingId;
  String selectedBuildingName = 'Select Building';

  String? selectedFloorId;
  String selectedFloorLabel = 'Select Floor';
  bool isLoading = false;

  String currentModel = 'assets/models/building.glb';
  bool showicons = true;
  int _unreadCount=0;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();





  bool isRoom1Expanded = false;
  bool isRoom2Expanded = false;

  final List<Map<String, dynamic>> devices = [
    {'name': 'Ceiling Fan', 'icon': Icons.air_rounded, 'isOn': true},
    {'name': 'Light Row 1', 'icon': Icons.lightbulb, 'isOn': true},
    {'name': 'Light Row 2', 'icon': Icons.lightbulb, 'isOn': true},
    {'name': 'Light Row 3', 'icon': Icons.lightbulb, 'isOn': true},
    {'name': 'Air Conditioner', 'icon': Icons.ac_unit, 'isOn': true},
    {'name': 'Computer', 'icon': Icons.computer, 'isOn': true},
    {'name': 'Wifi', 'icon': Icons.router, 'isOn': true},
    {'name': 'T.V', 'icon': Icons.tv, 'isOn': true},
  ];


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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> fetchBuildings() async {
    setState(() => isLoading = true);

    try {
      debugPrint("🚀 HIT: /org/buildings API");
      final response = await ApiService.getRequest('/org/buildings');
      debugPrint(" SUCCESS: /org/buildings Module ki API HIT HO GAYI hai");

      if (response['success'] == true && response['data'] != null) {
        final List data = response['data'];

        buildings = List<Map<String, dynamic>>.from(data);

        if (buildings.isNotEmpty) {
          final firstBuilding = buildings.first;

          selectedBuildingId = firstBuilding['_id'];
          selectedBuildingName = firstBuilding['name'];

          floors = List<Map<String, dynamic>>.from(firstBuilding['floors'] ?? []);

          if (floors.isNotEmpty) {
            selectedFloorId = floors.first['_id'];
            selectedFloorLabel = floors.first['label'];
          }
        }
      }
    } catch (e) {
      debugPrint('❌ Building API Error: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      endDrawer: const ProfileDrawer(),
      backgroundColor: Colors.grey[100],


      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          "Control",
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

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const WeatherCard(),
              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 36,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedBuildingId,
                            isExpanded: true,
                            icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                            items: buildings.map((b) {
                              return DropdownMenuItem<String>(
                                value: b['_id'],
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 6),
                                  child: Row(
                                    children: [
                                      Image.asset(
                                        'assets/icons/icon2.png',
                                        width: 18,
                                        height: 18,
                                        color: Colors.green,
                                        colorBlendMode: BlendMode.srcIn,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          b['name'],
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              final building = buildings.firstWhere((b) => b['_id'] == value);

                              setState(() {
                                selectedBuildingId = value;
                                selectedBuildingName = building['name'];

                                floors = List<Map<String, dynamic>>.from(building['floors'] ?? []);

                                if (floors.isNotEmpty) {
                                  selectedFloorId = floors.first['_id'];
                                  selectedFloorLabel = floors.first['label'];
                                } else {
                                  selectedFloorId = null;
                                  selectedFloorLabel = 'Select Floor';
                                }
                                currentModel = 'assets/models/Plot_Complete.glb';
                                showicons = false;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  Expanded(
                    child: SizedBox(
                      height: 36,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedFloorId,
                            isExpanded: true,
                            icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                            items: floors.map((f) {
                              return DropdownMenuItem<String>(
                                value: f['_id'],
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 6),
                                  child: Row(
                                    children: [
                                      Image.asset(
                                        'assets/icons/floor.png',
                                        width: 18,
                                        height: 18,
                                        color: Colors.green,
                                        colorBlendMode: BlendMode.srcIn,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          f['label'],
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedFloorId = value;
                                selectedFloorLabel = floors.firstWhere((f) => f['_id'] == value)['label'];
                                currentModel = 'assets/models/groudfloor.glb';
                                showicons = false;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 36,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child:  Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/icons/control.png',
                              width: 18,
                              height: 18,
                              color: Colors.white,
                              colorBlendMode: BlendMode.srcIn,
                            ),
                            SizedBox(width: 8),
                            Text('Control'),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  Expanded(
                    child: SizedBox(
                      height: 36,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => EmergencyPage()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.red,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.warning_amber, size: 18),
                            SizedBox(width: 8),
                            Text('Emergency'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),


              const SizedBox(height: 20),

              IndoorClimateMini(),
              const SizedBox(height: 10),

              SizedBox(
                height: 350,
                width: double.infinity,
                child: Stack(
                  children: [
                    ModelViewer(
                      key: ValueKey(currentModel),
                      src: currentModel,
                      cameraControls: false,
                      autoRotate: false,
                      shadowIntensity: 1,
                      exposure: 1,
                      ar: false,
                      // cameraOrbit: "0deg 75deg 2m",
                      // fieldOfView: "45deg",
                    ),

                    // 1. Top-left (yellow question mark)
                    if(showicons) Positioned(
                      top: 170,
                      left: 30,
                      child: IconButton(
                        icon: ImageIcon(
                          AssetImage("assets/icons/enrgy.png"),
                          color: Colors.yellow,
                        ),
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context){
                            return EnergySensorScreen();
                          }));
                        },
                      ),
                    ),

                    // 2. Left-center (orange drop)
                    if(showicons) Positioned(
                      top: 130,
                      left: 90,
                      child: IconButton(
                        icon: ImageIcon(
                          AssetImage("assets/icons/humidity.png"),
                          color: Colors.yellow,
                        ),
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context){
                            return HumiditySensorScreen();
                          }));
                        },
                      ),
                    ),

                    // 3. Center-left (orange flame)
                    if(showicons) Positioned(
                      top: 110,
                      left: 140,
                      child: IconButton(
                        icon: ImageIcon(
                          AssetImage("assets/icons/temprature.png"),
                          color: Colors.orange,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => SensorScreen()),
                          );
                        },
                      ),
                    ),

                    // 4. Center (green wifi)
                    if(showicons) Positioned(
                      top: 140,
                      left: 150,
                      child: IconButton(
                        icon: ImageIcon(
                          AssetImage('assets/icons/contact.png'),
                          color: Colors.green,
                        ),
                        onPressed: () {
                          // Action 4
                        },
                      ),
                    ),

                    // 5. Top-right (light blue wifi)
                    if(showicons) Positioned(
                      top: 60,
                      right: 60,
                      child: IconButton(
                        icon: ImageIcon(
                          AssetImage("assets/icons/gasleak.png"),
                          color: Colors.lightBlueAccent,
                        ),
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context){
                            return GasSensorScreen();
                          }));
                        },
                      ),
                    ),

                    // 6. Bottom-right (dark blue wifi)
                    if(showicons) Positioned(
                      top: 80,
                      right: 40,
                      child: IconButton(
                        icon: ImageIcon(
                          AssetImage("assets/icons/motion.png"),
                          color: Colors.blue,
                        ),
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context){
                            return MotionSensorScreen();
                          }));
                        },
                      ),
                    ),
                  ],
                ),
              ),


               SizedBox(height: 15),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Devices :",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  const SizedBox(height: 12),

                  GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    childAspectRatio: 2.4,
                    children: const [
                      DeviceItemPNG(
                        iconPath: "assets/icons/temprature.png",
                        label: "Temperature",
                        color: Colors.orange,
                      ),
                      DeviceItemPNG(
                        iconPath: "assets/icons/enrgy.png",
                        label: "Energy",
                        color: Colors.amber,
                      ),
                      DeviceItemPNG(
                        iconPath: "assets/icons/air1.png",
                        label: "Air Quality Index",
                        color: Colors.teal,
                      ),

                      DeviceItemPNG(
                        iconPath: "assets/icons/smartswitch .png",
                        label: "Smart Switch",
                        color: Colors.pink,
                      ),
                      DeviceItemPNG(
                        iconPath: "assets/icons/gasleak.png",
                        label: "Gas",
                        color: Colors.blue,
                      ),
                      DeviceItemPNG(
                        iconPath: "assets/icons/hubgateway.png",
                        label: "Hub",
                        color: Colors.green,
                      ),

                      DeviceItemPNG(
                        iconPath: "assets/icons/smokesensor.png",
                        label: "Smoke Sensor",
                        color: Colors.purple,
                      ),
                      DeviceItemPNG(
                        iconPath: "assets/icons/motion.png",
                        label: "Motion",
                        color: Colors.blue,
                      ),
                      DeviceItemPNG(
                        iconPath: "assets/icons/contact.png",
                        label: "Contact",
                        color: Colors.green,
                      ),
                      DeviceItemPNG(
                        iconPath: "assets/icons/humidity.png",
                        label: "Humidity",
                        color: Colors.orangeAccent,
                      ),
                    ],
                  )
                ],
              ),


              const SizedBox(height: 20),

              Row(
                children: [
                  const Text(
                    "Manage Spaces",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),

                  const Spacer(),

                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 30,
                      child: TextField(
                        controller: _searchController,
                        cursorColor: Colors.green,
                        enableInteractiveSelection: false,
                        onChanged: (value){

                        },
                        decoration: InputDecoration(
                          hintText: "Search",
                          contentPadding: EdgeInsets.symmetric(horizontal: 10),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50),
                            borderSide: BorderSide(color: Colors.green, width: 1),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),


              const SizedBox(height: 20),


              Card(
                elevation: 4,
                shadowColor: Colors.black26,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isRoom1Expanded = !isRoom1Expanded;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.asset(
                                "assets/images/profile.png",
                                width: 110,
                                height: 80,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Adeel's Room",
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 30),
                                  Text("${devices.length} Devices",
                                      style: TextStyle(color: Colors.grey[700])),
                                ],
                              ),
                            ),
                            Icon(
                              isRoom1Expanded
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                            ),
                          ],
                        ),
                      ),
                    ),

                    if (isRoom1Expanded)
                      _buildDeviceList(),
                  ],
                ),
              ),


              Card(
                elevation: 4,
                shadowColor: Colors.black26,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isRoom2Expanded = !isRoom2Expanded;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.asset(
                                "assets/images/profile.png",
                                width: 110,
                                height: 80,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "PM Room 1",
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 30),
                                  Text("${devices.length} Devices",
                                      style: TextStyle(color: Colors.grey[700])),
                                ],
                              ),
                            ),
                            Icon(
                              isRoom2Expanded
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                            ),
                          ],
                        ),
                      ),
                    ),

                    if (isRoom2Expanded)
                      _buildDeviceList(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildDeviceList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Divider(color: Colors.grey[300]),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: devices.length,
            itemBuilder: (context, index) {
              final device = devices[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  height: 60,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.green[300]!, width: 1.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(device['icon'], size: 20),
                          const SizedBox(width: 12),
                          Text(device['name']),
                        ],
                      ),
                      Switch(
                        value: device['isOn'],
                        onChanged: (value) {
                          setState(() {
                            device['isOn'] = value;
                          });
                        },
                        activeThumbColor: Colors.green,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}





