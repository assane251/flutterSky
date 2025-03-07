import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../services/weather_service.dart';
import '../models/weather_model.dart';
import 'city_detail_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final controller = PageController(initialPage: 0);
  double progress = 0.0;
  List<Weather> weatherData = [];
  bool isLoading = true;
  int messageIndex = 0;
  Timer? _timer;

  final List<String> loadingMessages = [
    'Nous téléchargeons les données…',
    'C’est presque fini…',
    'Plus que quelques secondes…',
  ];

  final List<String> cities = [
    'Mauritanie',
    'Senegal',
    'Gambie',
    'Guinée',
    'London',
    'Tokyo',
    'New York',
    'Mali'
  ];

  final WeatherService weatherService = WeatherService();

  @override
  void initState() {
    super.initState();
    fetchWeatherData();
  }

  void fetchWeatherData() async {
    setState(() {
      isLoading = true;
      progress = 0.0;
      weatherData.clear();
    });

    _timer = Timer.periodic(Duration(milliseconds: 500), (timer) async {
      if (progress >= 1.0 && weatherData.length == cities.length) {
        timer.cancel();
        setState(() => isLoading = false);
        return;
      }

      setState(() {
        progress = weatherData.length / cities.length;
        messageIndex = (messageIndex + 1) % loadingMessages.length;
      });

      try {
        if (weatherData.length < cities.length) {
          final weather = await weatherService.fetchWeather(cities[weatherData.length]);
          setState(() {
            weatherData.add(weather);
          });
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : $e')),
        );
      }
    });
  }

  Widget getWeatherIcon(double temperature) {
    try {
      if (temperature > 25) {
        return Icon(
          Icons.wb_sunny,
          color: Colors.orange[700],
          size: 40,
        );
      } else if (temperature < 10) {
        return Icon(
          Icons.ac_unit,
          color: Colors.blue[300],
          size: 40,
        );
      } else {
        return Icon(
          Icons.cloud,
          color: Colors.grey[600],
          size: 40,
        );
      }
    } catch (e) {
      // Fallback to Material icons if weather_icons fail
      print('Weather icons failed to load: $e');
      if (temperature > 25) {
        return Icon(
          Icons.wb_sunny,
          color: Colors.orange[700],
          size: 40,
        );
      } else if (temperature < 10) {
        return Icon(
          Icons.ac_unit,
          color: Colors.blue[300],
          size: 40,
        );
      } else {
        return Icon(
          Icons.cloud,
          color: Colors.grey[600],
          size: 40,
        );
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    controller.dispose();
    super.dispose();
  }

  Widget buildLoadingPage() {
    return Center(
      child: isLoading
          ? Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LinearProgressIndicator(value: progress),
          const SizedBox(height: 20),
          Text(
            loadingMessages[messageIndex],
            style: GoogleFonts.greatVibes(fontSize: 24),
          ),
          const SizedBox(height: 20),
          SpinKitCircle(color: Theme.of(context).primaryColor),
        ],
      )
          : Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Bienvenue!',
            // style: GoogleFonts.greatVibes(
            //   fontSize: 36,
            //   fontWeight: FontWeight.bold,
            // ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => controller.animateToPage(1,
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut),
            child: const Text('Voir la météo'),
          ),
        ],
      ),
    );
  }

  Widget buildWeatherPage() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: weatherData.length,
            itemBuilder: (context, index) {
              final weather = weatherData[index];
              return ListTile(
                title: Text(
                  weather.city,
                  style: GoogleFonts.greatVibes(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Row(
                  children: [
                    Text(
                      '${weather.temperature}',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '°C',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '- ${weather.description}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
                trailing: getWeatherIcon(weather.temperature),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CityDetailScreen(weather: weather),
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: fetchWeatherData,
            child: const Text('Actualiser'),
          ),
        ),
      ],
    );
  }

  Widget buildAboutPage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'À propos',
              style: GoogleFonts.greatVibes(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Application météo en temps réel\nDéveloppée avec Flutter\nDonnées fournies par WeatherAPI',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => controller.animateToPage(1,
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut),
              child: const Text('Retour à la météo'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Icon(
          Icons.cloud,
          color: Colors.white,
        ),
        title: Text(
          'Météo en Temps Réel',
          // style: GoogleFonts.greatVibes(
          //   fontSize: 35,
          //   color: Colors.white,
          // ),
        ),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: controller,
              children: [
                buildLoadingPage(),
                buildWeatherPage(),
                buildAboutPage(),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: SmoothPageIndicator(
              controller: controller,
              count: 3,
              effect: const SlideEffect(
                spacing: 8.0,
                radius: 4.0,
                dotWidth: 12.0,
                dotHeight: 12.0,
                dotColor: Colors.grey,
                activeDotColor: Colors.indigo,
              ),
            ),
          ),
        ],
      ),
    );
  }
}