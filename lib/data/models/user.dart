import 'package:intl/intl.dart';
import 'package:talbna/data/models/countries.dart';
import 'package:talbna/data/models/photos.dart';
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
  final bool dataSaverEnabled;
  String email;
  final String? googleId;
  final String authType; // 'email', 'google', etc.
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
    this.dataSaverEnabled = false,
    this.googleId,
    this.authType = 'email',
    this.emailVerifiedAt,
    this.isActive,
    this.createdAt,
    this.updatedAt,
    this.followingCount,
    this.followersCount,
    this.isFollow,
    this.servicePostsCount,
    this.pointsBalance,
    this.photos,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    // Parse photos if available
    List<Photo>? photos;
    if (json['photos'] != null) {
      photos = List<Photo>.from(json['photos'].map((photo) => Photo.fromJson(photo)));
    }

    // Parse date fields
    DateTime? parseDateTime(String? dateStr) {
      if (dateStr == null || dateStr.isEmpty) return null;
      try {
        return DateTime.parse(dateStr);
      } catch (e) {
        print('Error parsing date: $dateStr - $e');
        return null;
      }
    }

    return User(
      id: json['id'] ?? 0,
      userName: json['user_name'],
      name: json['name'],
      gender: json['gender'],
      city: json['city'] != null ? City.fromJson(json['city']) : null,
      country: json['country'] != null ? Country.fromJson(json['country']) : null,
      deviceToken: json['device_token'] ?? json['fcm_token'],
      dateOfBirth: parseDateTime(json['date_of_birth']),
      locationLatitudes: _parseNullableDouble(json['location_latitudes']),
      locationLongitudes: _parseNullableDouble(json['location_longitudes']),
      phones: json['phones'],
      watsNumber: json['WatsNumber'],
      email: json['email'] ?? '',
      dataSaverEnabled: json['data_saver_enabled'] ?? false,
      googleId: json['google_id'],
      authType: json['auth_type'] ?? 'email',
      emailVerifiedAt: parseDateTime(json['email_verified_at']),
      isActive: json['is_active'],
      createdAt: parseDateTime(json['created_at']),
      updatedAt: parseDateTime(json['updated_at']),
      followingCount: _parseNullableInt(json['following_count']),
      followersCount: _parseNullableInt(json['followers_count']),
      servicePostsCount: _parseNullableInt(json['service_posts_count']),
      pointsBalance: _parseNullableInt(json['pointsBalance'] ?? json['points_balance']),
      photos: photos,
      isFollow: json['is_follow'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    final DateFormat format = DateFormat('yyyy-MM-dd');

    data['id'] = id;
    data['user_name'] = userName;
    data['name'] = name;
    data['gender'] = gender;

    // Include the full objects AND their IDs as expected by the server
    if (country != null) {
      data['country'] = {'id': country!.id};
      data['country_id'] = country!.id;
    }

    if (city != null) {
      data['city'] = {'id': city!.id};
      data['city_id'] = city!.id;
    }

    data['device_token'] = deviceToken;

    if (dateOfBirth != null) {
      data['date_of_birth'] = format.format(dateOfBirth!);
    }

    data['location_latitudes'] = locationLatitudes;
    data['location_longitudes'] = locationLongitudes;
    data['phones'] = phones;
    data['WatsNumber'] = watsNumber;
    data['email'] = email;
    data['data_saver_enabled'] = dataSaverEnabled;
    data['google_id'] = googleId;
    data['auth_type'] = authType;

    return data;
  }

  // Create a copy of the user with updated fields
  User copyWith({
    int? id,
    String? userName,
    String? name,
    String? gender,
    City? city,
    Country? country,
    String? deviceToken,
    DateTime? dateOfBirth,
    double? locationLatitudes,
    double? locationLongitudes,
    String? phones,
    String? watsNumber,
    String? email,
    bool? dataSaverEnabled,
    String? googleId,
    String? authType,
    DateTime? emailVerifiedAt,
    String? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? followingCount,
    int? followersCount,
    bool? isFollow,
    int? servicePostsCount,
    int? pointsBalance,
    List<Photo>? photos,
  }) {
    return User(
      id: id ?? this.id,
      userName: userName ?? this.userName,
      name: name ?? this.name,
      gender: gender ?? this.gender,
      city: city ?? this.city,
      country: country ?? this.country,
      deviceToken: deviceToken ?? this.deviceToken,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      locationLatitudes: locationLatitudes ?? this.locationLatitudes,
      locationLongitudes: locationLongitudes ?? this.locationLongitudes,
      phones: phones ?? this.phones,
      watsNumber: watsNumber ?? this.watsNumber,
      email: email ?? this.email,
      dataSaverEnabled: dataSaverEnabled ?? this.dataSaverEnabled,
      googleId: googleId ?? this.googleId,
      authType: authType ?? this.authType,
      emailVerifiedAt: emailVerifiedAt ?? this.emailVerifiedAt,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      followingCount: followingCount ?? this.followingCount,
      followersCount: followersCount ?? this.followersCount,
      isFollow: isFollow ?? this.isFollow,
      servicePostsCount: servicePostsCount ?? this.servicePostsCount,
      pointsBalance: pointsBalance ?? this.pointsBalance,
      photos: photos ?? this.photos,
    );
  }

  static int? _parseNullableInt(dynamic value) {
    if (value == null) {
      return null;
    }
    return int.tryParse(value.toString());
  }

  static double? _parseNullableDouble(dynamic value) {
    if (value == null) {
      return null;
    }
    return double.tryParse(value.toString());
  }
}

