import 'package:intl/intl.dart';
import 'package:talbna/data/models/countries.dart';
import 'package:talbna/data/models/service_post.dart';

class User {
  int id;
  String? userName;
  String? name;
  String? gender;
  City? city;
  Country? country;
  String? deviceToken;
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
    this.deviceToken,
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

    DateTime? dateOfBirth;
    if (json['date_of_birth'] != null) {
      dateOfBirth = DateTime.tryParse(json['date_of_birth']);
    }

    DateTime? emailVerifiedAt;
    if (json['email_verified_at'] != null) {
      emailVerifiedAt = DateTime.tryParse(json['email_verified_at']);
    }

    DateTime? createdAt;
    if (json['created_at'] != null) {
      createdAt = DateTime.tryParse(json['created_at']);
    }

    DateTime? updatedAt;
    if (json['updated_at'] != null) {
      updatedAt = DateTime.tryParse(json['updated_at']);
    }

    return User(
      id: json['id'] ?? 0,
      userName: json['user_name'] ?? '',
      name: json['name'] ?? '',
      gender: json['gender'] ?? '',
      city: json['city'] != null ? City.fromJson(json['city']) : null,
      country: json['country'] != null ? Country.fromJson(json['country']) : null,
      deviceToken: json['device_token'] ?? '',
      dateOfBirth: dateOfBirth,
      locationLatitudes: double.tryParse(json['location_latitudes']?.toString() ?? '') ?? 0,
      locationLongitudes: double.tryParse(json['location_longitudes']?.toString() ?? '') ?? 0,
      phones: json['phones'] ?? '',
      watsNumber: json['WatsNumber'] ?? '',
      email: json['email'] ?? '',
      emailVerifiedAt: emailVerifiedAt,
      isActive: json['is_active'] ?? '',
      createdAt: createdAt,
      updatedAt: updatedAt,
      followingCount: _parseNullableInt(json['following_count']),
      followersCount: _parseNullableInt(json['followers_count']),
      servicePostsCount: _parseNullableInt(json['service_posts_count']),
      pointsBalance: _parseNullableInt(json['pointsBalance']),
      photos: photos,
      isFollow: json['is_follow'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    final DateFormat format = DateFormat('yyyy-MM-dd HH:mm:ss'); // Corrected date format

    data['id'] = id;
    data['user_name'] = userName ?? '';
    data['name'] = name ?? '';
    data['gender'] = gender ?? '';
    data['city'] = city?.toJson();
    data['country'] = country?.toJson();
    data['device_token'] = deviceToken ?? '';
    if (dateOfBirth != null) {
      data['date_of_birth'] = format.format(dateOfBirth!);
    }
    data['location_latitudes'] = locationLatitudes ?? 0.0;
    data['location_longitudes'] = locationLongitudes ?? 0.0;
    data['phones'] = phones ?? '';
    data['WatsNumber'] = watsNumber ?? '';
    data['email'] = email;
    print('this date of birth to go out ${data['date_of_birth']}');
    return data;
  }

  static int? _parseNullableInt(dynamic value) {
    if (value == null) {
      return null;
    }
    return int.tryParse(value.toString());
  }
}
