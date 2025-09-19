import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import '../utils/splash_manager.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _fadeController;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _textSlide;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _textController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _logoOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _logoController, curve: Curves.easeIn));

    _textSlide = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOutCubic),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));

    _startAnimations();
  }

  void _startAnimations() async {
    await _logoController.forward();

    await _textController.forward();

    await _fadeController.forward();

    _navigateAfterDelay();
  }

  void _navigateAfterDelay() async {
    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      SplashManager.navigateToSecondSplash(context);
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    final size = MediaQuery.of(context).size;
    final double logoSize = 120;
    final double curveHeight = 320;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 215, 223, 247),
      body: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
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

              Positioned(
                left: 0,
                right: 0,
                bottom: -logoSize / 2 + 30,
                child: Center(
                  child: AnimatedBuilder(
                    animation: _logoController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _logoScale.value,
                        child: Opacity(
                          opacity: _logoOpacity.value,
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
                              child: ClipOval(
                                child: Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                  ),
                                  child: ClipOval(
                                    child: Image.asset(
                                      'assets/logo.jpg',
                                      width: 40,
                                      height: 40,
                                      fit: BoxFit.cover,
                                      errorBuilder: (
                                        context,
                                        error,
                                        stackTrace,
                                      ) {
                                        return const Icon(
                                          Icons.health_and_safety,
                                          size: 40,
                                          color: Color.fromARGB(255, 1, 25, 59),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: logoSize / 2 + 36),

          AnimatedBuilder(
            animation: _textController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _textSlide.value),
                child: Opacity(
                  opacity: _textController.value,
                  child: Column(
                    children: [
                      const Text(
                        'AUVI',
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
                        'Advanced Health Monitoring & Analysis',
                        style: TextStyle(
                          fontSize: 17,
                          color: Color(0xFF6B7A90),
                          fontWeight: FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          const Expanded(child: SizedBox()),

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
