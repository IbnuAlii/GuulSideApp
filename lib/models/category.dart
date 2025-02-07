import 'package:flutter/material.dart';

class Category {
  final int? id;
  final String name;
  final String icon;
  final Color color;

  const Category({
    this.id,
    required this.name,
    required this.icon,
    required this.color,
  });

  IconData get iconData => getIconData(icon);

  static IconData getIconData(String icon) {
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
      case 'Home':
        return Icons.home;
      case 'Work':
        return Icons.work;
      case 'School':
        return Icons.school;
      case 'Sports':
        return Icons.sports_soccer;
      case 'Favorite':
        return Icons.favorite;
      case 'ShoppingCart':
        return Icons.shopping_cart;
      case 'Restaurant':
        return Icons.restaurant;
      case 'LocalHospital':
        return Icons.local_hospital;
      case 'DirectionsBike':
        return Icons.directions_bike;
      case 'Movie':
        return Icons.movie;
      case 'MusicNote':
        return Icons.music_note;
      case 'Book':
        return Icons.book;
      case 'Brush':
        return Icons.brush;
      case 'Camera':
        return Icons.camera_alt;
      case 'Computer':
        return Icons.computer;
      case 'Pets':
        return Icons.pets;
      case 'Flight':
        return Icons.flight;
      case 'FitnessCenter':
        return Icons.fitness_center;
      case 'Spa':
        return Icons.spa;
      case 'ShoppingBag':
        return Icons.shopping_bag;
      default:
        return Icons.help_outline;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'color': color.value,
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'],
      name: map['name'],
      icon: map['icon'],
      color: Color(map['color']),
    );
  }

  Category copyWith({
    int? id,
    String? name,
    String? icon,
    Color? color,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Category &&
        other.id == id &&
        other.name == name &&
        other.icon == icon &&
        other.color.value == color.value;
  }

  @override
  int get hashCode => Object.hash(id, name, icon, color.value);

  @override
  String toString() {
    return 'Category(id: $id, name: $name, icon: $icon, color: ${color.value})';
  }
}
