import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confetti/confetti.dart';
import 'package:google_fonts/google_fonts.dart';
import 'main_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 5));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDarkMode
                ? [Colors.blueGrey[900]!, Colors.blueGrey[700]!]
                : [Colors.blueGrey[200]!, Colors.blueGrey[400]!],
          ),
        ),
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.wb_sunny, size: 100, color: Colors.white.withOpacity(0.9))
                    .animate()
                    .fadeIn(duration: 1200.ms)
                    .rotate(duration: 2000.ms, begin: 0, end: 1),
                const SizedBox(height: 20),
                Text(
                  "Météo en direct",
                  style: GoogleFonts.lato(
                    fontSize: 36,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ).animate().fadeIn(duration: 1500.ms).slideY(begin: 0.5, end: 0, duration: 800.ms),
                const SizedBox(height: 10),
                Text(
                  "Votre météo, en temps réel",
                  style: GoogleFonts.lato(fontSize: 18, color: Colors.white70),
                ).animate().fadeIn(duration: 1800.ms),
                const SizedBox(height: 50),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: SizedBox(
                    height: 50,
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.9),
                        foregroundColor: Colors.black87,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                      ),
                      onPressed: () {
                        _confettiController.play();
                        Future.delayed(const Duration(seconds: 1), () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => const MainScreen()),
                                (route) => false,
                          );
                        });
                      },
                      child: Text("Commencer", style: GoogleFonts.lato(fontSize: 18)),
                    ),
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                colors: const [
                  Colors.blue,
                  Colors.white,
                  Colors.yellow,
                  Colors.red,
                  Colors.green,
                ],
                numberOfParticles: 50,
                maxBlastForce: 60,
                minBlastForce: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}