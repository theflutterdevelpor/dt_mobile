import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DatePicker extends StatefulWidget {
  final Function(DateTime? endDate, Map<String, List<bool>> activityData)? onDataChanged;

  const DatePicker({Key? key, this.onDataChanged}) : super(key: key);

  @override
  State<DatePicker> createState() => _DatePickerState();
}

class _DatePickerState extends State<DatePicker> {
  final List<String> days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
  final List<String> times = ['12 am', '2 am', '4 am', '6 am', '8 am', '10 am', '12 pm', '2 pm', '4 pm', '6 pm', '8 pm', '10 pm'];

  late Map<String, List<bool>> activityData;
  DateTime? selectedDate;
  String? startDay;
  int? startIndex;

  @override
  void initState() {
    super.initState();
    activityData = _initializeActivityData();
  }

  Map<String, List<bool>> _initializeActivityData() {
    Map<String, List<bool>> data = {};
    for (String day in days) {
      data[day] = List<bool>.filled(times.length, false);
    }
    return data;
  }

  void _notifyParent() {
    widget.onDataChanged?.call(selectedDate, activityData);
  }

  void _toggleActivity(String day, int timeIndex) {
    if (startDay == null) {
      setState(() {
        startDay = day;
        startIndex = timeIndex;
        activityData[day]![timeIndex] = true;
      });
      _notifyParent();
      return;
    }

    int startDayIndex = days.indexOf(startDay!);
    int endDayIndex = days.indexOf(day);

    if (endDayIndex < startDayIndex ||
        (endDayIndex == startDayIndex && timeIndex < startIndex!)) {
      int tempDayIndex = startDayIndex;
      startDayIndex = endDayIndex;
      endDayIndex = tempDayIndex;

      int tempTimeIndex = startIndex!;
      startIndex = timeIndex;
      timeIndex = tempTimeIndex;

      startDay = days[startDayIndex];
    }

    setState(() {
      for (int d = startDayIndex; d <= endDayIndex; d++) {
        String currentDay = days[d];

        int fromTime = (d == startDayIndex) ? startIndex! : 0;
        int toTime = (d == endDayIndex) ? timeIndex : times.length - 1;

        for (int t = fromTime; t <= toTime; t++) {
          activityData[currentDay]![t] = true;
        }
      }
    });

    startDay = null;
    startIndex = null;
    _notifyParent();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xff66bb6a),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != selectedDate) {
      setState(() => selectedDate = picked);
      _notifyParent();
    }
  }

  String _formatDate(DateTime date) => DateFormat('MM/dd/yyyy').format(date);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Column(
              children: [
                Row(
                  children: [
                    SizedBox(width: 80, child: Container()),
                    ...times.map((time) => SizedBox(
                      width: 40,
                      child: Center(
                        child: Text(
                          time,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    )),
                  ],
                ),
                const SizedBox(height: 12),
                ...days.map((day) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 80,
                        child: Text(
                          day,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                      ),
                      ...List.generate(times.length, (index) {
                        bool isActive = activityData[day]![index];
                        return SizedBox(
                          width: 40,
                          child: Center(
                            child: GestureDetector(
                              onTap: () => _toggleActivity(day, index),
                              child: Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: isActive ? const Color(0xff66bb6a) : const Color(0xffd3d3d3),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                )),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'End Date',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => _selectDate(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey.shade50,
              ),
              child: Row(
                children: [
                  Image.asset("assets/icons/calendar-03.png", fit: BoxFit.cover),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      selectedDate != null ? _formatDate(selectedDate!) : 'Select Date',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 16,
                        color: selectedDate != null ? Colors.black : Colors.grey.shade400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 26),
        ],
      ),
    );
  }
}