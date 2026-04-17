import 'package:dt_mobile/models/response/profile_response.dart';
import 'package:dt_mobile/pages/report_screens/report_screen.dart';
import 'package:dt_mobile/services/notification_service.dart';
import 'package:dt_mobile/services/profile_services.dart';
import 'package:dt_mobile/services/schedule_service.dart';
import 'package:dt_mobile/widgets/notification.dart';
import 'package:dt_mobile/widgets/profile_drawer.dart';
import 'package:flutter/material.dart';
import 'package:dt_mobile/widgets/date_picker.dart';
import 'package:dt_mobile/services/auth_services.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  List<String> types = [];
  List<Map<String, dynamic>> devices = [];
  List<Map<String, dynamic>> rawDevices = [];
  List<Map<String, dynamic>> buildings = [];
  List<Map<String, dynamic>> floors = [];

  String? selectedBuildingId;
  String? selectedFloorId;
  bool isLoading = false;
  bool isSubmitting = false;
  String? selectedSpace;
  String? selectedType;
  String? selectedDevice;
  int _unreadCount = 0;

  DateTime? _endDate;
  Map<String, List<bool>> _activityData = {};

  final List<String> _timeLabels = [
    '00:00', '02:00', '04:00', '06:00', '08:00', '10:00',
    '12:00', '14:00', '16:00', '18:00', '20:00', '22:00'
  ];

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
      final response = await ApiService.getRequest('/org/buildings');
      if (response['success'] == true && response['data'] != null) {
        setState(() {
          buildings = List<Map<String, dynamic>>.from(response['data']);
          selectedBuildingId = null;
          selectedFloorId = null;
          floors = [];
          types = [];
          devices = [];
          rawDevices = [];
        });
      }
    } catch (e) {
      debugPrint('❌ Building API Error: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }


  Future<void> fetchDevicesByBuilding() async {
    if (selectedBuildingId == null) return;

    setState(() => isLoading = true);

    try {
      final response = await ApiService.getRequest(
        '/org/devices?buildingId=$selectedBuildingId',
      );

      if (response['success'] == true) {
        rawDevices = List<Map<String, dynamic>>.from(response['data']);

        final uniqueTypes = rawDevices
            .map((d) => (d['deviceId'] ?? '').toString())
            .toSet()
            .toList();

        setState(() {
          types = uniqueTypes;
          selectedType = null;
          devices = [];
          selectedDevice = null;
        });
      }
    } catch (e) {
      debugPrint("Device error: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  String extractType(String deviceId) {


      return deviceId.replaceAll(RegExp(r'[0-9]'), '');
  }


  void filterDevicesByType(String? type) {
    if (type == null) return;

    final filtered = rawDevices.where((device) {
      return (device['deviceId'] ?? '') == type;
    }).toList();

    setState(() {
      devices = filtered;
      selectedDevice = null;
    });
  }

  Map<String, List<Map<String, String>>> _buildSchedulePayload() {
    Map<String, List<Map<String, String>>> result = {};

    _activityData.forEach((day, slots) {
      List<Map<String, String>> timeSlots = [];
      int? rangeStart;

      for (int i = 0; i < slots.length; i++) {
        if (slots[i] && rangeStart == null) {
          rangeStart = i;
        } else if (!slots[i] && rangeStart != null) {
          timeSlots.add({
            'startTime': _timeLabels[rangeStart],
            'endTime': _timeLabels[i],
          });
          rangeStart = null;
        }
      }
      if (rangeStart != null) {
        timeSlots.add({
          'startTime': _timeLabels[rangeStart],
          'endTime': _timeLabels[slots.length - 1],
        });
      }

      if (timeSlots.isNotEmpty) result[day] = timeSlots;
    });

    return result;
  }

  Future<void> _submitSchedule() async {
    if (_endDate == null || selectedDevice == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all fields')),
      );
      return;
    }

    final schedulePayload = _buildSchedulePayload();
    if (schedulePayload.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least one time slot')),
      );
      return;
    }

    setState(() => isSubmitting = true);

    final body = {
      "name": "$selectedDevice Schedulessss",
      "deviceId": selectedDevice,
      "expireAt": _endDate!.toIso8601String(),
      "schedule": schedulePayload,
      "timezone": DateTime.now().timeZoneName,
      "isActive": true,
    };

    final result =
    await ScheduleApiService.createSchedule(body: body);

    if (!mounted) return;

    setState(() => isSubmitting = false);

    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Schedule created successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to create schedule'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => ReportsPage())),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white70,
                foregroundColor: Colors.black,
                elevation: 5,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              child: const Text("Configuration", style: TextStyle(fontSize: 13)),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                elevation: 5,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              child: const Text("Schedule", style: TextStyle(fontSize: 13)),
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

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [

            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedBuildingId,
                          hint: const Text("Select Building"),
                          isExpanded: true,
                          icon: const Icon(Icons.keyboard_arrow_down),
                          items: buildings.map((b) {
                            return DropdownMenuItem<String>(
                              value: b['_id'],
                              child: Text(b['name'],
                                  overflow: TextOverflow.ellipsis),
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
                              selectedFloorId = null;
                              types = [];
                              selectedType = null;
                              devices = [];
                              selectedDevice = null;
                              rawDevices = [];
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Floor
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedFloorId,
                          hint: const Text("Select Floor"),
                          isExpanded: true,
                          icon: const Icon(Icons.keyboard_arrow_down),
                          items: floors.map((f) {
                            return DropdownMenuItem<String>(
                              value: f['_id'],
                              child: Text(f['label'],
                                  overflow: TextOverflow.ellipsis),
                            );
                          }).toList(),
                          onChanged: (value) async {
                            setState(() {
                              selectedFloorId = value;
                              types = [];
                              selectedType = null;
                              devices = [];
                              selectedDevice = null;
                              rawDevices = [];
                            });
                            await fetchDevicesByBuilding(); // devices fetch + types extract
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
                  child: buildDropdown(
                    value: selectedSpace,
                    hint: 'Space',
                    items: [],
                    onChanged: (v) => setState(() => selectedSpace = v),
                    enabled: false,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: buildDropdown(
                    value: selectedType,
                    hint: 'Select Type',
                    items: types,
                    enabled: types.isNotEmpty,
                    onChanged: types.isNotEmpty
                        ? (v) {
                      setState(() => selectedType = v);
                      filterDevicesByType(v);
                    }
                        : null,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            buildDropdown(
              value: selectedDevice,
              hint: 'Select Device',
              items: devices
                  .map((d) => (d['name'] ?? '').toString())
                  .toList()
                  .cast<String>(),
              enabled: devices.isNotEmpty,
              onChanged: devices.isNotEmpty
                  ? (v) => setState(() => selectedDevice = v)
                  : null,
            ),

            const SizedBox(height: 10),

            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: DatePicker(
                      onDataChanged: (endDate, activityData) {
                        _endDate = endDate;
                        _activityData = activityData;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton(
                        onPressed: isSubmitting ? null : _submitSchedule,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          elevation: 4,
                        ),
                        child: isSubmitting
                            ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                            : const Text(
                          'Submit',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          ],
        ),
      ),
    );
  }

  Widget buildDropdown({
    required String? value,
    required String hint,
    required List<String> items,
    required Function(String?)? onChanged,
    bool enabled = true,
  }) {
    return SizedBox(
      height: 36,
      child: Container(
        decoration: BoxDecoration(
          color: enabled ? Colors.white : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            hint: Text(hint),
            isExpanded: true,
            icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
            items: items
                .map((e) => DropdownMenuItem(
              value: e,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Text(e),
              ),
            ))
                .toList(),
            onChanged: enabled ? onChanged : null,
          ),
        ),
      ),
    );
  }
}