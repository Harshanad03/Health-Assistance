class AppRoutes {
  // Splash and Onboarding
  static const String splash = '/';
  static const String splashScreen1 = '/splashscreen1';

  // Authentication
  static const String login = '/login';
  static const String signup = '/signup';
  static const String createAccount = '/create_account';
  static const String forgetPassword = '/forget_password';

  // Main App
  static const String home = '/home';
  static const String profile = '/profile';
  static const String editProfile = '/edit_profile';
  static const String documents = '/documents';
  static const String heartRate = '/heart_rate';
  static const String bpMeasurement = '/bp_measurement';

  // Helper method to get all routes
  static Map<String, String> get allRoutes => {
    splash: 'Splash',
    splashScreen1: 'Splash Screen 1',
    login: 'Login',
    signup: 'Sign Up',
    createAccount: 'Create Account',
    forgetPassword: 'Forgot Password',
    home: 'Home',
    profile: 'Profile',
    editProfile: 'Edit Profile',
    documents: 'Documents',
    heartRate: 'Heart Rate Monitor',
    bpMeasurement: 'Blood Pressure Monitor',
  };
}
