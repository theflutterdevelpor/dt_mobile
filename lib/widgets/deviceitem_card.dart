import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class DeviceItemPNG extends StatelessWidget {
  final String iconPath;
  final String label;
  final Color color;

  const DeviceItemPNG({
    super.key,
    required this.iconPath,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // 👉 Yaha navigation or action add kar sakte ho
        print("$label clicked");
      },
      borderRadius: BorderRadius.circular(8),
      child: Row(
        children: [
          Image.asset(
            iconPath,
            width: 22,
            height: 22,
            color: color, // optional: remove if PNG already colored
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
