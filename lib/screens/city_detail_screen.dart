import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/weather_model.dart';

class CityDetailScreen extends StatelessWidget {
  final Weather weather;

  const CityDetailScreen({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(weather.city)),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text('Température : ${weather.temperature}°C'),
                Text('Description : ${weather.description}'),
              ],
            ),
          ),
          Expanded(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(weather.lat, weather.lon),
                zoom: 10,
              ),
              markers: {
                Marker(
                  markerId: MarkerId(weather.city),
                  position: LatLng(weather.lat, weather.lon),
                ),
              },
            ),
          ),
        ],
      ),
    );
  }
}