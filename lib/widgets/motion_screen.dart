import 'package:dt_mobile/models/response/device_response.dart';
import 'package:dt_mobile/models/response/motion_model.dart';
import 'package:dt_mobile/services/device_service.dart';
import 'package:dt_mobile/services/motion_detectionservice.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MotionScreen extends StatefulWidget {
  const MotionScreen({super.key});

  @override
  State<MotionScreen> createState() => _MotionScreenState();
}

class _MotionScreenState extends State<MotionScreen> {
  // ================= DATE =================
  List<DateTime> dates = [];
  List<DateTime> disabledDates = [];
  DateTime selectedDate = DateTime.now();

  // ================= STATE =================
  bool isLoading = true;
  List<DeviceModel> devices = [];

  // 🔥 REALTIME MOTION EVENTS
  final List<MotionEvent> realtimeEvents = [];
  final Set<String> _boundEvents = {};

  // ================= INIT =================
  @override
  void initState() {
    super.initState();
    _generateDates();
    _init();
  }

  Future<void> _init() async {
    await _initSocket();
    await _fetchMotionDevices();
  }

  @override
  void dispose() {
    for (final event in _boundEvents) {
      RealtimeSocketService.off(event);
    }
    RealtimeSocketService.disconnect();
    super.dispose();
  }

  // ================= SOCKET =================
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> _initSocket() async {
    final token = await _getToken();
    if (token == null) return;
    RealtimeSocketService.connect(token);
  }

  // ================= DATE =================
  void _generateDates() {
    final today = DateTime.now();
    dates.clear();
    disabledDates.clear();

    for (int i = -3; i <= 3; i++) {
      final date = today.add(Duration(days: i));
      if (i > 0) disabledDates.add(date);
      dates.add(date);
    }

    selectedDate = today;
  }

  bool _isSelected(DateTime date) =>
      DateUtils.isSameDay(selectedDate, date);

  bool _isDisabled(DateTime date) =>
      disabledDates.any((d) => DateUtils.isSameDay(d, date));

  // ================= TIME FORMATTER =================
  /// Always returns time like: 12:04 AM / PM
  String _formatTime(dynamic rawTime) {
    try {
      DateTime time;

      // ISO string from backend
      if (rawTime is String && rawTime.contains('T')) {
        time = DateTime.parse(rawTime);
      }
      // Already formatted string
      else if (rawTime is String) {
        return rawTime.toUpperCase();
      }
      // fallback
      else {
        time = DateTime.now();
      }

      return DateFormat('hh:mm a').format(time);
    } catch (_) {
      return DateFormat('hh:mm a').format(DateTime.now());
    }
  }

  // ================= API =================
  Future<void> _fetchMotionDevices() async {
    try {
      setState(() => isLoading = true);

      final allDevices = await DeviceService.getDevices();

      // ✅ ONLY MOTION (PIR)
      final motionDevices = allDevices
          .where((d) => d.deviceId.startsWith('PIR'))
          .toList();

      setState(() {
        devices = motionDevices;
        isLoading = false;
      });

      _bindMotionSocketEvents();
    } catch (e) {
      debugPrint('Device error: $e');
      setState(() {
        devices = [];
        isLoading = false;
      });
    }
  }

  // ================= SOCKET BINDING =================
  void _bindMotionSocketEvents() {
    for (final device in devices) {
      final eventName = 'MotionDetectorSensor-${device.deviceId}';

      if (_boundEvents.contains(eventName)) continue;

      debugPrint('👂 Listening MOTION: $eventName');

      RealtimeSocketService.on(eventName, (data) {
        if (!mounted) return;

        // ✅ Sirf real motion
        if (data['motion'] != true) return;

        final motion = MotionEvent(
          deviceId: data['deviceId'], // 🔥 realtime
          deviceName: data['deviceName'] ?? 'Motion Detector',
          roomName: data['roomName'] ?? 'Unknown Room',
          time: _formatTime(data['realDetectionTime']),
        );

        setState(() {
          realtimeEvents.insert(0, motion);

          if (realtimeEvents.length > 100) {
            realtimeEvents.removeLast();
          }
        });
      });

      _boundEvents.add(eventName);
    }
  }


  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    final List<MotionEvent> motionList = realtimeEvents;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          // ================= DATE SELECTOR =================
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: dates.length,
              itemBuilder: (context, index) {
                final date = dates[index];
                final selected = _isSelected(date);
                final disabled = _isDisabled(date);

                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  padding: const EdgeInsets.all(10),
                  width: 65,
                  decoration: BoxDecoration(
                    color: selected ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(60),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        DateFormat('d').format(date),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: disabled ? Colors.grey : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('EEE').format(date),
                        style: TextStyle(
                          fontSize: 12,
                          color: disabled ? Colors.grey : Colors.black,
                        ),
                      ),
                      if (selected)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          height: 4,
                          width: 4,
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),

          // ================= EVENTS =================
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : motionList.isEmpty
                ? const Center(child: Text('No motion detected'))
                : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: motionList.length,
              itemBuilder: (context, index) {
                final motion = motionList[index];

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Card(
                    elevation: 2,
                    color: Colors.green[100],
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(
                          left: BorderSide(
                            color: Colors.green.shade400,
                            width: 3,
                          ),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 80,
                              child: Text(
                                motion.time, // ✅ 12:04 AM
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    motion.deviceName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    motion.roomName,
                                    style: TextStyle(
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
