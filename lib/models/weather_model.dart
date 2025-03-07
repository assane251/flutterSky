class Weather {
  final String city;
  final double temperature;
  final String description;
  final double lat;
  final double lon;

  Weather({
    required this.city,
    required this.temperature,
    required this.description,
    required this.lat,
    required this.lon,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      city: json['name'],
      temperature: json['main']['temp'].toDouble(),
      description: json['weather'][0]['description'],
      lat: json['coord']['lat'].toDouble(),
      lon: json['coord']['lon'].toDouble(),
    );
  }
}