# Analytics & crash reporting — setup guide (E4-6)

## Good news: this one is FREE
Firebase **Analytics** and **Crashlytics** are both free on the **Spark** plan.
Unlike push/payments/calling, there's no paid tier or server needed — just two
packages, a little native config, and some `logEvent` calls. It wasn't wired yet
only to avoid a blind native change to a working build.

## Packages
```yaml
dependencies:
  firebase_analytics: ^10.8.0
  firebase_crashlytics: ^3.4.9
```
Then `flutter pub get`.

## Native config (one-time)
- **Android**: the Firebase Gradle plugins are already applied (you use
  firebase_core/auth). Crashlytics needs its Gradle plugin:
  - In `android/build.gradle` (or `settings.gradle` plugins block) add
    `com.google.firebase.crashlytics` version `2.9.9`.
  - In `android/app/build.gradle` apply `com.google.firebase.crashlytics`.
- **iOS**: no manual steps for Analytics; Crashlytics needs a dSYM upload build
  phase (not relevant while you're on the Android emulator).

## Wire it up in `main.dart`
```dart
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(/* options */);

  // Route Flutter framework errors to Crashlytics.
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  runApp(const MyApp());
}
```

## Analytics observer (screen tracking)
```dart
final analytics = FirebaseAnalytics.instance;

MaterialApp(
  navigatorObservers: [FirebaseAnalyticsObserver(analytics: analytics)],
  ...
)
```

## Events worth logging (map to this app)
```dart
final a = FirebaseAnalytics.instance;

// Adoption
a.logEvent(name: 'view_animal', parameters: {'species': animal.species});
a.logEvent(name: 'adoption_request_sent', parameters: {'animal': animal.name});
a.logEvent(name: 'listing_posted', parameters: {'species': species});

// Shop
a.logEvent(name: 'add_to_cart', parameters: {'item': p.name, 'price': p.price});
a.logEvent(name: 'purchase', parameters: {'value': total, 'currency': 'EGP'});

// Vet
a.logEvent(name: 'appointment_booked', parameters: {'vet': vet.name});
a.logEvent(name: 'vet_call_started');
```
Put a thin `AnalyticsService` wrapper around these so screens call
`AnalyticsService.purchase(total)` instead of the raw SDK.

## Verify
- Analytics **DebugView**: `adb shell setprop debug.firebase.analytics.app com.example.adopt_animal`,
  then watch Firebase Console → Analytics → DebugView.
- Crashlytics: call `FirebaseCrashlytics.instance.crash()` once in debug, relaunch,
  and the crash appears in the Crashlytics dashboard within minutes.

## Status
Buildable on the free plan. Left as **In progress** because it needs the two
packages added + the Crashlytics Gradle plugin — a small but native change best
done when you can run a full `flutter pub get` + rebuild and confirm the build.
