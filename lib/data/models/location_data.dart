class LocationData {
  final String name;
  final double latitude;
  final double longitude;
  final String? country;
  final String? admin1;

  LocationData({
    required this.name,
    required this.latitude,
    required this.longitude,
    this.country,
    this.admin1,
  });

  factory LocationData.fromJson(Map<String, dynamic> json) {
    return LocationData(
      name: json['name'] ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      country: json['country'],
      admin1: json['admin1'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'country': country,
      'admin1': admin1,
    };
  }
}
