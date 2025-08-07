import 'package:flutter/material.dart';
import 'dart:async';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), () {
      Navigator.of(context).pushReplacementNamed('/splashscreen1');
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double logoSize = 100;
    final double curveHeight = 320;
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 215, 223, 247),
      body: Column(
        children: [
          // Top section: Stack with wavy blue gradient and logo
          Stack(
            clipBehavior: Clip.none,
            children: [
              // Wavy blue gradient background
              SizedBox(
                width: size.width,
                height: curveHeight,
                child: ClipPath(
                  clipper: _WavyClipper(),
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color.fromARGB(255, 1, 25, 59),
                          Color.fromARGB(255, 1, 29, 48),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                ),
              ),
              // Floating logo/avatar (moved higher)
              Positioned(
                left: 0,
                right: 0,
                bottom: -logoSize / 2 + 30, // Move the circle up by 30 pixels
                child: Center(
                  child: Container(
                    width: logoSize,
                    height: logoSize,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromARGB(
                            255,
                            1,
                            22,
                            40,
                          ).withOpacity(0.12),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Container(
                      margin: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [
                            Color.fromARGB(255, 1, 21, 50),
                            Color(0xFF6CC5FF),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: const Icon(
                        Icons.health_and_safety,
                        size: 44,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Spacer to account for logo overlap
          SizedBox(height: logoSize / 2 + 36),
          // App name and subtitle
          const Text(
            'Health Assistant',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A2947),
              letterSpacing: 1.1,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 18),
          const Text(
            'A platform built for a new way of health',
            style: TextStyle(
              fontSize: 17,
              color: Color(0xFF6B7A90),
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
          const Expanded(child: SizedBox()),
        ],
      ),
    );
  }
}

class _WavyClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 60);
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height,
      size.width * 0.5,
      size.height - 40,
    );
    path.quadraticBezierTo(
      size.width * 0.75,
      size.height - 80,
      size.width,
      size.height - 20,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
