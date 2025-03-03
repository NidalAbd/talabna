class Photo {
  int? id;
  String? photoableType;
  int? photoableId;
  String? src;
  String? type;
  bool? isVideo;
  bool? isExternal; // Add this field
  DateTime? createdAt;
  DateTime? updatedAt;

  Photo({
    this.id,
    this.photoableType,
    this.photoableId,
    this.src,
    this.type,
    this.isVideo,
    this.isExternal, // Add to constructor
    this.createdAt,
    this.updatedAt
  });

  Photo.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? 0;
    photoableType = json['photoable_type'] ?? '';
    photoableId = json['photoable_id'] ?? 0;
    src = json['src'] ?? '';
    type = json['type'] ?? '';
    isVideo = json['isVideo'] == 1; // Convert integer to boolean
    isExternal = json['is_external'] == 1; // Convert integer to boolean
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
    data['isVideo'] = isVideo == true ? 1 : 0; // Convert boolean to integer
    data['is_external'] = isExternal == true ? 1 : 0; // Convert boolean to integer
    if (createdAt != null) data['created_at'] = createdAt;
    if (updatedAt != null) data['updated_at'] = updatedAt;
    return data;
  }
}