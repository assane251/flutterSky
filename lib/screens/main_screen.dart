import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../models/weather_model.dart';
import '../services/weather_service.dart';
import 'city_detail_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final controller = PageController(initialPage: 0);
  List<Weather> weatherData = [];
  bool isLoading = true;
  bool isDarkMode = false; // État pour suivre le mode sombre/clair

  final List<String> loadingMessages = [
    'Chargement des données…',
    'Un instant…',
    'Préparation en cours…',
  ];

  final List<String> cities = [
    'Dakar',
    'Thiès',
    'Fatick',
    'Saint-Louis',
    'Conakry',
    'Kindia',
    'Nouakchott',
    'Nouadhibou',
    'Tombouctou',
    'Banjul',
    'Dubaï',
    'Paris',
    'Réunion',
    'New York',
    'Phoenix',
  ];

  final WeatherService weatherService = WeatherService();

  @override
  void initState() {
    super.initState();
    fetchWeatherData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialiser isDarkMode ici, où le context est garanti d'être prêt
    setState(() {
      isDarkMode = Theme.of(context).brightness == Brightness.dark;
    });
  }

  void fetchWeatherData() async {
    setState(() {
      isLoading = true;
      weatherData.clear();
    });

    try {
      List<Weather> newWeatherData = [];
      for (String city in cities) {
        final weather = await weatherService.fetchWeather(city);
        newWeatherData.add(weather);
      }
      setState(() {
        weatherData = newWeatherData;
        isLoading = false;
      });
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Erreur de connexion",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP_RIGHT,
        backgroundColor: Colors.redAccent,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      setState(() => isLoading = false);
    }
  }

  Widget getWeatherIcon(
      BuildContext context, String description, double temperature) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    if (temperature < 15) {
      return Icon(Icons.water_drop,
          color: isDarkMode ? Colors.blue[200] : Colors.blue[400], size: 40);
    } else if (temperature >= 15 && temperature < 30) {
      return Icon(Icons.wb_sunny,
          color: isDarkMode ? Colors.yellow[600] : Colors.yellow[800],
          size: 40);
    } else {
      return Icon(Icons.cloud,
          color: isDarkMode ? Colors.grey[400] : Colors.grey[600], size: 40);
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Widget buildLoadingPage() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDarkMode
              ? [Colors.blueGrey[900]!, Colors.blueGrey[700]!]
              : [Colors.blueGrey[200]!, Colors.blueGrey[400]!],
        ),
      ),
      child: isLoading
          ? Center(
              child: LoadingAnimationWidget.fourRotatingDots(
                color: isDarkMode ? Colors.white : Colors.blue,
                size: 50,
              ),
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.cloud_queue,
                    size: 100,
                    color: isDarkMode
                        ? Colors.white70
                        : Colors.white.withOpacity(0.9)),
                const SizedBox(height: 20),
                Text(
                  'Météo en direct',
                  style: GoogleFonts.lato(
                    fontSize: 36,
                    color: isDarkMode ? Colors.white70 : Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Découvrez la météo en temps réel',
                  style: GoogleFonts.lato(
                    fontSize: 18,
                    color: isDarkMode ? Colors.grey[400] : Colors.white70,
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDarkMode
                        ? Colors.grey[800]
                        : Colors.white.withOpacity(0.9),
                    foregroundColor: isDarkMode ? Colors.white : Colors.black87,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25)),
                  ),
                  onPressed: () => controller.animateToPage(1,
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeInOut),
                  child:
                      Text('Explorer', style: GoogleFonts.lato(fontSize: 18)),
                ),
              ],
            ),
    );
  }

  Widget buildWeatherPage() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDarkMode
              ? [Colors.blueGrey[900]!, Colors.blueGrey[700]!]
              : [Colors.blueGrey[200]!, Colors.blueGrey[400]!],
        ),
      ),
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: weatherData.length,
              itemBuilder: (context, index) {
                final weather = weatherData[index];
                return Container(
                  margin:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? Colors.black.withOpacity(0.3)
                        : Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ListTile(
                    title: Text(
                      weather.city,
                      style: GoogleFonts.lato(
                        fontSize: 24,
                        color: isDarkMode ? Colors.white70 : Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Row(
                      children: [
                        Text(
                          '${weather.temperature.toInt()}°',
                          style: GoogleFonts.lato(
                            fontSize: 40,
                            color: isDarkMode ? Colors.white70 : Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            weather.description,
                            style: GoogleFonts.lato(
                              fontSize: 18,
                              color: isDarkMode
                                  ? Colors.grey[400]
                                  : Colors.white70,
                            ),
                          ),
                        ),
                      ],
                    ),
                    trailing: getWeatherIcon(
                        context, weather.description, weather.temperature),
                    onTap: () {
                      final coordinates = _getCityCoordinates(weather.city);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CityDetailScreen(
                            cityCoordinates: coordinates,
                            cityName: weather.city,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDarkMode
                      ? Colors.grey[800]
                      : Colors.white.withOpacity(0.9),
                  foregroundColor: isDarkMode ? Colors.white : Colors.black87,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                ),
                onPressed: fetchWeatherData,
                child:
                    Text('Actualiser', style: GoogleFonts.lato(fontSize: 16)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildAboutPage() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDarkMode
              ? [Colors.blueGrey[900]!, Colors.blueGrey[700]!]
              : [Colors.blueGrey[200]!, Colors.blueGrey[400]!],
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.info_outline,
                  size: 80,
                  color: isDarkMode
                      ? Colors.white70
                      : Colors.white.withOpacity(0.9)),
              const SizedBox(height: 20),
              Text(
                'À propos',
                style: GoogleFonts.lato(
                  fontSize: 32,
                  color: isDarkMode ? Colors.white70 : Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Météo en direct\nCréée avec Flutter\nDonnées par WeatherAPI',
                textAlign: TextAlign.center,
                style: GoogleFonts.lato(
                  fontSize: 18,
                  color: isDarkMode ? Colors.grey[400] : Colors.white70,
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDarkMode
                      ? Colors.grey[800]
                      : Colors.white.withOpacity(0.9),
                  foregroundColor: isDarkMode ? Colors.white : Colors.black87,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25)),
                ),
                onPressed: () => controller.animateToPage(1,
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut),
                child: Text('Retour', style: GoogleFonts.lato(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void toggleTheme() {
    setState(() {
      isDarkMode = !isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: isDarkMode ? ThemeData.dark() : ThemeData.light(),
      child: Scaffold(
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SmoothPageIndicator(
                    controller: controller,
                    count: 3,
                    effect: SlideEffect(
                      spacing: 8.0,
                      radius: 4.0,
                      dotWidth: 8.0,
                      dotHeight: 8.0,
                      dotColor: Colors.grey[600]!,
                      activeDotColor:
                          isDarkMode ? Colors.white70 : Colors.black,
                    ),
                  ),
                  const SizedBox(width: 20),
                  IconButton(
                    icon: Icon(
                        isDarkMode ? Icons.wb_sunny : Icons.nightlight_round),
                    color: isDarkMode ? Colors.white70 : Colors.black,
                    onPressed: toggleTheme,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  LatLng _getCityCoordinates(String city) {
    switch (city) {
      case 'Dakar':
        return LatLng(14.7247, -17.4844);
      case 'Thiès':
        return LatLng(14.7833, -16.9167);
      case 'Fatick':
        return LatLng(14.3333, -16.4167);
      case 'Saint-Louis':
        return LatLng(16.0333, -16.5);
      case 'Conakry':
        return LatLng(9.6412, -13.5784);
      case 'Kindia':
        return LatLng(10.0407, -12.8546);
      case 'Nouakchott':
        return LatLng(18.0735, -15.9582);
      case 'Nouadhibou':
        return LatLng(20.9419, -17.0363);
      case 'Tombouctou':
        return LatLng(16.7666, -3.0026);
      case 'Banjul':
        return LatLng(13.4549, -16.5790);
      case 'Dubaï':
        return LatLng(25.2769, 55.2962);
      case 'Paris':
        return LatLng(48.8584, 2.2945);
      case 'Réunion':
        return LatLng(-21.1151, 55.5364);
      case 'New York':
        return LatLng(40.7128, -74.0060);
      case 'Phoenix':
        return LatLng(33.4484, -112.0740);
      default:
        return LatLng(0.0, 0.0);
    }
  }
}
