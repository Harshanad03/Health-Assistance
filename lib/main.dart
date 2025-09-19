import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'pages/splash_page.dart';
import 'pages/splashscreen1.dart';
import 'pages/login_page.dart';
import 'pages/signup_page.dart';
import 'pages/create_account_page.dart';
import 'pages/home_page.dart';
import 'pages/main_container_page.dart';
import 'pages/forget_password_page.dart';
import 'pages/profile_page.dart';
import 'pages/heart_rate_page.dart';
import 'pages/bp_measurement_page.dart';
import 'utils/routes.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart' show SystemUiOverlayStyle;
import 'services/local_storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialized successfully');
  } catch (e) {
    print('Firebase initialization failed: $e');
    print('App will continue without Firebase features');
  }

  runApp(MyApp(initialRoute: AppRoutes.splash));
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  const MyApp({super.key, this.initialRoute = AppRoutes.splash});

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      try {
        if (Uri.base.fragment != '/' && Uri.base.fragment != '') {}
      } catch (e) {}
    }

    return MaterialApp(
      title: 'AUVI',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          systemOverlayStyle: SystemUiOverlayStyle.light,
        ),
      ),
      initialRoute: initialRoute,
      routes: {
        AppRoutes.splash: (context) => const SplashPage(),
        AppRoutes.splashScreen1: (context) => const SplashScreen1(),
        AppRoutes.login: (context) => const LoginPage(),
        AppRoutes.signup: (context) => const SignupPage(),
        AppRoutes.createAccount: (context) => const CreateAccountPage(),
        AppRoutes.main: (context) => const MainContainerPage(),
        AppRoutes.mainProfile:
            (context) => const MainContainerPage(initialTabIndex: 1),
        AppRoutes.home: (context) => const HomePage(),
        AppRoutes.forgetPassword: (context) => const ForgetPasswordPage(),
        AppRoutes.profile: (context) => const ProfilePage(),
        AppRoutes.heartRate: (context) => const HeartRatePage(),
        AppRoutes.bpMeasurement: (context) => const BPMeasurementPage(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
