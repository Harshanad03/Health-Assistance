import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/splash_manager.dart';
import 'dart:async';

class SplashScreen1 extends StatefulWidget {
  const SplashScreen1({Key? key}) : super(key: key);

  @override
  State<SplashScreen1> createState() => _SplashScreen1State();
}

class _SplashScreen1State extends State<SplashScreen1>
    with TickerProviderStateMixin {
  late AnimationController _imageController;
  late AnimationController _quoteController;
  late AnimationController _fadeController;

  late Animation<double> _imageScale;
  late Animation<double> _imageOpacity;
  late Animation<double> _quoteSlide;
  late Animation<double> _quoteOpacity;
  late Animation<double> _fadeAnimation;

  Timer? _autoNavigateTimer;

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _imageController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _quoteController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // Define animations
    _imageScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _imageController, curve: Curves.elasticOut),
    );

    _imageOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _imageController, curve: Curves.easeIn));

    _quoteSlide = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(parent: _quoteController, curve: Curves.easeOutCubic),
    );

    _quoteOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _quoteController, curve: Curves.easeIn));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));

    // Start animations
    _startAnimations();

    // Auto-navigate after 8 seconds
    _autoNavigateTimer = Timer(const Duration(seconds: 8), () {
      if (mounted) {
        _navigateToLogin();
      }
    });
  }

  void _startAnimations() async {
    // Start image animation
    await _imageController.forward();

    // Start quote animation
    await _quoteController.forward();

    // Start fade animation
    await _fadeController.forward();
  }

  void _navigateToLogin() {
    SplashManager.navigateToLogin(context);
  }

  @override
  void dispose() {
    _imageController.dispose();
    _quoteController.dispose();
    _fadeController.dispose();
    _autoNavigateTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Set status bar to light mode for white text
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

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

                  // Centered image with animations
                  AnimatedBuilder(
                    animation: _imageController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _imageScale.value,
                        child: Opacity(
                          opacity: _imageOpacity.value,
                          child: Center(
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
                                      color: const Color(
                                        0xFF6CC5FF,
                                      ).withOpacity(0.1),
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
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 90),

                  // Quote section with neumorphic design and animations
                  AnimatedBuilder(
                    animation: _quoteController,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _quoteSlide.value),
                        child: Opacity(
                          opacity: _quoteOpacity.value,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 20,
                              ),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFE8EAFE),
                                    Color(0xFFD6E0FF),
                                  ],
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
                                  const Text(
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
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),

            // Auto-navigation indicator
            AnimatedBuilder(
              animation: _fadeController,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value,
                  child: const SizedBox(height: 30),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
