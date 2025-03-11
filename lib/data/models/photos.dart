class Photo {
  final int? id;
  final String? photoableType;
  final int? photoableId;
  final String? src;
  final String? type;
  final bool? isVideo;
  final bool? isExternal;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Photo({
    this.id,
    this.photoableType,
    this.photoableId,
    this.src,
    this.type,
    this.isVideo,
    this.isExternal,
    this.createdAt,
    this.updatedAt,
  });

  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      id: _parseIntField(json['id']),
      photoableType: _parseStringField(json['photoable_type']),
      photoableId: _parseIntField(json['photoable_id']),
      src: _parseStringField(json['src']),
      type: _parseStringField(json['type']),
      isVideo: _parseBoolField(json['isVideo']),
      isExternal: _parseBoolField(json['is_external']),
      createdAt: _parseDateTimeField(json['created_at']),
      updatedAt: _parseDateTimeField(json['updated_at']),
    );
  }

  // Helper method to parse integer fields
  static int? _parseIntField(dynamic value) {
    if (value == null) return null;
    return value is int ? value : int.tryParse(value.toString()) ?? 0;
  }

  // Helper method to parse string fields
  static String? _parseStringField(dynamic value) {
    return value?.toString();
  }

  // Helper method to parse boolean fields
  static bool? _parseBoolField(dynamic value) {
    if (value == null) return null;

    if (value is bool) return value;

    if (value is int) return value == 1;

    if (value is String) {
      return value.toLowerCase() == 'true' || value == '1';
    }

    return false;
  }

  // Helper method to parse datetime fields
  static DateTime? _parseDateTimeField(dynamic value) {
    if (value == null) return null;

    try {
      return value is DateTime
          ? value
          : DateTime.parse(value.toString());
    } catch (e) {
      return null;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    if (id != null) data['id'] = id;
    if (photoableType != null) data['photoable_type'] = photoableType;
    if (photoableId != null) data['photoable_id'] = photoableId;
    if (src != null) data['src'] = src;
    if (type != null) data['type'] = type;

    // Convert boolean fields to integers
    if (isVideo != null) data['isVideo'] = isVideo == true ? 1 : 0;
    if (isExternal != null) data['is_external'] = isExternal == true ? 1 : 0;

    // Convert datetime to ISO 8601 string
    if (createdAt != null) data['created_at'] = createdAt!.toIso8601String();
    if (updatedAt != null) data['updated_at'] = updatedAt!.toIso8601String();

    return data;
  }

  // Convenience method to check if the photo is valid
  bool get isValid => src != null && src!.isNotEmpty;

  // Generate a full URL if needed (you might want to customize this)
  String? getFullUrl({String? baseUrl}) {
    if (src == null) return null;

    if (baseUrl != null) {
      return src!.startsWith('http') ? src : '$baseUrl/$src';
    }

    return src;
  }

  // Create a copy of the photo with some fields potentially modified
  Photo copyWith({
    int? id,
    String? photoableType,
    int? photoableId,
    String? src,
    String? type,
    bool? isVideo,
    bool? isExternal,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Photo(
      id: id ?? this.id,
      photoableType: photoableType ?? this.photoableType,
      photoableId: photoableId ?? this.photoableId,
      src: src ?? this.src,
      type: type ?? this.type,
      isVideo: isVideo ?? this.isVideo,
      isExternal: isExternal ?? this.isExternal,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Photo &&
        other.id == id &&
        other.src == src &&
        other.photoableId == photoableId;
  }

  @override
  int get hashCode => Object.hash(id, src, photoableId);

  @override
  String toString() {
    return 'Photo(id: $id, src: $src, type: $type)';
  }
}