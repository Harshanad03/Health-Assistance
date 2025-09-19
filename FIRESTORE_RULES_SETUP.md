# Firestore Security Rules Setup

## Current Issue
The History page might not be showing measurements due to Firestore security rules. 

## Required Firestore Rules

Add these rules to your Firestore Security Rules in the Firebase Console:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow users to read and write their own profile
    match /profiles/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Allow users to read and write their own measurements
    match /measurements/{measurementId} {
      allow read, write: if request.auth != null && 
        request.auth.uid == resource.data.userId;
      allow create: if request.auth != null && 
        request.auth.uid == request.resource.data.userId;
    }
  }
}
```

## How to Apply These Rules

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: `health-assistant-a4ab2`
3. Navigate to **Firestore Database**
4. Click on **Rules** tab
5. Replace the existing rules with the rules above
6. Click **Publish**

## Testing the Rules

After applying the rules:

1. Open your app
2. Go to the History tab
3. Click the **"Test Save"** button to create a test measurement
4. Click **"Refresh"** to reload the history
5. The measurement should now appear in the history

## Current Database Structure

Your measurements are stored with this structure:
```
measurements/
  └── {userId}_{timestamp}/
      ├── id: string
      ├── userId: string  
      ├── type: "heartRate" | "bloodPressure"
      ├── timestamp: Timestamp
      ├── values: { heartRate?: number, systolic?: number, diastolic?: number }
      └── metadata: { age?: number, isNormal?: boolean, ... }
```

## Debug Information

The app now includes debug logging that will show in the console:
- User authentication status
- Number of measurements found
- Any Firebase errors

Check the browser console (F12) or device logs for detailed error messages.
