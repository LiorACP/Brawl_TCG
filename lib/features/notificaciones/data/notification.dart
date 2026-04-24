import 'package:flutter/material.dart';

enum NotificationType { event, result, social, system }

class AppNotification {
  final String icon;
  final String title;
  final String body;
  final String timeLabel;
  final Color color;
  final NotificationType type;
  final bool isRead;

  const AppNotification({
    required this.icon,
    required this.title,
    required this.body,
    required this.timeLabel,
    required this.color,
    required this.type,
    this.isRead = false,
  });
}
