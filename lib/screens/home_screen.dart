import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confetti/confetti.dart';
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
    // Initialisation du contrôleur de confettis (durée de 3 secondes)
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue, Color(0xFFB0E0E6)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 50.0),
                  // child: Image.asset(
                  //   'images/logo.png',
                  //   fit: BoxFit.contain,
                  //   height: 120,
                  // ).animate().fadeIn(duration: 1000.ms).scale(),
                ),
                const SizedBox(height: 30),
                const Icon(
                  Icons.wb_sunny,
                  size: 80,
                  color: Colors.white,
                )
                    .animate()
                    .fadeIn(duration: 1200.ms)
                    .rotate(duration: 2000.ms, begin: 0, end: 1),
                const SizedBox(height: 20),
                const Text(
                  "Bienvenue, futur météorologue !",
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                )
                    .animate()
                    .fadeIn(duration: 1500.ms)
                    .slideY(begin: 0.5, end: 0, duration: 800.ms),
                const SizedBox(height: 50),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: SizedBox(
                    height: 50,
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
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
                      child: const Text(
                        "Lancer l'aventure",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
                  Colors.green,
                  Colors.yellow,
                  Colors.red,
                  Colors.white,
                ],
                numberOfParticles: 20,
                maxBlastForce: 50,
                minBlastForce: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}