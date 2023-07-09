class CategoryMenu {
  int id;
  String name;
  DateTime createdAt;
  DateTime updatedAt;
  List<Photo> photos;

  CategoryMenu({
    required this.id,
    required this.name,
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
      photos: List<Photo>.from(json['photos'].map((photo) => Photo.fromJson(photo))),
    );
  }
}

class Photo {
  int id;
  String photoableType;
  int photoableId;
  String src;
  int isVideo;
  DateTime createdAt;
  DateTime updatedAt;

  Photo({
    required this.id,
    required this.photoableType,
    required this.photoableId,
    required this.src,
    required this.isVideo,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      id: json['id'],
      photoableType: json['photoable_type'],
      photoableId: json['photoable_id'],
      src: json['src'],
      isVideo: json['isVideo'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
