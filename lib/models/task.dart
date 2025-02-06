import 'package:flutter/material.dart';

class Task {
  final String id; // Changed from int to String to match MongoDB ObjectId
  final String name;
  final Category category;
  final String startDate;
  final String endDate;
  final Priority priority;
  final String note;
  final bool completed;
  final String? completedAt;
  final String? reminder; // Added reminder field

  Task({
    required this.id,
    required this.name,
    required this.category,
    required this.startDate,
    required this.endDate,
    required this.priority,
    required this.note,
    this.completed = false,
    this.completedAt,
    this.reminder, // Added to constructor
  });

  Task copyWith({
    String? id,
    String? name,
    Category? category,
    String? startDate,
    String? endDate,
    Priority? priority,
    String? note,
    bool? completed,
    String? completedAt,
    String? reminder, // Added to copyWith
  }) {
    return Task(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      priority: priority ?? this.priority,
      note: note ?? this.note,
      completed: completed ?? this.completed,
      completedAt: completedAt ?? this.completedAt,
      reminder: reminder ?? this.reminder, // Added to copyWith
    );
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['_id'], // Changed to '_id' to match MongoDB's default ID field
      name: json['name'],
      category: Category.fromJson(json['category']),
      startDate: json['startDate'],
      endDate: json['endDate'],
      priority: Priority.fromJson(json['priority']),
      note: json['note'],
      completed: json['completed'],
      completedAt: json['completedAt'],
      reminder: json['reminder'], // Added to fromJson
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'category': category.toJson(),
      'startDate': startDate,
      'endDate': endDate,
      'priority': priority.toJson(),
      'note': note,
      'completed': completed,
      'completedAt': completedAt,
      'reminder': reminder, // Added to toJson
    };
  }
}

class Category {
  final String name;
  final String icon;
  final Color color;

  const Category({
    required this.name,
    required this.icon,
    required this.color,
  });

  IconData get iconData => _getIconData(icon);

  static IconData _getIconData(String icon) {
    switch (icon) {
      case 'Ban':
        return Icons.block;
      case 'PenTool':
        return Icons.brush;
      case 'Clock':
        return Icons.access_time;
      case 'UserCircle':
        return Icons.person;
      case 'GraduationCap':
        return Icons.school;
      case 'Bike':
        return Icons.directions_bike;
      case 'Ticket':
        return Icons.local_activity;
      case 'MessageSquare':
        return Icons.chat;
      case 'DollarSign':
        return Icons.attach_money;
      case 'Stethoscope':
        return Icons.medical_services;
      case 'Briefcase':
        return Icons.work;
      case 'Utensils':
        return Icons.restaurant;
      default:
        return Icons.help_outline;
    }
  }

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      name: json['name'],
      icon: json['icon'],
      color: Color(int.parse(json['color'], radix: 16)),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'icon': icon,
      'color': color.value.toRadixString(16),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Category &&
        other.name == name &&
        other.icon == icon &&
        other.color.value == color.value;
  }

  @override
  int get hashCode => Object.hash(name, icon, color.value);
}

class Priority {
  final int value;
  final bool isDefault;

  Priority({required this.value, required this.isDefault});

  factory Priority.fromJson(Map<String, dynamic> json) {
    return Priority(
      value: json['value'],
      isDefault: json['isDefault'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'isDefault': isDefault,
    };
  }
}
