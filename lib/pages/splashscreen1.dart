import 'package:flutter/material.dart';
// import 'dart:async'; // No longer needed

class SplashScreen1 extends StatefulWidget {
  const SplashScreen1({Key? key}) : super(key: key);

  @override
  State<SplashScreen1> createState() => _SplashScreen1State();
}

class _SplashScreen1State extends State<SplashScreen1> {
  // Removed Timer logic from initState

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 215, 223, 247),
      body: SafeArea(
        child: Stack(
          children: [
            // Main content scrollable
            SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 100),
                  // Centered image
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        'assert/splash2.png',
                        width: 300,
                        height: 330,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              color: const Color(0xFF6CC5FF).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(
                              Icons.image,
                              size: 60,
                              color: Color(0xFF6CC5FF),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 90),
                  // Quote section with neumorphic design
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 20,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFE8EAFE), Color(0xFFD6E0FF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.8),
                            offset: const Offset(-4, -4),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                          BoxShadow(
                            color: const Color.fromARGB(
                              255,
                              5,
                              5,
                              167,
                            ).withOpacity(0.4),
                            offset: const Offset(4, 4),
                            blurRadius: 12,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.format_quote,
                            color: Color(0xFF6CC5FF),
                            size: 35,
                          ),
                          const SizedBox(height: 15),
                          const Text(
                            '"Health is not just about being free from disease, it\'s about living a life of vitality and wellness."',
                            style: TextStyle(
                              fontSize: 18,
                              color: Color.fromARGB(255, 44, 66, 113),
                              fontWeight: FontWeight.w500,
                              fontStyle: FontStyle.italic,
                              height: 1.4,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 15),
                          Text(
                            '- Health Assistant',
                            style: TextStyle(
                              fontSize: 15,
                              color: Color(0xFF6B7A90),
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
            // Bottom right skip arrow button
            Positioned(
              top: 12,
              right: 32,
              child: FloatingActionButton(
                backgroundColor: const Color.fromARGB(255, 1, 25, 59),
                foregroundColor: Colors.white,
                onPressed: () {
                  Navigator.of(context).pushReplacementNamed('/login');
                },
                child: const Icon(Icons.arrow_forward_rounded, size: 28),
                tooltip: 'Skip',
                elevation: 4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
