// import 'package:flutter/material.dart';
//
// class ActivityTimelineScreen extends StatelessWidget {
//   const ActivityTimelineScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Column(
//         children: [
//
//           // ────────────────── TOP WEEK CALENDAR ──────────────────
//           SizedBox(
//             height: 110,
//             child: ListView.builder(
//               scrollDirection: Axis.horizontal,
//               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
//               itemCount: 15,
//               itemBuilder: (context, i) {
//                 final now = DateTime.now();
//                 final date = now.add(Duration(days: i - 7));
//                 final isToday = i == 7;
//
//                 return GestureDetector(
//                   onTap: () {},
//                   child: Container(
//                     width: 68,
//                     margin: const EdgeInsets.symmetric(horizontal: 6),
//                     decoration: BoxDecoration(
//                       color: isToday ? const Color(0xFF4CAF50) : Colors.transparent,
//                       borderRadius: BorderRadius.circular(34),
//                     ),
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Text(
//                           ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][date.weekday - 1],
//                           style: TextStyle(
//                             fontSize: 13,
//                             color: isToday ? Colors.white : Colors.grey[600],
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                         const SizedBox(height: 6),
//                         Text(
//                           date.day.toString(),
//                           style: TextStyle(
//                             fontSize: 20,
//                             fontWeight: FontWeight.bold,
//                             color: isToday ? Colors.white : Colors.black87,
//                           ),
//                         ),
//                         if (isToday)
//                           Container(
//                             margin: const EdgeInsets.only(top: 8),
//                             width: 6,
//                             height: 6,
//                             decoration: const BoxDecoration(
//                               color: Colors.white,
//                               shape: BoxShape.circle,
//                             ),
//                           ),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//
//           // Green divider line
//           Container(height: 0.8, color: const Color(0xFF4CAF50).withOpacity(0.2)),
//
//           // ────────────────── TIMELINE EVENTS ──────────────────
//           Expanded(
//             child: ListView(
//               padding: const EdgeInsets.only(top: 12),
//               children: const [
//
//                 TimelineEvent(
//                   time: "07:00 AM",
//                   title: "Motion Detection",
//                   location: "At Adel's Room",
//                 ),
//                 TimelineEvent(
//                   time: "07:00 AM",
//                   title: "Smoke Detection",
//                   location: "At Kitchen's Room",
//                 ),
//                 TimelineEvent(
//                   time: "07:00 AM",
//                   title: "Door Open",
//                   location: "At Adel's Room",
//                 ),
//                 TimelineEvent(
//                   time: "07:00 AM",
//                   title: "Motion Detection",
//                   location: "At Adel's Room",
//                 ),
//                 TimelineEvent(
//                   time: "07:00 AM",
//                   title: "Motion Detection",
//                   location: "At Adel's Room",
//                 ),
//                 TimelineEvent(
//                   time: "07:00 AM",
//                   title: "Door Open",
//                   location: "At Adel's Room",
//                 ),
//
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// // Yeh ek single event ka exact widget – bilkul pic jaisa
// class TimelineEvent extends StatelessWidget {
//   final String time;
//   final String title;
//   final String location;
//
//   const TimelineEvent({
//     super.key,
//     required this.time,
//     required this.title,
//     required this.location,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//
//           // Time + Green Line
//           SizedBox(
//             width: 88,
//             child: Column(
//               children: [
//                 Text(
//                   time,
//                   style: TextStyle(
//                     fontSize: 13,
//                     color: Colors.grey.shade600,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//                 const SizedBox(height: 12),
//                 Container(
//                   width: 2,
//                   height: 76,
//                   color: const Color(0xFF4CAF50).withOpacity(0.35),
//                 ),
//               ],
//             ),
//           ),
//
//           const SizedBox(width: 16),
//
//           // Event Card – 100% pic jaisa
//           Expanded(
//             child: Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: const Color(0xFFF8FFF9),
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(
//                   color: const Color(0xFF4CAF50).withOpacity(0.25),
//                   width: 1,
//                 ),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     title,
//                     style: const TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                       color: Colors.black87,
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     location,
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: Colors.grey.shade600,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';

// ----------------------------------------------------------------------
// --- Dummy Data and Model ---
// ----------------------------------------------------------------------

// Dummy Data structure for events
class Event {
  final String time;
  final String name;
  final String location;
  final Color color;

  Event({required this.time, required this.name, required this.location, required this.color});
}

// Dummy Data for the list view
final List<Event> todayEvents = [
  Event(time: '07:00 AM', name: 'Motion Detection', location: 'At Adeel\'s Room', color: Colors.green),
  Event(time: '07:00 AM', name: 'Smoke Detection', location: 'At Kitchen\'s Room', color: Colors.green),
  Event(time: '07:00 AM', name: 'Door Open', location: 'At Adeel\'s Room', color: Colors.green),
  Event(time: '07:00 AM', name: 'Motion Detection', location: 'At Adeel\'s Room', color: Colors.green),
  Event(time: '07:00 AM', name: 'Motion Detection', location: 'At Adeel\'s Room', color: Colors.green),
  Event(time: '07:00 AM', name: 'Door Open', location: 'At Adeel\'s Room', color: Colors.green),
];

// Dummy Data for the calendar header
final List<Map<String, dynamic>> calendarDays = [
  {'date': '11', 'day': 'Mon', 'hasEvent': false, 'isToday': false},
  {'date': '12', 'day': 'Tue', 'hasEvent': false, 'isToday': false},
  {'date': '13', 'day': 'Wed', 'hasEvent': true, 'isToday': false},
  {'date': '14', 'day': 'Thu', 'hasEvent': true, 'isToday': true}, // Selected Day
  {'date': '15', 'day': 'Fri', 'hasEvent': false, 'isToday': false},
  {'date': '16', 'day': 'Sat', 'hasEvent': false, 'isToday': false},
  {'date': '17', 'day': 'Sun', 'hasEvent': false, 'isToday': false},
];

// ----------------------------------------------------------------------
// --- Main Screen Widget ---
// ----------------------------------------------------------------------

class EventScreen extends StatelessWidget {
  const EventScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            // --- 1. Calendar Header ---
            CalendarHeader(days: calendarDays),

            // Horizontal Rule / Divider
            const Divider(height: 1, color: Colors.black12),

            // --- 2. Events List ---
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.zero, // Remove default list padding
                itemCount: todayEvents.length,
                itemBuilder: (context, index) {
                  final event = todayEvents[index];
                  // Use a very light green/off-white for background as seen in the image
                  final tileColor = index.isEven ? const Color(0xFFF7FFF7) : Colors.white;

                  // Add a Divider at the end of each tile except the last one
                  return Column(
                    children: [
                      EventTile(
                        event: event,
                        tileColor: tileColor,
                      ),
                      if (index < todayEvents.length - 1)
                      // A very subtle separator line to mimic the image
                        Container(
                          height: 1.0,
                          color: Colors.black12.withOpacity(0.1),
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ----------------------------------------------------------------------
// --- Custom Widget 1: Calendar Header (Top Bar) ---
// ----------------------------------------------------------------------

class CalendarHeader extends StatelessWidget {
  final List<Map<String, dynamic>> days;

  const CalendarHeader({Key? key, required this.days}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100, // Fixed height for the header
      padding: const EdgeInsets.only(top: 10.0, bottom: 5.0),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: days.length,
        itemBuilder: (context, index) {
          final day = days[index];

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5.0),
            child: DayCard(
              date: day['date'] as String,
              dayOfWeek: day['day'] as String,
              isSelected: day['isToday'] as bool,
              hasEvent: day['hasEvent'] as bool,
            ),
          );
        },
      ),
    );
  }
}

class DayCard extends StatelessWidget {
  final String date;
  final String dayOfWeek;
  final bool isSelected;
  final bool hasEvent;

  const DayCard({
    Key? key,
    required this.date,
    required this.dayOfWeek,
    required this.isSelected,
    required this.hasEvent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Define colors for selected state
    const selectedBackgroundColor = Color(0xFFEFF5ED); // Lightest shade of green/off-white
    const selectedTextColor = Color(0xFF388E3C); // Medium green text (for contrast)
    const defaultTextColor = Colors.black54;

    return Container(
      width: 65, // Fixed width for consistent card size
      decoration: isSelected
          ? BoxDecoration(
        color: selectedBackgroundColor,
        borderRadius: BorderRadius.circular(10.0),
      )
          : null,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          // Date (e.g., 14)
          Text(
            date,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isSelected ? selectedTextColor : defaultTextColor,
            ),
          ),
          // Day of Week (e.g., Thu)
          Text(
            dayOfWeek,
            style: TextStyle(
              fontSize: 14,
              color: isSelected ? selectedTextColor : defaultTextColor,
            ),
          ),
          // Green Dot for selected day with events
          if (isSelected) // Green dot is only visible for the selected day in the image
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.green),
              ),
            ),
        ],
      ),
    );
  }
}

// ----------------------------------------------------------------------
// --- Custom Widget 2: Event Tile (List Item) ---
// ----------------------------------------------------------------------

class EventTile extends StatelessWidget {
  final Event event;
  final Color tileColor;

  const EventTile({Key? key, required this.event, required this.tileColor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: tileColor, // Alternating light green/white background
      padding: const EdgeInsets.symmetric(vertical: 18.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Left Green Indicator Bar (Vertical Line)
          Container(
            width: 5.0,
            // Height is adjusted by using constraints and padding on the outside
            height: 70,
            color: event.color,
          ),

          const SizedBox(width: 15.0), // Space between bar and text

          // Time (Left Side - Fixed width for alignment)
          SizedBox(
            width: 80,
            child: Text(
              event.time,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: Colors.black,
              ),
            ),
          ),

          // Event Details (Right Side)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Event Name (Bold, Larger)
                Text(
                  event.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4.0),
                // Location (Grey, Smaller)
                Text(
                  event.location,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}