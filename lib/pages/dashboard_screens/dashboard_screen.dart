import 'dart:convert';

import 'package:dt_mobile/models/response/dashboard_response.dart';
import 'package:dt_mobile/models/response/profile_response.dart';
import 'package:dt_mobile/services/notification_service.dart';
import 'package:dt_mobile/services/profile_services.dart';
import 'package:dt_mobile/widgets/Energy-Maintenance-Card.dart';
import 'package:dt_mobile/widgets/bar_chart.dart';
import 'package:dt_mobile/widgets/dashboard_card.dart';
import 'package:dt_mobile/widgets/maintenance_card_table.dart';
import 'package:dt_mobile/widgets/notification.dart';
import 'package:dt_mobile/widgets/profile_drawer.dart';
import 'package:dt_mobile/widgets/state_grid.dart';
import 'package:dt_mobile/widgets/weather_card.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  DashboardData? dashboardData;
  bool isLoading = true;
  int _unreadCount=0;
  final String baseUrl = 'http://3.231.62.206:5000/api/v1';

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
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

  Future<void> _loadDashboardData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        print('❌ Token not found');
        setState(() => isLoading = false);
        return;
      }

      print('🔄 Dashboard API Call Start...');

      final response = await http.get(
        Uri.parse('$baseUrl/dashboard'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception('Connection timeout'),
      );

      if (response.statusCode == 200) {
        final dashboardResponse = DashboardResponse.fromJson(jsonDecode(response.body));

        print('✅ Dashboard API Success');
        print('📊 Response: ${response.body}');

        if (dashboardResponse.success && dashboardResponse.data != null) {
          setState(() {
            dashboardData = dashboardResponse.data;
            isLoading = false;
          });

          print('🏢 Buildings: ${dashboardData?.buildings}');
          print('🔧 Devices: ${dashboardData?.devices}');
          print('📝 Total Complaints: ${dashboardData?.totalComplaints}');
        } else {
          print('❌ Response success is false');
          setState(() => isLoading = false);
        }
      } else {
        print('❌ Dashboard API Error: ${response.statusCode}');
        setState(() => isLoading = false);
      }
    } catch (e) {
      print('❌ Exception: ${e.toString()}');
      setState(() => isLoading = false);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      endDrawer: const ProfileDrawer(),
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Dashboard",
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
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
               WeatherCard(),
        
               SizedBox(height: 8),

              StatsGrid(
                dashboardData: dashboardData,
                isLoading: isLoading,
              ),
              const SizedBox(height: 8),
        
              const EnergyMaintenanceCard(),
              const SizedBox(height: 8),

              const DashboardCard(),


              const SizedBox(height: 12),

              SizedBox(
                height: 350,
                child: barchart(),
              ),

              SizedBox(height: 12,),
              const MaintenanceCardTable(),


            ],
          ),
        ),
      ),
    );
  }
}