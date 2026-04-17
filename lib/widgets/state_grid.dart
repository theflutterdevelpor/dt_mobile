
import 'package:dt_mobile/widgets/state_card.dart';
import 'package:dt_mobile/models/response/dashboard_response.dart';
import 'package:flutter/material.dart';

class StatsGrid extends StatelessWidget {
  final DashboardData? dashboardData;
  final bool isLoading;

  const StatsGrid({
    super.key,
    this.dashboardData,
    this.isLoading = true,
  });

  @override
  Widget build(BuildContext context) {

    if (isLoading) {
      return GridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.1,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: List.generate(
          4,
              (index) => Card(
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ),
      );
    }


    if (dashboardData == null) {
      return const Center(child: Text('No data available'));
    }

    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.1,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        // Total Buildings
        StatCard(
          iconAssetPath: 'assets/icons/icon2.png',
          iconColor: Colors.green,
          title: 'Total Buildings',
          value: '${dashboardData!.buildings}',
          backgroundColor: Colors.white,
        ),
        // Total Floors
        StatCard(
          iconAssetPath: 'assets/icons/floor.png',
          iconColor: Colors.green,
          title: 'Total Floors',
          value: '${dashboardData!.floors}',
          backgroundColor: Colors.white,
        ),
        // Active Maintenances
        StatCard(
          iconAssetPath: 'assets/icons/active.png',
          iconColor: Colors.green,
          title: 'Active Maintenances',
          value: '${dashboardData!.inProgressComplaints}',
          backgroundColor: Colors.white,
        ),
        // Pending Maintenances
        StatCard(
          iconAssetPath: 'assets/icons/icon3.png',
          iconColor: Colors.green,
          title: 'Pending Maintenances',
          value: '${dashboardData!.pendingComplaints}',
          backgroundColor: Colors.white,
        ),
      ],
    );
  }
}