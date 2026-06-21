# Firebase Setup for Lizard Fitness

## 1. Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Click "Add project" → name it `lizard-fitness`
3. Enable Google Analytics (optional)

## 2. Enable Firebase Services

### Auth
- Firebase Console → Authentication → Get started
- Enable **Email/Password** provider

### Firestore
- Firebase Console → Firestore Database → Create database
- Start in **production mode**
- Choose your region (e.g. `europe-west2` for UK)

### Storage
- Firebase Console → Storage → Get started
- Start in **production mode**

## 3. Add Apps

### iOS
- Firebase Console → Project settings → Add app → iOS
- Bundle ID: `com.lizardfitness.lizardFitness`
- Download `GoogleService-Info.plist`
- Place in `ios/Runner/`

### Android
- Firebase Console → Project settings → Add app → Android
- Package name: `com.lizardfitness.lizard_fitness`
- Download `google-services.json`
- Place in `android/app/`

## 4. Run FlutterFire CLI

```bash
dart pub global activate flutterfire_cli
flutterfire configure --project=lizard-fitness
```

This replaces `lib/firebase_options.dart` with your real config.

## 5. Deploy Security Rules

```bash
npm install -g firebase-tools
firebase login
firebase init  # select Firestore + Storage
firebase deploy --only firestore:rules,storage
```

Use `firestore.rules` and `storage.rules` at repo root when prompted, or deploy directly:

```bash
firebase deploy --only firestore:rules --project lizard-fitness
firebase deploy --only storage --project lizard-fitness
```

## 6. Seed Data

```bash
# Get a service account key from Firebase Console → Project settings → Service accounts
export GOOGLE_APPLICATION_CREDENTIALS="/path/to/serviceAccount.json"
export FIREBASE_PROJECT_ID="lizard-fitness"

npm install firebase-admin
node seed_data.js
```

This seeds:
- 16 exercises (Bench Press, Squat, Deadlift, etc.)
- 8 workout templates (Beginner Full Body, PPL, Upper/Lower, Strength 5x5, HIIT)
- 4 gym challenges

## 7. Run the App

```bash
flutter run
```

## Firestore Indexes

If you get index errors in console, create composite indexes for:
- `workoutSessions`: `userId` ASC + `startedAt` DESC
- `customWorkouts`: `userId` ASC + `createdAt` DESC
- `personalRecords`: `userId` ASC + `achievedAt` DESC
- `progressPhotos`: `userId` ASC + `takenAt` DESC
- `milestones`: `userId` ASC + `achievedAt` DESC

Firebase will show you the direct link to create each index when the query fails.
