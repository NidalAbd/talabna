class SubCategoryMenu {
  final int id;
  final String name;
  final int categoriesId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int servicePostsCount;
  final List<Photo> photos;

  SubCategoryMenu({
    required this.id,
    required this.name,
    required this.categoriesId,
    required this.createdAt,
    required this.updatedAt,
    required this.servicePostsCount,
    required this.photos,
  });

  factory SubCategoryMenu.fromJson(Map<String, dynamic> json) {
    return SubCategoryMenu(
      id: json['id'],
      name: json['name'],
      categoriesId: json['categories_id'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      servicePostsCount: json['service_posts_count'],
      photos: List<Photo>.from(
        json['photos'].map((photoJson) => Photo.fromJson(photoJson)),
      ),
    );
  }
}

class Photo {
  final int id;
  final String photoableType;
  final int photoableId;
  final String src;
  final DateTime createdAt;
  final DateTime updatedAt;

  Photo({
    required this.id,
    required this.photoableType,
    required this.photoableId,
    required this.src,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      id: json['id'],
      photoableType: json['photoable_type'],
      photoableId: json['photoable_id'],
      src: json['src'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
