import 'package:flutter/material.dart';
import 'pages/splash_page.dart';
import 'pages/splashscreen1.dart';
import 'pages/login_page.dart';
import 'pages/home_page.dart';
import 'pages/signup_page.dart';
import 'pages/create_account_page.dart';
import 'pages/forget_password_page.dart';
import 'pages/profile_page.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Force redirect to root if not already there (web only)
    if (kIsWeb) {
      try {
        // Import dart:html only when needed
        dynamic html = null;
        if (Uri.base.fragment != '/' && Uri.base.fragment != '') {
          // This will only work on web platforms
          // For mobile, this will be ignored
        }
      } catch (e) {
        // Ignore errors on non-web platforms
      }
    }

    return MaterialApp(
      title: 'Smart Mobile Health Assistant',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashPage(),
        '/splashscreen1': (context) => const SplashScreen1(),
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignupPage(),
        '/create_account': (context) => const CreateAccountPage(),
        '/home': (context) => const HomePage(),
        '/forget_password': (context) => const ForgetPasswordPage(),
        '/profile': (context) => const ProfilePage(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
