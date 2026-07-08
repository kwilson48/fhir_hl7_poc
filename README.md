# Dry30 🌱

A cross-platform (iOS / Android / web) Flutter app for a **30-day alcohol-free challenge**:

- **Day counter** with a progress ring — "Day 12 of 30"
- **Science-based benefits timeline** — what's happening in your body at 12 hours, day 3, day 14, day 30 (the "your cilia are regrowing" experience, but for alcohol; sourced from the Royal Free Hospital / BMJ Open "dry month" research)
- **Daily motivation** — a different nudge for each day of the challenge
- **Daily check-in** — mood, craving intensity, and an optional note, one per day
- **Savings stats** — money saved, calories and drinks skipped, based on your typical week
- **Compassionate resets** — a slip closes the attempt into history and starts a fresh 30 days; lifetime alcohol-free days never go down
- **Local notifications** — a ping when a milestone unlocks, plus a daily check-in reminder at a time you pick
- **Craving SOS** — guided box-breathing, urge-surfing tips, and one-tap call/text to your support person
- **Shareable milestone cards** — share any unlocked milestone as an image
- **Sign in with Google, Apple, phone (SMS), or email/password**

> Dry30 shares general wellness information, not medical advice. Heavy daily drinkers should talk to a doctor before stopping abruptly — withdrawal can be dangerous.

## Architecture

| Layer | Choice | Why |
| --- | --- | --- |
| UI | Flutter (Material 3) | One codebase for iOS, Android, web |
| State | Riverpod | Simple, testable stream-based providers |
| Auth | Firebase Auth | Google / Apple / phone / email out of the box |
| Data | Cloud Firestore | Serverless NoSQL, scales horizontally, offline-first sync built in |
| Rules | `firestore.rules` | Users can only read/write their own subtree; writes are schema-validated |

There is no app server to run or scale: clients talk to Firestore directly, security rules enforce access, and everything works offline with automatic sync. If server-side logic is needed later (push reminders, streak notifications), Cloud Functions slot in without changing the data model.

### Data model

```
users/{uid}                      profile: displayName, weeklySpendUsd, drinksPerWeek, onboarded
users/{uid}/attempts/{autoId}    startDate, goalDays, endedAt?, endReason?  (one active at a time)
users/{uid}/checkins/{yyyy-MM-dd} mood (0-4), craving (0-4), note?
```

Check-in docs are keyed by local date, so writes are idempotent and "one check-in per day" is structural. Milestone/quote content ships in the app bundle (`lib/data/`), so the timeline works offline and content updates ride app releases.

### Code layout

```
lib/
  main.dart               Firebase init + ProviderScope
  app.dart                theme + auth gate (sign-in → onboarding → home)
  providers.dart          Riverpod providers wiring auth ↔ Firestore
  models/                 Milestone, SoberAttempt, CheckIn, UserProfile
  data/                   milestones.dart (benefits content), quotes.dart
  services/               auth_service.dart, firestore_service.dart
  screens/                sign-in, onboarding, dashboard, timeline, check-in, settings
  widgets/                progress ring
firestore.rules           per-user security + write validation
test/                     day math, milestone progression, savings math
```

## Getting started

### 1. Prereqs

- [Flutter](https://docs.flutter.dev/get-started/install) 3.24+ (`flutter doctor`)
- A [Firebase project](https://console.firebase.google.com/) (free Spark plan is fine to start; phone auth needs Blaze)

### 2. Wire up Firebase

`lib/firebase_options.dart` is a placeholder — generate the real one:

```bash
npm install -g firebase-tools        # or: curl -sL https://firebase.tools | bash
firebase login
dart pub global activate flutterfire_cli
flutterfire configure                # pick your project + platforms
```

Then in the [Firebase console](https://console.firebase.google.com/):

1. **Authentication → Sign-in method**: enable **Email/Password**, **Google**, **Apple**, and **Phone**.
2. **Firestore Database**: create a database (production mode), then deploy the rules:
   ```bash
   firebase deploy --only firestore:rules
   ```

### 3. Per-provider notes

- **Google (Android)**: add your debug/release SHA-1 fingerprints in Firebase project settings, re-download `google-services.json` (flutterfire places it).
- **Google (iOS)**: add the reversed client ID from `GoogleService-Info.plist` as a URL scheme in `ios/Runner/Info.plist`.
- **Apple**: enable the *Sign In with Apple* capability on the app ID in the Apple Developer portal and in Xcode (Runner → Signing & Capabilities). Apple requires this option whenever other social logins are offered on iOS.
- **Phone**: on iOS, set up an APNs key in Firebase for silent verification; reCAPTCHA fallback works out of the box. Add test numbers in Authentication → Phone for development.

### 4. Run it

```bash
flutter pub get
flutter run          # pick a connected device / simulator / chrome
flutter test         # unit tests (day math, milestones, savings)
flutter analyze
```

## Roadmap ideas

- Widgets/watch complications with the day counter
- Cloud Functions + FCM for streak-risk nudges (server-side push)
- Buddy mode: share your streak with an accountability partner
