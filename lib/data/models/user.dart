import 'package:intl/intl.dart';
import 'package:talbna/data/models/countries.dart';

class User {
  int id;
  String? userName;
  String? name;
  String? gender;
  City? city;
  Country? country;
  String? device_token;
  DateTime? dateOfBirth;
  double? locationLatitudes;
  double? locationLongitudes;
  String? phones;
  String? watsNumber;
  String email;
  DateTime? emailVerifiedAt;
  String? isActive;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? followingCount;
  int? followersCount;
  final bool? isFollow; // Add this field
  int? servicePostsCount;
  int? pointsBalance;
  List<Photo>? photos;

  User({
    required this.id,
    this.isFollow,
    this.userName,
    this.name,
    this.gender,
    this.city,
    this.country,
    this.device_token,
    this.dateOfBirth,
    this.locationLatitudes,
    this.locationLongitudes,
    this.phones,
    this.watsNumber,
    required this.email,
    this.emailVerifiedAt,
    this.isActive,
    this.createdAt,
    this.updatedAt,
    this.followingCount,
    this.followersCount,
    this.servicePostsCount,
    this.pointsBalance,
    this.photos,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    List<Photo>? photos;
    if (json['photos'] != null) {
      photos = List<Photo>.from(json['photos'].map((photo) => Photo.fromJson(photo)));
    }

    return User(
      id: json['id'] ?? 0,
      userName: json['user_name'] ?? '',
      name: json['name'] ?? '',
      gender: json['gender'] ?? '',
      city: json['city'] != null ? City.fromJson(json['city']) : null,
      country: json['country'] != null ? Country.fromJson(json['country']) : null,
      device_token: json['device_token'] ?? '',
      dateOfBirth: json['date_of_birth'] != null ? DateTime.parse(json['date_of_birth']) : null,
      locationLatitudes: double.tryParse(json['location_latitudes']?.toString() ?? '') ?? 0,
      locationLongitudes: double.tryParse(json['location_longitudes']?.toString() ?? '') ?? 0,
      phones: json['phones'] ?? '',
      watsNumber: json['WatsNumber'] ?? '',
      email: json['email'] ?? '',
      emailVerifiedAt: json['email_verified_at'] != null ? DateTime.parse(json['email_verified_at']) : null,
      isActive: json['is_active'] ?? '',
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      followingCount: _parseNullableInt(json['following_count']),
      followersCount: _parseNullableInt(json['followers_count']),
      servicePostsCount: _parseNullableInt(json['service_posts_count']),
      pointsBalance: _parseNullableInt(json['pointsBalance']),
      photos: photos,
      isFollow: json['is_follow'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    final DateFormat format = DateFormat('yyyy-MM-dd HH:mm:ss');
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['user_name'] = userName ?? '';
    data['name'] = name ?? '';
    data['gender'] = gender ?? '';
    data['city'] = city?.toJson();
    data['country'] = country?.toJson();
    data['device_token'] = device_token ?? '';
    if (dateOfBirth != null) {
      data['date_of_birth'] = format.format(dateOfBirth!);
    }
    data['location_latitudes'] = locationLatitudes ?? 0.0;
    data['location_longitudes'] = locationLongitudes ?? 0.0;
    data['phones'] = phones ?? '';
    data['WatsNumber'] = watsNumber ?? '';
    data['email'] = email;
    data['email_verified_at'] = emailVerifiedAt != null ? format.format(emailVerifiedAt!) : null;
    data['is_active'] = isActive ?? '';
    data['created_at'] = createdAt != null ? format.format(createdAt!) : null;
    data['updated_at'] = updatedAt != null ? format.format(updatedAt!) : null;
    data['following_count'] = followingCount?.toString();
    data['followers_count'] = followersCount?.toString();
    data['service_posts_count'] = servicePostsCount?.toString();
    data['pointsBalance'] = pointsBalance?.toString();
    data['photos'] = photos?.map((v) => v.toJson()).toList();
    return data;
  }

  static int? _parseNullableInt(dynamic value) {
    if (value == null) {
      return null;
    }
    return int.tryParse(value.toString());
  }
}

class Photo {
  int? id;
  String photoableType;
  int? photoableId;
  String src;
  DateTime createdAt;
  DateTime updatedAt;

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

  Map<String, dynamic> toJson() {
    final DateFormat format = DateFormat('yyyy-MM-dd HH:mm:ss');
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['photoable_type'] = photoableType;
    data['photoable_id'] = photoableId;
    data['src'] = src;
    data['created_at'] = format.format(createdAt);
    data['updated_at'] = format.format(updatedAt);
    return data;
  }
}
