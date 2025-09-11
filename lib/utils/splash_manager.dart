import 'package:flutter/material.dart';
import '../pages/splashscreen1.dart';
import '../pages/login_page.dart';
import '../utils/routes.dart';

class SplashManager {
  static const Duration _firstSplashDuration = Duration(milliseconds: 3500);
  static const Duration _secondSplashDuration = Duration(seconds: 8);
  static const Duration _transitionDuration = Duration(milliseconds: 1000);

  /// Navigate from first splash to second splash with smooth transition
  static void navigateToSecondSplash(BuildContext context) {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const SplashScreen1(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(1.0, 0.0),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeInOutCubic,
                    ),
                  ),
              child: child,
            ),
          );
        },
        transitionDuration: _transitionDuration,
      ),
    );
  }

  /// Navigate from second splash to login with smooth transition
  static void navigateToLogin(BuildContext context) {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const LoginPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(0.0, 1.0),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeInOutCubic,
                    ),
                  ),
              child: child,
            ),
          );
        },
        transitionDuration: _transitionDuration,
      ),
    );
  }

  /// Navigate directly to login (skip splash screens)
  static void skipToLogin(BuildContext context) {
    Navigator.of(context).pushReplacementNamed(AppRoutes.login);
  }

  /// Get recommended splash durations
  static Duration get firstSplashDuration => _firstSplashDuration;
  static Duration get secondSplashDuration => _secondSplashDuration;
  static Duration get transitionDuration => _transitionDuration;
}

/// Custom page route for splash transitions
class SplashPageRoute extends PageRouteBuilder {
  final Widget page;
  final Offset slideDirection;

  SplashPageRoute({
    required this.page,
    this.slideDirection = const Offset(1.0, 0.0),
  }) : super(
         pageBuilder: (context, animation, secondaryAnimation) => page,
         transitionsBuilder: (context, animation, secondaryAnimation, child) {
           return FadeTransition(
             opacity: animation,
             child: SlideTransition(
               position: Tween<Offset>(begin: slideDirection, end: Offset.zero)
                   .animate(
                     CurvedAnimation(
                       parent: animation,
                       curve: Curves.easeInOutCubic,
                     ),
                   ),
               child: child,
             ),
           );
         },
         transitionDuration: SplashManager.transitionDuration,
       );
}
