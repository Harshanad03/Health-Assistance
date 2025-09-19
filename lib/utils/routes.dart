class AppRoutes {
  static const String splash = '/';
  static const String splashScreen1 = '/splashscreen1';

  static const String login = '/login';
  static const String signup = '/signup';
  static const String createAccount = '/create_account';
  static const String forgetPassword = '/forget_password';

  static const String main = '/main';
  static const String mainProfile =
      '/main_profile'; // Main container starting with profile tab
  static const String home = '/home'; // Keep for backward compatibility
  static const String profile = '/profile'; // Keep for backward compatibility
  static const String editProfile = '/edit_profile';
  static const String documents = '/documents';
  static const String history = '/history';
  static const String heartRate = '/heart_rate';
  static const String bpMeasurement = '/bp_measurement';

  static Map<String, String> get allRoutes => {
    splash: 'Splash',
    splashScreen1: 'Splash Screen 1',
    login: 'Login',
    signup: 'Sign Up',
    createAccount: 'Create Account',
    forgetPassword: 'Forgot Password',
    main: 'Main Container',
    home: 'Home',
    profile: 'Profile',
    editProfile: 'Edit Profile',
    documents: 'Documents',
    history: 'History',
    heartRate: 'AUVI Heart Rate Monitor',
    bpMeasurement: 'AUVI Blood Pressure Monitor',
  };
}
