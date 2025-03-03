
import 'package:talbna/data/models/photos.dart';

class CategoryMenu {
  int id;
  String name;
  DateTime createdAt;
  DateTime updatedAt;
  final bool isSuspended;  // Add this field
  List<Photo> photos;

  CategoryMenu({
    required this.id,
    required this.name,
    this.isSuspended = false,  // Default to false
    required this.createdAt,
    required this.updatedAt,
    required this.photos,
  });

  factory CategoryMenu.fromJson(Map<String, dynamic> json) {
    return CategoryMenu(
      id: json['id'],
      name: json['name'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      isSuspended: json['isSuspended'] == 1 || json['isSuspended'] == true,  // Handle both int and bool formats
      photos: List<Photo>.from(json['photos'].map((photo) => Photo.fromJson(photo))),
    );
  }
}

