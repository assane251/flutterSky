import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
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
  List<Weather> weatherData = [];
  bool isLoading = true;

  final List<String> loadingMessages = [
    'Chargement des données…',
    'Un instant…',
    'Préparation en cours…',
  ];

  final List<String> cities = [
    'Dakar', 'Thiès', 'Fatick', 'Saint-Louis',
    'Conakry', 'Kindia',
    'Nouakchott', 'Nouadhibou', 'Tombouctou',
    'Banjul', 'Dubaï',
    'Paris', 'Réunion',
    'New York', 'Phoenix',
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

  Widget getWeatherIcon(String description, double temperature) {
    // switch (description.toLowerCase()) {
    //   case 'clear':
    //   case 'sunny':
    //     return Icon(Icons.wb_sunny, color: Colors.yellow[800], size: 40);
    //   case 'partly cloudy':
    //     return Icon(Icons.wb_cloudy, color: Colors.grey[400], size: 40);
    //   case 'cloudy':
    //   case 'overcast':
    //     return Icon(Icons.cloud, color: Colors.grey[600], size: 40);
    //   case 'rain':
    //   case 'light rain':
    //   case 'shower':
    //     return Icon(Icons.water_drop, color: Colors.blue[400], size: 40);
    //   case 'snow':
    //   case 'light snow':
    //     return Icon(Icons.ac_unit, color: Colors.blue[200], size: 40);
    //   case 'thunderstorm':
    //     return Icon(Icons.bolt, color: Colors.yellow[700], size: 40);
    //   default:
    //     return Icon(Icons.cloud, color: Colors.grey[600], size: 40);
    // }
    if (temperature < 15) {
      return Icon(Icons.water_drop, color: Colors.blue[400], size: 40);
    } else if (temperature >= 15 && temperature < 30) {
      return Icon(Icons.wb_sunny, color: Colors.yellow[800], size: 40);
    } else {
      return Icon(Icons.cloud, color: Colors.grey[600], size: 40);
    }
    // }
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
          colors: [Colors.blueGrey[200]!, Colors.blueGrey[400]!],
        ),
      ),
      child: Center(
        child: isLoading
            ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SpinKitDoubleBounce(color: Colors.white, size: 60),
            const SizedBox(height: 20),
            Text(
              loadingMessages[DateTime.now().second % loadingMessages.length],
              style: GoogleFonts.lato(
                fontSize: 22,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        )
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_queue, size: 100, color: Colors.white.withOpacity(0.9)),
            const SizedBox(height: 20),
            Text(
              'Bienvenue à Météo en direct',
              style: GoogleFonts.lato(
                fontSize: 36,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Découvrez la météo en temps réel',
              style: GoogleFonts.lato(
                fontSize: 18,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.9),
                foregroundColor: Colors.black87,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              ),
              onPressed: () => controller.animateToPage(1,
                  duration: const Duration(milliseconds: 400), curve: Curves.easeInOut),
              child: Text('Explorer', style: GoogleFonts.lato(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildWeatherPage() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.blueGrey[200]!, Colors.blueGrey[400]!],
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
                  margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ListTile(
                    title: Text(
                      weather.city,
                      style: GoogleFonts.lato(
                        fontSize: 24,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Row(
                      children: [
                        Text(
                          '${weather.temperature.toInt()}°',
                          style: GoogleFonts.lato(
                            fontSize: 32,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            weather.description,
                            style: GoogleFonts.lato(fontSize: 16, color: Colors.white70),
                          ),
                        ),
                      ],
                    ),
                    trailing: getWeatherIcon(weather.description, weather.temperature),
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
                  backgroundColor: Colors.white.withOpacity(0.9),
                  foregroundColor: Colors.black87,
                  padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                onPressed: fetchWeatherData,
                child: Text('Actualiser', style: GoogleFonts.lato(fontSize: 16)),
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
          colors: [Colors.blueGrey[200]!, Colors.blueGrey[400]!],
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.info_outline, size: 80, color: Colors.white.withOpacity(0.9)),
              const SizedBox(height: 20),
              Text(
                'À propos',
                style: GoogleFonts.lato(
                  fontSize: 32,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Météo en direct\nCréée avec Flutter\nDonnées par WeatherAPI',
                textAlign: TextAlign.center,
                style: GoogleFonts.lato(fontSize: 18, color: Colors.white70),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.9),
                  foregroundColor: Colors.black87,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                ),
                onPressed: () => controller.animateToPage(1,
                    duration: const Duration(milliseconds: 400), curve: Curves.easeInOut),
                child: Text('Retour', style: GoogleFonts.lato(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              effect: SlideEffect(
                spacing: 8.0,
                radius: 4.0,
                dotWidth: 8.0,
                dotHeight: 8.0,
                dotColor: Colors.white.withOpacity(0.5),
                activeDotColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  LatLng _getCityCoordinates(String city) {
    switch (city) {
      case 'Dakar': return LatLng(14.7247, -17.4844);
      case 'Thiès': return LatLng(14.7833, -16.9167);
      case 'Fatick': return LatLng(14.3333, -16.4167);
      case 'Saint-Louis': return LatLng(16.0333, -16.5);
      case 'Conakry': return LatLng(9.6412, -13.5784);
      case 'Kindia': return LatLng(10.0407, -12.8546);
      case 'Nouakchott': return LatLng(18.0735, -15.9582);
      case 'Nouadhibou': return LatLng(20.9419, -17.0363);
      case 'Tombouctou': return LatLng(16.7666, -3.0026);
      case 'Banjul': return LatLng(13.4549, -16.5790);
      case 'Dubaï': return LatLng(25.2769, 55.2962);
      case 'Paris': return LatLng(48.8584, 2.2945);
      case 'Réunion': return LatLng(-21.1151, 55.5364);
      case 'New York': return LatLng(40.7128, -74.0060);
      case 'Phoenix': return LatLng(33.4484, -112.0740);
      default: return LatLng(0.0, 0.0);
    }
  }
}