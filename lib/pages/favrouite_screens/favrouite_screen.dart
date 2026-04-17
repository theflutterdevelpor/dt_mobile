import 'package:dt_mobile/models/response/complain_response.dart';
import 'package:dt_mobile/models/response/profile_response.dart';
import 'package:dt_mobile/pages/favrouite_screens/vendors.dart';
import 'package:dt_mobile/services/complaint_services.dart';
import 'package:dt_mobile/services/notification_service.dart';
import 'package:dt_mobile/services/profile_services.dart';

import 'package:dt_mobile/widgets/notification.dart';
import 'package:dt_mobile/widgets/profile_drawer.dart';
import 'package:flutter/material.dart';



class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late Future<List<Complaint>> _future;
  final MaintenanceApi _api = MaintenanceApi();
  List<Complaint> _allComplaints = [];
  List<Complaint> _filteredComplaints = [];
  int _unreadCount =0;

  @override
  void initState() {
    super.initState();
    _loadData();
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
  void _loadData() {
  final fromDate = "2000-01-01";
  final now = DateTime.now();

  final toDate =
      "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

  setState(() {
    _future = _api.getComplaints(
      fromDate: fromDate,
      toDate: toDate,
    );
  });

  print(" Loading ALL complaints from $fromDate to $toDate");
}

  void _refreshData() {
    print(" Refreshing complaints data...");
    _loadData();
  }

  void _filterComplaints(String query) {
    if (query.isEmpty) {
      _filteredComplaints = List.from(_allComplaints);
    } else {
      _filteredComplaints = _allComplaints.where((complaint) {
        return complaint.title.toLowerCase().contains(query.toLowerCase()) ||
            complaint.name.toLowerCase().contains(query.toLowerCase()) ||
            complaint.status.toLowerCase().contains(query.toLowerCase());
      }).toList();
    }
    setState(() {});
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      endDrawer: const ProfileDrawer(),
      resizeToAvoidBottomInset: true,
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
                elevation: 5,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              child: const Text("Maintenances", style: TextStyle(fontSize: 13)),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context){
                  return VendorsPage();
                }));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white70,
                foregroundColor: Colors.black,
                elevation: 5,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              child: const Text("Vendors", style: TextStyle(fontSize: 13)),
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // SEARCH BAR
              SizedBox(
                width: 418,
                child: TextField(
                  controller: _searchController,
                  cursorColor: Colors.green,
                  enableInteractiveSelection: false,
                  onChanged: (value) {
                    _filterComplaints(value);
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

              // TABLE CARD
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
                          child: FutureBuilder<List<Complaint>>(
                            future: _future,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(24),
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              }

                              if (snapshot.hasError) {
                                return Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(24),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.error_outline, size: 48, color: Colors.red),
                                        const SizedBox(height: 16),
                                        Text(
                                          'Error: ${snapshot.error}',
                                          style: const TextStyle(color: Colors.red),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }

                              _allComplaints = snapshot.data ?? [];

                              // Initialize filtered complaints if search is empty
                              if (_searchController.text.isEmpty) {
                                _filteredComplaints = _allComplaints;
                              }

                              print("Total complaints: ${_allComplaints.length}");
                              print(" Filtered complaints: ${_filteredComplaints.length}");

                              if (_filteredComplaints.isEmpty) {
                                return Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(24),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
                                        const SizedBox(height: 16),
                                        const Text(
                                          'No complaints found',
                                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          _allComplaints.isEmpty
                                              ? 'No data available for the last 30 days'
                                              : 'Try adjusting your search',
                                          style: const TextStyle(fontSize: 14, color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }

                              return PaginatedDataTable(
                                headingRowColor:
                                WidgetStateProperty.all(Colors.green),
                                columns: const [
                                  DataColumn(
                                      label: Text("Date",
                                          style:
                                          TextStyle(color: Colors.white))),
                                  DataColumn(
                                      label: Text("Type",
                                          style:
                                          TextStyle(color: Colors.white))),
                                  DataColumn(
                                      label: Text("Reported by",
                                          style:
                                          TextStyle(color: Colors.white))),
                                  DataColumn(
                                      label: Text("Status",
                                          style:
                                          TextStyle(color: Colors.white))),
                                ],
                                source: MyMaintenanceData(
                                    _filteredComplaints, context, _refreshData),
                                rowsPerPage: 7,
                                columnSpacing: 40,
                                horizontalMargin: 24,
                                showFirstLastButtons: true,
                                showCheckboxColumn: false,
                              );
                            },
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

// ==================== HELPER FUNCTIONS ====================
String _formatDate(DateTime date) {
  final localDate = date.toLocal();
  return "${localDate.day.toString().padLeft(2, '0')}/"
      "${localDate.month.toString().padLeft(2, '0')}/"
      "${localDate.year}";
}

String _formatTime(DateTime date) {
  final localDate = date.toLocal();
  final hour = localDate.hour % 12 == 0 ? 12 : localDate.hour % 12;
  final minute = localDate.minute.toString().padLeft(2, '0');
  final period = localDate.hour >= 12 ? "PM" : "AM";
  return "$hour:$minute $period";
}


Color _getPriorityColor(String? priority) {
  if (priority == null) return Colors.grey;

  switch (priority.toLowerCase()) {
    case 'high':
      return Colors.red;
    case 'medium':
      return Colors.orange;
    case 'low':
      return Colors.green;
    default:
      return Colors.grey;
  }
}

void _showComplainDialog(Complaint complaint, BuildContext context,VoidCallback onStatusChanged) {
  print("Images: ${complaint.images}");
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) => Dialog(
      insetPadding: EdgeInsets.zero,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Column(
            children: [
               Text('Complain Detail', style: TextStyle(color: Colors.green, fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
          leading: IconButton(
            icon:  Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          padding:  EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                height: 300,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey[200], // Background color
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _buildComplaintImage(complaint),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Complain ID: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 30),
                  Text(complaint.compliantId ?? complaint.id),
                ],
              ),
              SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Date of Complain: ', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(width: 8),
                  Text(_formatDate(complaint.createdAt)),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Time: ', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(width: 8),
                  Text(_formatTime(complaint.createdAt)),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Reported By: ', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(width: 8),
                  Text(complaint.name),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Priority: ', style: TextStyle(fontWeight: FontWeight.bold,)),
                  SizedBox(width: 8),
                  Text(
                    complaint.priority ?? 'N/A',
                    style: TextStyle(
                      color: _getPriorityColor(complaint.priority),
                    ),
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Email: ', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      complaint.email ?? 'N/A',
                      textAlign: TextAlign.right,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //   children: [
              //     Text('Contact: ', style: TextStyle(fontWeight: FontWeight.bold)),
              //     SizedBox(width: 8),
              //     Text('+92-321-1938219'),
              //   ],
              // ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Type: ', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(width: 8),
                  Text(complaint.title),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Description: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      complaint.description ?? 'No description provided',
                      textAlign: TextAlign.right,
                      softWrap: true,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),


              SizedBox(height: 20,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[

                  Expanded(
                    child: OutlinedButton(
                      onPressed: ()async {
                        try {
                          bool success = await MaintenanceApi().changeComplaintStatus(
                            complaintId: complaint.id,
                            status: 'rejected',
                          );

                          if (success) {
                            Navigator.pop(context);
                            onStatusChanged();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Complaint rejected'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: $e')),
                          );
                        }
                      },
                      style: OutlinedButton.styleFrom(

                        minimumSize: const Size.fromHeight(44),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                      child: const Text(
                        'Decline',
                        style: TextStyle(fontSize: 18, color: Colors.black),
                      ),
                    ),
                  ),


                  const SizedBox(width: 15),


                  Expanded(
                    child: ElevatedButton(
                      onPressed: ()async {
                        try {
                          bool success = await MaintenanceApi().changeComplaintStatus(
                            complaintId: complaint.id,
                            status: 'in-progress',
                          );

                          if (success) {
                            Navigator.pop(context);
                            onStatusChanged();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Complaint accepted'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: $e')),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,

                        minimumSize: const Size.fromHeight(44),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: const Text(
                        'Accept',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              )

            ],
          ),
        ),
      ),
    ),
  );
}


Widget _buildComplaintImage(Complaint complaint) {

  if (complaint.images == null || complaint.images!.isEmpty) {
    print(" No images found, showing placeholder");
    return Image.asset(
      'assets/images/building.png',
      fit: BoxFit.cover,
    );
  }

  String imageUrl = complaint.images!.first;
  print(" Attempting to load image: $imageUrl");


  if (!imageUrl.startsWith('http')) {
    imageUrl = 'http://3.231.62.206:5000$imageUrl';
    print("🔗 Fixed URL: $imageUrl");
  }

  return Image.network(
    imageUrl,
    fit: BoxFit.cover,
    loadingBuilder: (context, child, loadingProgress) {
      if (loadingProgress == null) return child;
      return Center(
        child: CircularProgressIndicator(
          value: loadingProgress.expectedTotalBytes != null
              ? loadingProgress.cumulativeBytesLoaded /
              loadingProgress.expectedTotalBytes!
              : null,
        ),
      );
    },
    errorBuilder: (context, error, stackTrace) {
      print(" Image loading error: $error");
      return Image.asset(
        'assets/images/building.png',
        fit: BoxFit.cover,
      );
    },
  );
}

// ==================== DATA SOURCE WITH CONTEXT ====================
class MyMaintenanceData extends DataTableSource {
  final List<Complaint> complaints;
  final BuildContext context;
  final VoidCallback onRefresh;

  MyMaintenanceData(this.complaints, this.context, this.onRefresh);

  String formatDate(DateTime date) {
    final localDate = date.toLocal();
    return "${localDate.day.toString().padLeft(2, '0')}/"
        "${localDate.month.toString().padLeft(2, '0')}/"
        "${localDate.year}";
  }

  String formatTime(DateTime date) {
    final localDate = date.toLocal();
    final hour = localDate.hour % 12 == 0 ? 12 : localDate.hour % 12;
    final minute = localDate.minute.toString().padLeft(2, '0');
    final period = localDate.hour >= 12 ? "PM" : "AM";
    return "$hour:$minute $period";
  }


  @override
  DataRow getRow(int index) {
    final complaint = complaints[index];

    Color _getStatusColor(String status) {
      switch (status.toLowerCase()) {
        case 'open':
          return Colors.blue;
        case 'in-progress':
          return Colors.orange;
        case 'resolved':
          return Colors.green;
        case 'rejected':
          return Colors.red;
        default:
          return Colors.grey;
      }
    }



    return DataRow(
      cells: [
        DataCell(
          GestureDetector(
            onTap: () => _showComplainDialog(complaint, context, onRefresh),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  formatDate(complaint.createdAt),
                  style: const TextStyle(fontSize: 13),
                ),
                const SizedBox(height: 1),
                Text(
                  formatTime(complaint.createdAt),
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
        DataCell(
          GestureDetector(
            onTap: () => _showComplainDialog(complaint, context, onRefresh),
            child: Text(complaint.title),
          ),
        ),
        DataCell(
          GestureDetector(
            onTap: () => _showComplainDialog(complaint, context, onRefresh),
            child: Text(complaint.name),
          ),
        ),
        DataCell(StatefulBuilder(builder: (context, setStateCell) {
          return PopupMenuButton<String>(
            initialValue: complaint.status,
            onSelected: (newStatus) async {
              final oldStatus = complaint.status;
              final index = complaints.indexOf(complaint);

              if (index != -1) {
                setStateCell(() {
                  complaints[index] = complaint.copyWith(
                    status: newStatus.toLowerCase(),
                  );
                  notifyListeners();
                });
              }

              try {
                bool success = await MaintenanceApi().changeComplaintStatus(
                  complaintId: complaint.id,
                  status: newStatus.toLowerCase(),
                );

                if (success) {
                  onRefresh();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Status updated to ${newStatus.toLowerCase()}'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else if (index != -1) {

                  setStateCell(() {
                    complaints[index] = complaint.copyWith(status: oldStatus);
                  });
                  ScaffoldMessenger.of(context)
                      .showSnackBar(const SnackBar(content: Text("Failed to update status")));
                }
              } catch (e) {
                if (index != -1) {
                  setStateCell(() {
                    complaints[index] = complaint.copyWith(status: oldStatus);
                  });
                }
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text("Error: $e")));
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'open', child: Text('Open')),
              PopupMenuItem(value: 'in-progress', child: Text('In-Progress')),
              PopupMenuItem(value: 'resolved', child: Text('Resolved')),
              PopupMenuItem(value: 'rejected', child: Text('Rejected')),
            ],
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getStatusColor(complaint.status).withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(complaint.status,
                  style: const TextStyle(
                    fontSize: 12,
                  )),
            ),
          );
        })),
      ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => complaints.length;

  @override
  int get selectedRowCount => 0;
}



// void _loadData() {
//   final fromDate = "2000-01-01"; // very old date
//   final now = DateTime.now();
//
//   final toDate =
//       "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
//
//   setState(() {
//     _future = _api.getComplaints(
//       fromDate: fromDate,
//       toDate: toDate,
//     );
//   });
//
//   print("📅 Loading ALL complaints from $fromDate to $toDate");
// }
