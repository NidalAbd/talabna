import 'package:talbna/data/models/user.dart';

class Comments {
  final int? id; // Make id nullable
  final int userId;
  final int servicePostId;
  final String content;
  final DateTime? createdAt; // Make createdAt nullable
  final DateTime? updatedAt; // Make updatedAt nullable
  final User user;

  Comments({
    this.id, // Nullable
    required this.userId,
    required this.servicePostId,
    required this.content,
    this.createdAt, // Nullable
    this.updatedAt, // Nullable
    required this.user,
  });

  factory Comments.fromJson(Map<String, dynamic> json) {
    return Comments(
      id: json['id'] as int?,
      userId: json['user_id'] as int,
      servicePostId: json['service_post_id'] as int,
      content: json['content'] as String,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : null,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'service_post_id': servicePostId,
      'content': content,
    };

    return data;
  }
}
