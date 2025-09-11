# Google Sign-In Setup Guide for Flutter Health Assistant App

## Overview
This guide explains how to set up Google Sign-In authentication in your Flutter Health Assistant app using Firebase Authentication.

## Prerequisites
- Flutter SDK installed
- Firebase project created
- Google Cloud Console access
- Android/iOS development environment

## Step 1: Firebase Project Setup

### 1.1 Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a project"
3. Enter project name: "Health Assistant"
4. Enable Google Analytics (optional)
5. Click "Create project"

### 1.2 Enable Authentication
1. In Firebase Console, go to "Authentication"
2. Click "Get started"
3. Go to "Sign-in method" tab
4. Enable "Google" provider
5. Add your support email
6. Click "Save"

### 1.3 Get Firebase Configuration
1. Go to Project Settings (gear icon)
2. Scroll down to "Your apps"
3. Click "Add app" and select platform (Android/iOS)
4. Follow setup instructions for each platform

## Step 2: Android Setup

### 2.1 Add SHA-1 Fingerprint
1. Get your debug SHA-1:
   ```bash
   cd android
   ./gradlew signingReport
   ```
2. Copy the SHA-1 from debug variant
3. Add it to Firebase Console → Project Settings → Your apps → Android app

### 2.2 Update google-services.json
1. Download `google-services.json` from Firebase Console
2. Place it in `android/app/` directory
3. Ensure it's added to `.gitignore`

### 2.3 Update build.gradle
In `android/app/build.gradle`, ensure you have:
```gradle
apply plugin: 'com.google.gms.google-services'
```

In `android/build.gradle`, ensure you have:
```gradle
classpath 'com.google.gms:google-services:4.3.15'
```

## Step 3: iOS Setup

### 3.1 Add GoogleService-Info.plist
1. Download `GoogleService-Info.plist` from Firebase Console
2. Add it to your iOS project using Xcode
3. Ensure it's added to `.gitignore`

### 3.2 Update Info.plist
Add URL schemes to `ios/Runner/Info.plist`:
```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLName</key>
        <string>REVERSED_CLIENT_ID</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>YOUR_REVERSED_CLIENT_ID</string>
        </array>
    </dict>
</array>
```

## Step 4: Update Firebase Configuration

### 4.1 Update firebase_options.dart
Replace placeholder values in `lib/firebase_options.dart` with your actual Firebase configuration:

```dart
static const FirebaseOptions android = FirebaseOptions(
  apiKey: 'your-actual-android-api-key',
  appId: 'your-actual-android-app-id',
  messagingSenderId: 'your-actual-sender-id',
  projectId: 'your-actual-project-id',
  storageBucket: 'your-actual-project-id.appspot.com',
);
```

### 4.2 Run FlutterFire CLI (Alternative)
Instead of manually editing, you can use FlutterFire CLI:
```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

## Step 5: Install Dependencies

### 5.1 Get Dependencies
```bash
flutter pub get
```

### 5.2 Platform-specific Setup
```bash
# For Android
cd android
./gradlew clean

# For iOS
cd ios
pod install
```

## Step 6: Testing

### 6.1 Test Google Sign-In
1. Run the app
2. Go to Login or Signup page
3. Tap "Continue with Google" or "Sign up with Google"
4. Select Google account
5. Verify successful authentication

### 6.2 Debug Common Issues
- Check Firebase Console for authentication logs
- Verify SHA-1 fingerprint matches
- Ensure Google Play Services are up to date
- Check internet connectivity

## Step 7: Production Deployment

### 7.1 Release SHA-1
1. Generate release SHA-1 from your keystore
2. Add it to Firebase Console
3. Update `google-services.json`

### 7.2 App Store/Play Store
1. Follow platform-specific deployment guides
2. Ensure privacy policy mentions Google Sign-In
3. Test on real devices before release

## Troubleshooting

### Common Issues

#### "Google Sign-In failed"
- Check Firebase configuration
- Verify Google Sign-In is enabled in Firebase Console
- Check internet connectivity

#### "SHA-1 fingerprint mismatch"
- Ensure debug and release SHA-1 are added to Firebase
- Regenerate `google-services.json` after adding SHA-1

#### "Google Play Services not available"
- Update Google Play Services on test device
- Test on device with latest Google Play Services

### Debug Commands
```bash
# Check Firebase connection
flutter run --verbose

# Verify dependencies
flutter doctor

# Clean and rebuild
flutter clean
flutter pub get
```

## Security Considerations

### 1. API Key Security
- Never commit API keys to public repositories
- Use environment variables for sensitive data
- Restrict API key usage in Google Cloud Console

### 2. User Data Privacy
- Implement proper data handling
- Follow GDPR/CCPA compliance
- Secure user profile information

### 3. Authentication Flow
- Implement proper session management
- Add logout functionality
- Handle authentication state changes

## Additional Features

### 1. User Profile Management
- Store additional user data in Firebase
- Implement profile picture upload
- Add user preferences

### 2. Social Features
- Add Facebook Sign-In
- Implement Apple Sign-In for iOS
- Add email/password fallback

### 3. Analytics
- Track authentication events
- Monitor user engagement
- Analyze sign-in success rates

## Support Resources

- [Firebase Documentation](https://firebase.google.com/docs)
- [Google Sign-In Flutter Plugin](https://pub.dev/packages/google_sign_in)
- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Google Cloud Console](https://console.cloud.google.com/)

## Conclusion

Following this guide will enable Google Sign-In authentication in your Flutter Health Assistant app. The integration provides a seamless user experience while maintaining security best practices.

Remember to:
- Test thoroughly on both platforms
- Handle edge cases gracefully
- Implement proper error handling
- Follow platform-specific guidelines
- Keep dependencies updated

For additional support, refer to the official documentation or community forums.
