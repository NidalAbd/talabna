class ServicePost {
  final int? id;
  final int? userId;
  final String? userName;
  final String? userPhoto;
  final String? title;
  final String? description;
  final String? category;
  final String? subCategory;
  final double? price;
  final String? priceCurrency;
  final double? locationLatitudes;
  final double? locationLongitudes;
  final double? distance;

  final String? type;
  final String? haveBadge;
  final int? badgeDuration;
  final int? favoritesCount;
  final int? reportCount;
  final int? viewCount;
  final bool? isFavorited;
  final bool? isFollowed;

  final String? state;
  final int? categoriesId;
  final int? subCategoriesId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<Photo>? photos;

  ServicePost(  {
     this.userName,
     this.userPhoto,
     this.id,
     this.userId,
     this.title,
     this.description,
     this.category,
     this.subCategory,
     this.price,
     this.priceCurrency,
     this.locationLatitudes,
     this.locationLongitudes,
     this.distance,
     this.isFollowed,
     this.type,
     this.haveBadge,
     this.badgeDuration,
     this.favoritesCount,
     this.reportCount,
     this.viewCount,
    this.isFavorited, // Add this field
    this.state,
     this.categoriesId,
     this.subCategoriesId,
     this.createdAt,
     this.updatedAt,
     this.photos,
  });


  factory ServicePost.fromJson(Map<String, dynamic> json) {
    return ServicePost(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      userName: json['user_name'] ?? '',
      userPhoto: json['user_photo'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      subCategory: json['sub_category'] ?? '',
      price: (json['price'] is int ? json['price'].toDouble() : json['price']) ?? 0,
      priceCurrency: json['price_currency'] ?? '',
      locationLatitudes: double.tryParse(json['location_latitudes'] ?? '') ?? 0,
      locationLongitudes: double.tryParse(json['location_longitudes'] ?? '') ?? 0,
      distance: json['distance'] ?? 0,
      type: json['type'] ?? '',
      haveBadge: json['have_badge'] ??  '',
      badgeDuration: int.tryParse(json['badge_duration']?.toString() ?? '') ?? 0,
      favoritesCount: json['favorites_count'] ?? 0,
      reportCount: json['report_count'] ?? 0,
      viewCount: json['view_count'] ?? 0,
      isFavorited: json['is_favorited'] ?? false,
      isFollowed: json['isFollowed'] ?? false,
      state: json['state'] ?? '',
      categoriesId: json['categories_id'] ?? 0,
      subCategoriesId: json['sub_categories_id'] ?? 0,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      photos: (json['photos'] as List<dynamic>?)?.map((photo) => Photo.fromJson(photo)).toList() ?? [],
    );
  }


  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'title': title,
    'description': description,
    'category': category,
    'sub_category': subCategory,
    'categories_id': categoriesId,
    'sub_categories_id': subCategoriesId,
    'price': price,
    'price_currency': priceCurrency,
    'location_latitudes': locationLatitudes,
    'location_longitudes': locationLongitudes,
    'type': type,
    'have_badge': haveBadge,
    'badge_duration': badgeDuration,
    'photos': photos?.map((photo) => photo.toJson()).toList(),
  };
}

class Photo {
  int? id;
  String? photoableType;
  int? photoableId;
  String? src;
  String? type;
  DateTime? createdAt;
  DateTime? updatedAt;

  Photo.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? 0;
    photoableType = json['photoable_type'] ?? '';
    photoableId = json['photoable_id'] ?? 0;
    src = json['src'] ?? '';
    type = json['type'] ?? '';
    createdAt = json['created_at'] != null ? DateTime.parse(json['created_at']) : null;
    updatedAt = json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['photoable_type'] = photoableType;
    data['photoable_id'] = photoableId;
    data['src'] = src;
    data['type'] = type;
    if (createdAt != null) data['created_at'] = createdAt;
    if (updatedAt != null) data['updated_at'] = updatedAt;
    return data;
  }
}

