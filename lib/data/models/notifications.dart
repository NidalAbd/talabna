import 'dart:convert';
import 'package:flutter/material.dart';

class Notifications {
  final int id;
  final int userId;
  final Map<String, String> message; // Multilingual message
  late final bool read;
  final String type;
  final DateTime createdAt;
  final DateTime updatedAt;

  Notifications({
    required this.id,
    required this.userId,
    required this.message,
    required this.read,
    required this.type,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Notifications.fromJson(Map<String, dynamic> json) {
    return Notifications(
      id: json['id'],
      userId: json['user_id'],
      message: json['message'] is String
          ? Map<String, String>.from(jsonDecode(json['message']))  // Decode JSON string
          : Map<String, String>.from(json['message']), // Already a Map
      read: json['read'] == 1 ? true : false,
      type: json['type'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }


  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'message': jsonEncode(message), // ✅ Convert Map to JSON string
    'read': read ? 1 : 0,
    'type': type,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };


  // Get message by language (default to English)
  String getMessage(String lang) => message[lang] ?? message['en'] ?? "Message unavailable";

  IconData getIconData() {
    switch (type) {
      case 'user':
        return Icons.person;
      case 'login':
        return Icons.login;
      case 'register':
        return Icons.app_registration;
      case 'post':
        return Icons.post_add;
      case 'badge':
        return Icons.badge;
      case 'password':
        return Icons.lock;
      case 'email':
        return Icons.email;
      case 'report':
        return Icons.report;
      case 'photo':
        return Icons.photo;
      case 'pointIn':
        return Icons.arrow_circle_down;
      case 'pointOut':
        return Icons.arrow_circle_up;
      case 'sub_category':
        return Icons.category;
      default:
        return Icons.notifications;
    }
  }

  Color getIconColor() {
    switch (type) {
      case 'user':
        return Colors.blue;
      case 'login':
        return Colors.orange;
      case 'register':
        return Colors.green;
      case 'post':
        return Colors.purple;
      case 'badge':
        return Colors.yellow;
      case 'password':
        return Colors.red;
      case 'email':
        return Colors.teal;
      case 'report':
        return Colors.grey;
      case 'photo':
        return Colors.tealAccent;
      case 'pointIn':
        return Colors.pink;
      case 'pointOut':
        return Colors.red;
      case 'sub_category':
        return Colors.blueGrey;
      default:
        return Colors.black;
    }
  }
}
