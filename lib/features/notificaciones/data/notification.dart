import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:brawl_tcg/core/theme/app_colors.dart';

enum NotificationType { event, result, social, system }

class AppNotification {
  final String id;
  final String icon;
  final String title;
  final String body;
  final String timeLabel;
  final Color color;
  final NotificationType type;
  final bool isRead;
  final DateTime createdAt;

  AppNotification({
    required this.id,
    required this.icon,
    required this.title,
    required this.body,
    required this.timeLabel,
    required this.color,
    required this.type,
    this.isRead = false,
    required this.createdAt,
  });

  // Firestore schema:
  //   date (Timestamp), mensaje (string), type (string), userID (Reference)
  //   Optional: title, icon, isRead
  factory AppNotification.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    final typeStr = d['type'] as String? ?? 'system';
    final type = _parseType(typeStr);
    final createdAt =
        (d['date'] as Timestamp?)?.toDate() ?? DateTime.now();

    // Support both 'mensaje' (current schema) and 'body' (extended schema)
    final body = d['mensaje'] as String? ?? d['body'] as String? ?? '';
    final title = d['title'] as String? ?? _defaultTitle(typeStr);
    final icon = d['icon'] as String? ?? _defaultIcon(type);

    return AppNotification(
      id: doc.id,
      icon: icon,
      title: title,
      body: body,
      timeLabel: _timeLabel(createdAt),
      color: _typeColor(type),
      type: type,
      isRead: d['isRead'] as bool? ?? false,
      createdAt: createdAt,
    );
  }

  static NotificationType _parseType(String s) {
    final lower = s.toLowerCase();
    if (lower == 'event' || lower == 'torneo' || lower == 'evento') {
      return NotificationType.event;
    }
    if (lower == 'result' || lower == 'resultado') {
      return NotificationType.result;
    }
    if (lower == 'social' ||
        lower == 'inscripcion' ||
        lower == 'inscripción') {
      return NotificationType.social;
    }
    return NotificationType.system;
  }

  static String _defaultTitle(String typeStr) {
    final lower = typeStr.toLowerCase();
    if (lower == 'torneo' || lower == 'evento' || lower == 'event') {
      return 'Nuevo torneo disponible';
    }
    if (lower == 'resultado' || lower == 'result') {
      return 'Resultado publicado';
    }
    if (lower == 'inscripcion' || lower == 'social') {
      return 'Nueva solicitud';
    }
    return 'Notificación del sistema';
  }

  static Color _typeColor(NotificationType type) => switch (type) {
        NotificationType.event => AppColors.cyan,
        NotificationType.result => AppColors.yellow,
        NotificationType.social => AppColors.violet,
        NotificationType.system => AppColors.orange,
      };

  static String _defaultIcon(NotificationType type) => switch (type) {
        NotificationType.event => '◉',
        NotificationType.result => '🏆',
        NotificationType.social => '✉',
        NotificationType.system => '★',
      };

  static String _timeLabel(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }

  AppNotification copyWith({bool? isRead}) => AppNotification(
        id: id,
        icon: icon,
        title: title,
        body: body,
        timeLabel: timeLabel,
        color: color,
        type: type,
        isRead: isRead ?? this.isRead,
        createdAt: createdAt,
      );
}
