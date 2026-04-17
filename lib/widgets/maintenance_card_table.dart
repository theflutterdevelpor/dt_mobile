import 'package:dt_mobile/services/complaint_services.dart';
import 'package:flutter/material.dart';
import 'package:dt_mobile/models/response/complain_response.dart';


class MaintenanceCardTable extends StatefulWidget {
  const MaintenanceCardTable({super.key});

  @override
  State<MaintenanceCardTable> createState() => _MaintenanceCardTableState();
}

class _MaintenanceCardTableState extends State<MaintenanceCardTable> {
  String selectedFilter = "Today";
  late Future<List<Complaint>> _future;
  final MaintenanceApi _api = MaintenanceApi();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final range = getDateRange(selectedFilter);
    _future = _api.getComplaints(
      fromDate: range['fromDate']!,
      toDate: range['toDate']!,
    );
  }

  String dateFormat(DateTime date) =>
      "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";


  Map<String, String> getDateRange(String dateFilter) {
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);

    DateTime fromDate, toDate;

    switch (dateFilter) {
      case 'Yesterday':
        fromDate = today.subtract(const Duration(days: 1));
        toDate = fromDate;
        break;
      case 'Week':
        fromDate = today.subtract(const Duration(days: 6));
        toDate = today;
        break;
      case '30 Days':
        fromDate = today.subtract(const Duration(days: 29));
        toDate = today;
        break;
      case '6 Months':
        fromDate = DateTime(
          now.year,
          now.month - 6,
          now.day,
        );
        toDate = now;
        break;
      default:
        fromDate = today;
        toDate = today;
    }

    return {
      'fromDate': dateFormat(fromDate),
      'toDate': dateFormat(toDate),
    };
  }

  final List<String> filterOptions = ["Today", "Yesterday", "Week", "30 Days","6 Months",];

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER + DROPDOWN
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                        onPressed: () {},
                        icon: Image.asset(
                          'assets/icons/icon3.png',
                          width: 20,
                          height: 20,
                        )),
                    const SizedBox(width:1),
                    const Text(
                      "Maintenances",
                      style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black12),
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                  ),
                  child: PopupMenuButton<String>(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          selectedFilter,
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                        const Icon(Icons.keyboard_arrow_down, size: 20),
                      ],
                    ),
                    onSelected: (String value) {
                      setState(() {
                        selectedFilter = value;
                        _loadData();
                      });
                    },
                    itemBuilder: (BuildContext context) {
                      return filterOptions.map((String choice) {
                        return PopupMenuItem<String>(
                          value: choice,
                          child: Text(
                            choice,
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w500),
                          ),
                        );
                      }).toList();
                    },
                    padding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ),

          /// 🔹 TABLE WITH API DATA
          FutureBuilder<List<Complaint>>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                );
              }

              if (snapshot.hasError) {
                return Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(snapshot.error.toString()),
                );
              }

              final complaints = snapshot.data ?? [];

              return PaginatedDataTable(
                headingRowColor:
                WidgetStateProperty.all(Colors.green),
                columns: const [
                  DataColumn(label: Text("Date", style: TextStyle(color: Colors.white))),
                  DataColumn(label: Text("Type", style: TextStyle(color: Colors.white))),
                  DataColumn(label: Text("Reported by", style: TextStyle(color: Colors.white))),
                  DataColumn(label: Text("Status", style: TextStyle(color: Colors.white))),
                ],
                source: MyMaintenanceData(complaints),
                rowsPerPage: 7,
                columnSpacing: 40,
                horizontalMargin: 24,
                showFirstLastButtons: true,
                showCheckboxColumn: false,
              );
            },
          ),
        ],
      ),
    );
  }
}


// ===================================================
// 🔽 DATA SOURCE (same as before)
// ===================================================

class MyMaintenanceData extends DataTableSource {

  String formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/"
        "${date.month.toString().padLeft(2, '0')}/"
        "${date.year}";
  }

  String formatTime(DateTime date) {
    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? "PM" : "AM";
    return "$hour:$minute $period";
  }
  final List<Complaint> complaints;

  MyMaintenanceData(this.complaints);

  @override
  DataRow getRow(int index) {
    final complaint = complaints[index];

    final status = complaint.status.toLowerCase().trim();

    Color color;
    switch (status) {
      case "resolved":
        color = Colors.green;
        break;
      case "rejected":
        color = Colors.red;
        break;
      case "in-progress":
      case "in_progress": // backend underscore ho sakta hai
        color = Colors.orange;
        break;
      case "open":
        color = Colors.blue;
        break;
      default:
        color = Colors.grey;
    }


    return DataRow(
      cells: [
        DataCell(
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                formatDate(complaint.createdAt),
                style:  TextStyle(fontSize: 13),
              ),
               SizedBox(height: 1),
              Text(
                formatTime(complaint.createdAt),
                style:  TextStyle(
                  fontSize: 11,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),

        DataCell(Text(complaint.title)),
        DataCell(Text(complaint.name)),
        DataCell(
          Container(
            padding:  EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              complaint.status,
              style:  TextStyle(fontSize: 12),
            ),
          ),
        ),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => complaints.length;

  @override
  int get selectedRowCount => 0;
}

