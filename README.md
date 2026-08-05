# Adopt Animal 🐾

**Adopt Animal** is a Flutter mobile app that brings the entire pet-care journey into one
place. Adopt a pet or list one for adoption, shop for food and supplies, and consult or book
a veterinarian — all backed by Firebase and built on a clean, scalable architecture.

---

## ✨ Features

| Area | What you can do |
|------|-----------------|
| **Authentication** | Sign up / sign in with email & password or Google, with a role (adopter or vet) chosen at registration. Robust auth error handling. |
| **Adoption** | Browse a live feed of adoptable animals, filter by species / age / size / city, search, and open detailed profiles. Send an adoption request, or — as an owner — post your own pet with photos, manage your listings, and accept/decline incoming requests. |
| **Favorites** | Save animals you love; hearts sync to your account and persist across sessions. |
| **Shop** | Browse pet supplies by category (food, toys, accessories, health), view product details, build a live cart, and check out (cash on delivery) with order history and a delivery tracker. |
| **Vet care** | Explore a vet directory with specialties & ratings, view vet profiles, chat 1-on-1, call, and book / manage appointments. |
| **Profile & system** | A profile hub with stats, editable personal info, settings, notification preferences, a notifications feed, and global search across animals, products and vets. |

---

## 🏗️ Architecture

The app follows **Clean Architecture** with a **feature-first** folder structure. Each feature is
split into three layers:

```
data/         → data sources + repositories (Firebase)
domain/       → entities + use cases
presentation/ → cubits + pages (UI)
```

**Tech stack**

- **Flutter / Dart** — cross-platform UI
- **BLoC / Cubit** (`flutter_bloc`) — state management
- **GetIt** — dependency injection (`lib/injection.dart`)
- **Firebase** — Auth, Cloud Firestore, Storage
- **image_picker**, **flutter_svg**, **url_launcher**, **animated_notch_bottom_bar**

**UI system** — a single shared design system drives every screen: design tokens
(`lib/core/app_theme.dart` → `AppColors`, `AppText`), a reusable widget kit
(`lib/core/widgets/`), and an SVG icon set (`assets/icons/`), all tied together by a
5-tab bottom-navigation shell: **Home · Adopt · Shop · Vets · Profile**.

### Project structure

```
lib/
├── core/                    # theme, shared widgets, icons, services, sample data
│   ├── app_theme.dart       # AppColors + AppText design tokens
│   ├── widgets/             # reusable UI kit (cards, chips, buttons, rows…)
│   ├── cart_service.dart    # in-memory cart
│   ├── favorites_service.dart
│   └── storage_service.dart # Firebase Storage uploads
├── features/
│   ├── auth/                # sign-in / sign-up / roles
│   ├── adoption/            # browse, detail, request, list, my-listings, saved
│   ├── shop/                # catalog, product, cart, checkout, orders
│   ├── vet/                 # directory, profile, chat, booking, appointments
│   ├── profile/             # profile hub, settings, notifications, personal info
│   ├── notifications/       # notifications feed
│   ├── search/              # global search
│   └── main_shell.dart      # 5-tab navigation shell
└── main.dart
```

### Firestore collections

`users` · `animals` · `adoption_requests` · `products` · `orders` · `vets` · `appointments` · `chats`

See **`docs/firestore_schema.md`** for the full data model and **`firestore.rules`** for the
per-collection security rules.

---

## 🚀 Getting started

```bash
flutter pub get
flutter run
```

### Firebase setup (required for data to persist)

1. **Firestore rules** — Firebase Console → Firestore → **Rules** → paste `firestore.rules` →
   **Publish** (or `firebase deploy --only firestore:rules`).
2. **Storage** — Firebase Console → Build → **Storage** → Get started, then publish rules that
   allow authenticated users to write under `animals/{uid}/…` (needed for listing photos).
3. Enable **Email/Password** sign-in under Authentication → Sign-in method.

> Firestore's SDK reports a *local* success immediately, so a write can appear to succeed even
> while the server rejects it. If new listings don't persist, deploy the rules above first.

---

## 🗺️ Roadmap

Built and working in code; these need external configuration to go live:

- **Push notifications (FCM)** — the in-app notifications feed exists; real delivery needs Cloud Functions + push config.
- **Card payments** — currently cash-on-delivery; card needs a payment provider (e.g. Stripe) + API keys.
- **In-app voice/video calling** — the *Call* action opens the device dialer as a stand-in; real calling needs Agora/Twilio.
- **Analytics & automated tests.**

---

Built with Flutter & Firebase.
