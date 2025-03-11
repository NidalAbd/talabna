import 'dart:convert';

class Country {
  final int id;
  final Map<String, String> name; // Multilingual name
  final String countryCode;
  final String? currencyCode;
  final Map<String, String>? currencyName; // Multilingual currency name

  Country({
    required this.id,
    required this.name,
    required this.countryCode,
    this.currencyCode,
    this.currencyName,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      id: json['id'],
      name: json['name'] is String
          ? Map<String, String>.from(jsonDecode(json['name']))
          : Map<String, String>.from(json['name']),
      countryCode: json['country_code'] ?? '',
      currencyCode: json['currency_code'],
      currencyName: json['currency_name'] is String && json['currency_name'] != null
          ? Map<String, String>.from(jsonDecode(json['currency_name']))
          : (json['currency_name'] != null
          ? Map<String, String>.from(json['currency_name'])
          : null),
    );
  }

  // Get currency name by language with fallback
  String getCurrencyName(String lang) {
    if (currencyName == null) return "USD";
    return currencyName![lang] ?? currencyName!['en'] ?? "USD";
  }

  String getCountryName(String lang) {
    return name[lang] ?? name['en'] ?? "Unknown";
  }
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