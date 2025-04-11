import 'package:flutter/material.dart';

class Reminder {
  final String id;
  final String medicationName;
  final int quantity;
  final TimeOfDay time;
  final List<int> days; // 0-6 for Sunday-Saturday
  final bool isActive;

  Reminder({
    required this.id,
    required this.medicationName,
    required this.quantity,
    required this.time,
    required this.days,
    this.isActive = true,
  });

  factory Reminder.fromData(Map<String, dynamic> data) {
    final days = (data['days'] as String).split(',').map(int.parse).toList();
    return Reminder(
      id: data['id'],
      medicationName: data['medicationName'],
      quantity: data['quantity'],
      time: TimeOfDay(hour: data['hour'], minute: data['minute']),
      days: days,
      isActive: data['isActive'],
    );
  }

  Map<String, dynamic> toData() {
    return {
      'id': id,
      'medicationName': medicationName,
      'quantity': quantity,
      'hour': time.hour,
      'minute': time.minute,
      'days': days.join(','),
      'isActive': isActive,
    };
  }

  Reminder copyWith({
    String? id,
    String? medicationName,
    int? quantity,
    TimeOfDay? time,
    List<int>? days,
    bool? isActive,
  }) {
    return Reminder(
      id: id ?? this.id,
      medicationName: medicationName ?? this.medicationName,
      quantity: quantity ?? this.quantity,
      time: time ?? this.time,
      days: days ?? this.days,
      isActive: isActive ?? this.isActive,
    );
  }
}
