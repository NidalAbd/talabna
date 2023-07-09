class Country {
  final int id;
  final String name;
  final String countryCode;

  Country({
    required this.id,
    required this.name,
    required this.countryCode,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      id: json['id'],
      name: json['name'],
      countryCode: json['country_code'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'country_code': countryCode,
    };
  }
}

class City {
  final int id;
  final String name;
  final int countryId;
  final DateTime createdAt;
  final DateTime updatedAt;

  City({
    required this.id,
    required this.name,
    required this.countryId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      id: json['id'],
      name: json['name'],
      countryId: json['country_id'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'country_id': countryId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

