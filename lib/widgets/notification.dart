import 'package:dt_mobile/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:dt_mobile/models/response/notification_response.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  String _selectedTab = 'All';
  String _selectedCategory = 'All';
  DateTime? _selectedDate;

  bool _isLoading = true;
  String? _errorMessage;

  List<NotificationModel> _notifications = [];

  final List<Map<String, String>> _categories = [
    {"label": "All"},
    {"label": "Gas"},
    {"label": "Temperature"},
    {"label": "Electricity"},
    {"label": "Humidity"},
    {"label": "Motion"},
  ];

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await NotificationApi.getMyNotifications();
      setState(() {
        _notifications = response.data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _markAllAsRead() async {
    final unreadIds = _notifications
        .where((n) => !n.read)
        .map((n) => n.id)
        .toList();

    if (unreadIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All notifications are already read')),
      );
      return;
    }

    final success = await NotificationApi.markManyAsRead(ids: unreadIds);

    if (success) {
      setState(() {
        _notifications = _notifications
            .map((n) => n.copyWith(read: true))
            .toList();
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All notifications marked as read'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _markSingleAsRead(NotificationModel notification) async {
    if (notification.read) return;

    final success = await NotificationApi.markAsRead(
      notificationId: notification.id,
    );

    if (success) {
      setState(() {
        final index = _notifications.indexWhere((n) => n.id == notification.id);
        if (index != -1) {
          _notifications[index] = notification.copyWith(read: true);
        }
      });
    }
  }

  Future<void> _openCalendar() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.green,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: Colors.green),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _clearDateFilter() {
    setState(() => _selectedDate = null);
  }

  String _formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate).toLocal();
      final now = DateTime.now();
      final diff = now.difference(date);

      if (diff.inDays == 0) {
        final hour = date.hour;
        final minute = date.minute.toString().padLeft(2, '0');
        final period = hour >= 12 ? 'PM' : 'AM';
        final hour12 = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
        return 'Today at $hour12:$minute $period';
      } else if (diff.inDays == 1) {
        return 'Yesterday';
      } else if (diff.inDays < 7) {
        const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        return 'Last ${days[date.weekday - 1]}';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (_) {
      return isoDate;
    }
  }

  IconData _getCategoryIcon(String label) {
    switch (label) {
      case 'All':
        return Icons.wifi;
      case 'Gas':
        return Icons.local_gas_station;
      case 'Temperature':
        return Icons.thermostat;
      case 'Electricity':
        return Icons.bolt;
      case 'Humidity':
        return Icons.water_drop_outlined;
      case 'Motion':
        return Icons.directions_run;
      default:
        return Icons.circle;
    }
  }

  void _showFilterPopup(BuildContext context, GlobalKey key) async {
    final RenderBox renderBox =
    key.currentContext!.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final Size size = renderBox.size;

    await showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy + size.height,
        offset.dx + 200,
        0,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      items: _categories.map((cat) {
        final label = cat['label']!;
        final isSelected = _selectedCategory == label;
        return PopupMenuItem(
          value: label,
          child: Row(
            children: [
              Icon(
                _getCategoryIcon(label),
                color: isSelected ? Colors.green : Colors.grey,
                size: 20,
              ),
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.green : Colors.black,
                  fontWeight:
                  isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    ).then((value) {
      if (value != null) {
        setState(() => _selectedCategory = value);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey filterIconKey = GlobalKey();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Notifications",
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Row(
              children: [
                GestureDetector(
                  onTap: _markAllAsRead,
                  child: const Text(
                    "Mark all as read",
                    style: TextStyle(color: Colors.green, fontSize: 10),
                  ),
                ),
                const SizedBox(width: 5),
                GestureDetector(
                  key: filterIconKey,
                  onTap: () => _showFilterPopup(context, filterIconKey),
                  child: const Icon(Icons.filter_list, color: Colors.black87),
                ),
                const SizedBox(width: 3),

                Stack(
                  alignment: Alignment.topRight,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.calendar_today_outlined,
                        color: _selectedDate != null
                            ? Colors.green
                            : Colors.black87,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: _openCalendar,
                    ),
                    if (_selectedDate != null)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _clearDateFilter,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              size: 8,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(width: 8),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          if (_selectedDate != null)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.event, color: Colors.green, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Date: ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                      style: const TextStyle(
                        color: Colors.green,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _clearDateFilter,
                    child: const Icon(Icons.close,
                        color: Colors.red, size: 16),
                  ),
                ],
              ),
            ),

          Row(
            children: [
              _buildTab("All"),
              _buildTab("Unread"),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.green),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 12),
            const Text(
              'Failed to load notifications',
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _fetchNotifications,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            ),
          ],
        ),
      );
    }

    return buildNotificationList();
  }

  Widget _buildTab(String label) {
    final isSelected = _selectedTab == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = label),
      child: Container(
        margin: const EdgeInsets.only(left: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget buildNotificationList() {
    var filtered = _notifications.where((n) {
      if (_selectedTab == 'Unread') return !n.read;
      return true;
    }).toList();

    if (_selectedCategory != 'All') {
      filtered = filtered.where((n) {
        return n.type
            .toLowerCase()
            .contains(_selectedCategory.toLowerCase());
      }).toList();
    }

    if (_selectedDate != null) {
      filtered = filtered.where((n) {
        try {
          final date = DateTime.parse(n.createdAt).toLocal();
          return date.year == _selectedDate!.year &&
              date.month == _selectedDate!.month &&
              date.day == _selectedDate!.day;
        } catch (_) {
          return true;
        }
      }).toList();
    }

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_off_outlined,
                size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text(
              _selectedDate != null
                  ? "Is date par koi notification nahi mila."
                  : "No notifications found.",
              style: TextStyle(color: Colors.grey.shade500),
            ),
            if (_selectedDate != null) ...[
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: _clearDateFilter,
                icon: const Icon(Icons.clear, color: Colors.green, size: 16),
                label: const Text(
                  'Date filter hatao',
                  style: TextStyle(color: Colors.green, fontSize: 13),
                ),
              ),
            ],
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: Colors.green,
      onRefresh: _fetchNotifications,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filtered.length,
        itemBuilder: (context, index) {
          final n = filtered[index];
          return GestureDetector(
            onTap: () => _markSingleAsRead(n),
            child: buildNotificationTile(
              title: n.title,
              message: n.message,
              time: _formatDate(n.createdAt),
              isUnread: !n.read,
            ),
          );
        },
      ),
    );
  }

  Widget buildNotificationTile({
    required String title,
    required String message,
    required String time,
    bool isUnread = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.circle,
                color: isUnread ? Colors.green : Colors.grey.shade400,
                size: 10,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "$title: $message",
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            time,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}