import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'game_screen.dart';

const String _fontFamily = 'GreatsRacing';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _animation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startGame() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const GameScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Colors.blue.shade900,
              Colors.black,
              Colors.grey.shade800,
            ],
            stops: const [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Title
                Text(
                  'ACTION RIDER',
                  style: TextStyle(
                    fontFamily: _fontFamily,
                    fontSize: 56,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 6,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.8),
                        offset: const Offset(4, 4),
                        blurRadius: 10,
                      ),
                      Shadow(
                        color: Colors.blue.shade900.withOpacity(0.5),
                        offset: const Offset(-2, -2),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 60),
                // Tap to play button
                ScaleTransition(
                  scale: _animation,
                  child: GestureDetector(
                    onTap: _startGame,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 70,
                        vertical: 25,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white,
                            Colors.blue.shade900,
                            Colors.black,
                            Colors.grey.shade700,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(35),
                        border: Border.all(
                          color: Colors.white,
                          width: 4,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.6),
                            offset: const Offset(5, 5),
                            blurRadius: 10,
                          ),
                          BoxShadow(
                            color: Colors.blue.shade900.withOpacity(0.3),
                            offset: const Offset(-3, -3),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Text(
                        'TAP TO PLAY',
                        style: TextStyle(
                          fontFamily: _fontFamily,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 3,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

