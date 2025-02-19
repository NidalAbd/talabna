import 'dart:convert';

class Country {
  final int id;
  final Map<String, String> name; // Multilingual name
  final String countryCode;

  Country({
    required this.id,
    required this.name,
    required this.countryCode,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      id: json['id'],
      name: Map<String, String>.from(json['name']), // Parse JSON object
      countryCode: json['country_code'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name, // Store as JSON
      'country_code': countryCode,
    };
  }

  // Get country name by language (default to English)
  String getName(String lang) => name[lang] ?? name['en'] ?? "Unknown";
}

class City {
  final int id;
  final Map<String, String> name; // Multilingual name
  final int countryId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  City({
    required this.id,
    required this.name,
    required this.countryId,
    this.createdAt,
    this.updatedAt,
  });

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      id: json['id'],
      name: json['name'] is String
          ? Map<String, String>.from(jsonDecode(json['name']))
          : Map<String, String>.from(json['name']),
      countryId: json['country_id'],
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name, // Store as JSON
      'country_id': countryId,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // Get city name by language (default to English)
  String getName(String lang) => name[lang] ?? name['en'] ?? "Unknown";
}