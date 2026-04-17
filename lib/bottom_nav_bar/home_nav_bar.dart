import 'package:dt_mobile/bottom_nav_bar/my_bottom_nav_bar.dart';
import 'package:dt_mobile/pages/chart_screens/chart_Pages.dart';
import 'package:dt_mobile/pages/dashboard_screens/dashboard_screen.dart';
import 'package:dt_mobile/pages/favrouite_screens/favrouite_screen.dart';
import 'package:dt_mobile/pages/favrouite_screens/maintenance_add.dart';
import 'package:dt_mobile/pages/profile_screens/profile_screen.dart';
import 'package:dt_mobile/pages/report_screens/report_screen.dart';
import 'package:dt_mobile/pages/setting_screens/setting_screen.dart';
import 'package:dt_mobile/pages/setting_screens/user_add.dart';
import 'package:dt_mobile/pages/wallet_screens/wallet_screen.dart';


import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentPageIndex = 0;

  final List<Widget> _pages = [
    DashboardPage(),
    WalletPage(),
    FavoritesPage(),
    CreateUserRoleScreen(),
    UserManagementPage(),
    ReportsPage(),
    chartPage()


  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack( index: _currentPageIndex, children: _pages, ),

      floatingActionButton: _currentPageIndex == 2 || _currentPageIndex == 4
          ? FloatingActionButton(
        backgroundColor: Colors.green,
        elevation: 4,
        shape: const CircleBorder(),
        onPressed: () {

          if (_currentPageIndex == 2) {

            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => addnew()),
            );
          } else if (_currentPageIndex == 4) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => useradd()),
            );
          }
        },
        child: Image.asset(
          "assets/icons/add.png",
          width: 30,
          height: 24,
          color: Colors.white,
        ),
      )
          : null,

      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: MyBottomNavBar(
        onItemTapped: (index) {
          setState(() {
            _currentPageIndex = index;
          });
        },
      ),
    );
  }
}