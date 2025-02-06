import 'package:flutter/material.dart';
import '../models/task.dart';

class TaskIcon extends StatelessWidget {
  final String icon;
  final Color color;
  final double size;

  const TaskIcon({
    Key? key,
    required this.icon,
    required this.color,
    this.size = 24,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Create a temporary Category object to use the iconData getter
    final tempCategory = Category(name: '', icon: icon, color: color);

    return Container(
      width: size * 2,
      height: size * 2,
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(size / 2),
      ),
      child: Icon(
        tempCategory.iconData,
        color: color,
        size: size,
      ),
    );
  }
}
