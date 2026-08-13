# Push notifications (E4-1)

## What's done (free / Spark plan)
The app has a complete **in-app notification system**, no paid plan required:

- **Notifications screen** — a live feed derived from Firestore: incoming adoption
  requests, appointment status, and orders. No fake data. (`notifications_page.dart`)
- **Home bell badge** — shows a real unread count = pending adoption requests +
  unconfirmed appointments, updated live. (`home_screen.dart`)

This is the part that works on the free plan and needs no server.

## What's left: true OS push (needs the Blaze plan)
Delivering a system push notification (banner on the phone when the app is closed)
needs two things the free plan can't give you automatically:

1. **A sender.** A push has to be *sent* from a trusted server. Options:
   - **Firebase Console → Cloud Messaging → “Send test message”** — free, manual,
     good for testing to a single device token.
   - **A Cloud Function** that fires on Firestore writes (e.g. when an
     `adoption_requests` doc is created, push to the owner). Cloud Functions
     require the **Blaze (pay-as-you-go)** plan. FCM itself is free; the Function
     runtime is what needs Blaze.

2. **The client SDK** (`firebase_messaging`) to receive the push and register a
   device token.

### Client steps (when you upgrade)
1. Add the package:
   ```yaml
   dependencies:
     firebase_messaging: ^14.9.4
   ```
   then `flutter pub get`. On Android no manual native code is needed —
   `google-services.json` is already configured.

2. Register the token after login (save it on the user doc so a server can target it):
   ```dart
   import 'package:firebase_messaging/firebase_messaging.dart';
   import 'package:cloud_firestore/cloud_firestore.dart';
   import 'package:firebase_auth/firebase_auth.dart';

   Future<void> registerPushToken() async {
     final messaging = FirebaseMessaging.instance;
     await messaging.requestPermission();
     final token = await messaging.getToken();
     final uid = FirebaseAuth.instance.currentUser?.uid;
     if (token != null && uid != null) {
       await FirebaseFirestore.instance
           .collection('users').doc(uid)
           .set({'fcmToken': token}, SetOptions(merge: true));
     }
     messaging.onTokenRefresh.listen((t) {
       final u = FirebaseAuth.instance.currentUser?.uid;
       if (u != null) {
         FirebaseFirestore.instance
             .collection('users').doc(u)
             .set({'fcmToken': t}, SetOptions(merge: true));
       }
     });
   }
   ```
   Call `registerPushToken()` from `AuthCubit` right after a successful sign-in.

3. Handle foreground messages:
   ```dart
   FirebaseMessaging.onMessage.listen((msg) {
     // update in-app state / show a local notification
   });
   ```
   (System notifications while the app is in the background/terminated are shown
   automatically by the OS from the FCM payload.)

4. Add a `users/{uid}` rule note: the doc already allows the owner to write their
   own fields, so `fcmToken` needs no rule change.

### Server step (Blaze)
A Cloud Function to fan out a push when a request arrives:
```js
exports.onAdoptionRequest = functions.firestore
  .document('adoption_requests/{id}')
  .onCreate(async (snap) => {
    const r = snap.data();
    const owner = await admin.firestore().doc(`users/${r.ownerId}`).get();
    const token = owner.get('fcmToken');
    if (token) {
      await admin.messaging().send({
        token,
        notification: {
          title: 'New adoption request',
          body: `${r.adopterName} wants to adopt ${r.animalName}`,
        },
      });
    }
  });
```

## Summary
- In-app notifications + unread badge: **shipped, free.**
- OS push: **blocked on the Blaze plan** (same decision as Firebase Storage).
  The client code above + a Cloud Function turn it on with no further app rework.
