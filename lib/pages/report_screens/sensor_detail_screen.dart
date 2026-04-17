import 'package:dt_mobile/models/response/device_response.dart';
import 'package:dt_mobile/services/device_service.dart';
import 'package:flutter/material.dart';

class SensorDetailScreen extends StatefulWidget {
  final String? buildingId;
  final String? floorId;
  final String? deviceName;
  const SensorDetailScreen({
    super.key,
    this.buildingId,
    this.floorId,
    this.deviceName,
  });

  @override
  State<SensorDetailScreen> createState() => _SensorDetailScreenState();
}

class _SensorDetailScreenState extends State<SensorDetailScreen> {
  List<DeviceModel> devices = [];
  List<Map<String, dynamic>> _sensorData = [];
  DeviceModel? device;
  int selectedDeviceIndex = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDevices();
  }

  @override
  void didUpdateWidget(covariant SensorDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.buildingId != widget.buildingId ||
        oldWidget.floorId != widget.floorId ||
        oldWidget.deviceName != widget.deviceName) {
      fetchDevices();
    }
  }

  Future<void> fetchDevices() async {
    setState(() => isLoading = true);

    try {

      print("\n🔄 Fetching devices with filters:");
      print("   Building: ${widget.buildingId}");
      print("   Floor: ${widget.floorId}");
      print("   Device Type: ${widget.deviceName}");
      final result = await DeviceService.getFilteredDevicesLocal(
        buildingId: widget.buildingId!,
        floorId: widget.floorId,
        deviceName: widget.deviceName,
      );

      debugPrint("FILTERED COUNT: ${result.length}");


      if (result.isNotEmpty) {
        devices = result;
        selectedDeviceIndex = 0;

        device = devices[selectedDeviceIndex];
        _loadSensorData();


      } else {
        devices = [];
        device = null;
        _sensorData = [];
      }

      setState(() => isLoading = false);
    } catch (e) {
      debugPrint("Device fetch error: $e");
      setState(() => isLoading = false);
    }
  }

  void _loadSensorData() {
    if (devices.isEmpty) return;

    final device = devices[selectedDeviceIndex];
    _sensorData = device.sensors
        .map((s) => {
      'id': s.id ?? '',
      'name': s.name,
      'unit': s.unit,
      'min': s.minThreshold.toString(),
      'max': s.maxThreshold.toString(),
      'actions': true,
    })
        .toList();
  }



  int _rowsPerPage = 5;
  int _sortColumnIndex = 0;
  bool _sortAscending = true;
  int? _editingIndex;

  @override
  Widget build(BuildContext context) {

    if (isLoading) {
      return  Center(
          child: CircularProgressIndicator(),
      );
    }

    if (_sensorData.isEmpty) {
      return Container(
        color: Colors.grey[100],
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.devices_other,
                size: 64,
                color: Colors.grey,
              ),
              SizedBox(height: 16),
              Text(
                'No device found',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Please select building, floor, or sensor type',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  color: Colors.white,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                         Text(
                           device?.name ?? 'Unknown Device',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),

                        const SizedBox(height: 16),

                        Text(
                          "ID: ${device?.deviceId ?? 'N/A'}",
                          style: const TextStyle(color: Colors.blue),
                        ),

                        const SizedBox(height: 20),

                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[200]!),
                            borderRadius: BorderRadius.circular(6),
                            color: Colors.grey[100],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Building:',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(width: 50),
                                   Expanded(
                                    child: Text(
                                      device!.building?.name ?? 'N/A',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 8),

                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Floor:',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(width: 71),
                                   Expanded(
                                    child: Text(
                                      device!.floor?.label ?? 'N/A',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 8),

                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Room:',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                   Expanded(
                                    child: Text(
                                      '',
                                      style: TextStyle(fontSize: 15),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                         Text(
                           "Sensors (${_sensorData.length})",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 10),

                        LayoutBuilder(
                          builder: (context, constraints) {
                            final headingRowHeight = 56.0;
                            final dataRowHeight = 48.0;
                            final paginationRowHeight = 56.0;

                            double tableHeight = headingRowHeight +
                                (dataRowHeight * _rowsPerPage.clamp(1, _sensorData.length)) +
                                paginationRowHeight +
                                10;

                            return SizedBox(
                              width: double.infinity,
                              height: tableHeight,
                              child: Card(
                                elevation: 6,
                                color: Colors.grey[50],
                                margin: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(color: Colors.grey[300]!),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: SingleChildScrollView(
                                  child: PaginatedDataTable(
                                    header: const SizedBox.shrink(),
                                    rowsPerPage: _rowsPerPage,
                                    availableRowsPerPage: const [2, 5, 10, 20, 50],
                                    onRowsPerPageChanged: (value) {
                                      setState(() {
                                        _rowsPerPage = value ?? 2;
                                      });
                                    },
                                    sortColumnIndex: _sortColumnIndex,
                                    sortAscending: _sortAscending,
                                    onSelectAll: (value) {},
                                    columnSpacing: 40,
                                    horizontalMargin: 12,
                                    headingRowHeight: 48,
                                    columns: [
                                      const DataColumn(
                                        label: Text(
                                          'Name',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        label: const Text(
                                          'Unit',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                        onSort: (columnIndex, ascending) {
                                          setState(() {
                                            _sortColumnIndex = columnIndex;
                                            _sortAscending = ascending;
                                            _sensorData.sort((a, b) {
                                              return ascending
                                                  ? a['unit'].compareTo(b['unit'])
                                                  : b['unit'].compareTo(a['unit']);
                                            });
                                          });
                                        },
                                      ),
                                      DataColumn(
                                        label: const Text(
                                          'Min',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                        numeric: true,
                                        onSort: (columnIndex, ascending) {
                                          setState(() {
                                            _sortColumnIndex = columnIndex;
                                            _sortAscending = ascending;
                                            _sensorData.sort((a, b) {
                                              final aMin = double.tryParse(a['min']) ?? 0;
                                              final bMin = double.tryParse(b['min']) ?? 0;
                                              return ascending
                                                  ? aMin.compareTo(bMin)
                                                  : bMin.compareTo(aMin);
                                            });
                                          });
                                        },
                                      ),
                                      DataColumn(
                                        label: const Text(
                                          'Max',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),

                                      ),
                                      const DataColumn(
                                        label: Text(
                                          'Actions',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                    source: _SensorDataSource(
                                      _sensorData,
                                      _editingIndex,
                                          (index) {
                                        setState(() {
                                          _editingIndex = index;
                                        });
                                      },
                                          () {
                                        setState(() {
                                          _editingIndex = null;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SensorDataSource extends DataTableSource {
  final List<Map<String, dynamic>> _data;
  final int? editingIndex;
  final Function(int) onEdit;
  final Function() onClose;

  late Map<String, TextEditingController> _controllers;

  _SensorDataSource(
      this._data,
      this.editingIndex,
      this.onEdit,
      this.onClose,
      ) {
    _initializeControllers();
  }

  void _initializeControllers() {
    _controllers = {};
    if (editingIndex != null && editingIndex! < _data.length) {
      final item = _data[editingIndex!];
      _controllers['name'] = TextEditingController(text: item['name']);
      _controllers['unit'] = TextEditingController(text: item['unit']);
      _controllers['min'] = TextEditingController(text: item['min']);
      _controllers['max'] = TextEditingController(text: item['max']);
    }
  }

  @override
  DataRow? getRow(int index) {
    if (index >= _data.length) return null;
    final item = _data[index];
    final isEditing = editingIndex == index;

    if (isEditing) {
      _initializeControllers();
    }

    return DataRow(
      cells: [
        DataCell(
          isEditing
              ? TextField(
            controller: _controllers['name'],
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          )
              : Text(
            item['name'],
            style: const TextStyle(fontSize: 14),
          ),
        ),
        DataCell(
          isEditing
              ? TextField(
            controller: _controllers['unit'],
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          )
              : Text(
            item['unit'],
            style: const TextStyle(fontSize: 14),
          ),
        ),
        DataCell(
          isEditing
              ? TextField(
            controller: _controllers['min'],
            style: const TextStyle(fontSize: 14),
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          )
              : Text(
            item['min'],
            style: const TextStyle(fontSize: 14),
          ),
        ),
        DataCell(
          isEditing
              ? TextField(
            controller: _controllers['max'],
            style: const TextStyle(fontSize: 14),
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          )
              : Text(
            item['max'],
            style: const TextStyle(fontSize: 14),
          ),
        ),
        DataCell(
          isEditing
              ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.check,
                  color: Colors.green,
                  size: 22,
                ),
                onPressed: () {
                  item['name'] = _controllers['name']!.text;
                  item['unit'] = _controllers['unit']!.text;
                  item['min'] = _controllers['min']!.text;
                  item['max'] = _controllers['max']!.text;
                  onClose();
                  debugPrint('Changes saved for ${item['name']}');
                },
              ),
              IconButton(
                icon: const Icon(
                  Icons.close,
                  color: Colors.red,
                  size: 22,
                ),
                onPressed: () {
                  onClose();
                  debugPrint('Edit cancelled');
                },
              ),
            ],
          )
              : IconButton(
            icon: const Icon(
              Icons.edit,
              color: Colors.green,
              size: 22,
            ),
            onPressed: () {
              onEdit(index);
              debugPrint('Edit clicked for ${item['name']}');
            },
          ),
        ),
      ],
    );
  }

  @override
  int get rowCount => _data.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;
}