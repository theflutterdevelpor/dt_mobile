import 'package:flutter/material.dart';

class MyBottomNavBar extends StatefulWidget {
  final ValueChanged<int>? onItemTapped;

  const MyBottomNavBar({super.key, this.onItemTapped});

  @override
  State<MyBottomNavBar> createState() => _MyBottomNavBarState();
}

class _MyBottomNavBarState extends State<MyBottomNavBar> {
  int _selectedIndex = 0;

  void _onTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
    widget.onItemTapped?.call(index);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(7, (index) => _navItem(index)),
      ),
    );
  }

  Widget _navItem(int index) {
    bool isActive = _selectedIndex == index;


    final List<String> iconPaths = [
      'assets/icons/icon1.png',
      'assets/icons/icon2.png',
      'assets/icons/icon3.png',
      'assets/icons/icon4.png',
      'assets/icons/icon5.png',
      'assets/icons/icon6.png',
      'assets/icons/icon7.png',
    ];

    return Expanded(
      child: GestureDetector(
        onTap: () => _onTap(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          child: Image.asset(
            iconPaths[index],
            width: isActive ? 30 : 26,
            height: isActive ? 30 : 26,
            color: isActive ? const Color(0xFF00C853) : Colors.grey.shade600,

            errorBuilder: (context, error, stackTrace) {
              return Icon(
                Icons.error_outline,
                size: isActive ? 30 : 26,
                color: Colors.red,
              );
            },
          ),
        ),
      ),
    );
  }
}