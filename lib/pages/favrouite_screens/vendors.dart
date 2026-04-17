import 'package:dt_mobile/models/response/profile_response.dart';
import 'package:dt_mobile/pages/favrouite_screens/favrouite_screen.dart';
import 'package:dt_mobile/services/profile_services.dart';
import 'package:dt_mobile/widgets/notification.dart';
import 'package:flutter/material.dart';

// ==================== SAMPLE DATA ====================
final List<Map<String, dynamic>> raw_data = List.generate(60, (index) {
  final statuses = ["Open", "In Progress", "Resolved"];
  final types = ["Electrical", "Plumbing", "AC Repair", "Lift Issue", "Painting", "Cleaning"];
  final names = ["John Doe", "Alice", "Mike", "Sarah", "Tom", "Emma", "Rahul", "Priya"];

  return {
    "date": "2025-${12 - (index % 10)}-${28 - (index % 25)}",
    "type": types[index % types.length],
    "reported_by": names[index % names.length],
    "status": statuses[index % 3],
  };
});

// ==================== MAIN VENDORS PAGE ====================
class VendorsPage extends StatefulWidget {
  const VendorsPage({super.key});

  @override
  State<VendorsPage> createState() => _VendorsPageState();
}

class _VendorsPageState extends State<VendorsPage> {
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late MyData _dataSource;

  @override
  void initState() {
    super.initState();
    _dataSource = MyData(data: raw_data, ctx: context);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return FavoritesPage();
                }));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white70,
                foregroundColor: Colors.black,
                elevation: 5,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              child: const Text("Maintenances", style: TextStyle(fontSize: 13)),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                elevation: 5,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              child: const Text("Vendors", style: TextStyle(fontSize: 13)),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return NotificationScreen();
              }));
            },
            icon: const Icon(Icons.notifications_none, color: Colors.black),
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              SizedBox(
                width: 418,
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    _dataSource.filter(value);
                  },
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: Card(
                          elevation: 6,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: PaginatedDataTable(
                            headingRowColor: WidgetStateProperty.all(Colors.green),
                            columns: const [
                              DataColumn(
                                label: Text("Date",
                                    style: TextStyle(color: Colors.white)),
                              ),
                              DataColumn(
                                label: Text("Type",
                                    style: TextStyle(color: Colors.white)),
                              ),
                              DataColumn(
                                label: Text("Reported by",
                                    style: TextStyle(color: Colors.white)),
                              ),
                              DataColumn(
                                label: Text("Status",
                                    style: TextStyle(color: Colors.white)),
                              ),
                            ],
                            source: _dataSource,
                            rowsPerPage: 7,
                            columnSpacing: 40,
                            horizontalMargin: 24,
                            showFirstLastButtons: true,
                            showCheckboxColumn: false,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// ==================== DATA SOURCE WITH CONTEXT ====================
class MyData extends DataTableSource {
  List<Map<String, dynamic>> _originalData;
  List<Map<String, dynamic>> _filteredData;
  late BuildContext context;

  MyData({required List<Map<String, dynamic>> data, required BuildContext ctx})
      : _originalData = data,
        _filteredData = List.from(data) {
    context = ctx;
  }

  void filter(String query) {
    if (query.isEmpty) {
      _filteredData = List.from(_originalData);
    } else {
      _filteredData = _originalData.where((row) {
        return row.values.any((value) =>
            value.toString().toLowerCase().contains(query.toLowerCase()));
      }).toList();
    }
    notifyListeners();
  }

  @override
  DataRow getRow(int index) {
    if (index >= _filteredData.length) return const DataRow(cells: []);

    final row = _filteredData[index];
    final status = row['status'];

    Color statusColor;
    switch (status) {
      case 'Resolved':
        statusColor = Colors.green;
        break;
      case 'In Progress':
        statusColor = Colors.orange;
        break;
      case 'Open':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }

    return DataRow(
      cells: [
        DataCell(Text(row['date'], style: const TextStyle(fontSize: 13))),
        DataCell(Text(row['type'], style: const TextStyle(fontSize: 13))),
        DataCell(Text(row['reported_by'], style: const TextStyle(fontSize: 13))),
        DataCell(
          GestureDetector(
            onTap: () {
              if (row['status'] == 'Open') {
                row['status'] = 'In Progress';
              } else if (row['status'] == 'In Progress') {
                row['status'] = 'Resolved';
              } else {
                row['status'] = 'Open';
              }
              notifyListeners();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                row['status'],
                style: const TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => _filteredData.length;

  @override
  int get selectedRowCount => 0;
}