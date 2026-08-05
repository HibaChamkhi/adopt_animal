# Adopt Animal — Product Backlog

_Last updated: 2026-07-20_

This backlog turns three requested feature areas into an actionable plan that fits the app's existing **clean architecture** (`data / domain / presentation`), **BLoC/Cubit** state management, **GetIt** DI (`lib/injection.dart`), and **Firebase** backend (Auth + Firestore + Storage).

New features follow the same folder pattern already used by `features/auth` and `features/profile`:

```
lib/features/<feature>/
  data/{dataSources,models,repository}/
  domain/{entities,repository,useCases}/
  presentation/{cubit,pages}/
```

---

## Current state (baseline)

What already exists and can be reused:

- **Auth** — email/password + Google sign-in, sign-out, Firestore `users` collection, `AuthCubit`.
- **Profile / Settings** — gradient header, menu rows (Settings, Password, Contact Us, Logout), `ProfileCubit`.
- **Navigation shell** — `BottomNavBarPage` with 4 tabs: Home, Cart (placeholder "Coming soon"), Chat (placeholder "Coming soon"), Settings.
- **Home** — static welcome text only.

Gaps this backlog fills: the core adoption experience, the shop (maps to the Cart tab), and the vet/doctor feature (maps to the Chat tab).

---

## Epics at a glance

| # | Epic | Maps to | Priority |
|---|------|---------|----------|
| E0 | Foundations & shared infrastructure | cross-cutting | Must (do first) |
| E1 | Animal adoption (browse + list your own) | Home tab / new "Adopt" section | Must — core purpose |
| E2 | Shop for food & supplies | Cart tab | Should |
| E3 | Vet / doctor: chat, call, appointments | Chat tab | Should |
| E4 | Cross-cutting: notifications, search, payments, polish | all | Could / phased |

---

## E0 — Foundations & shared infrastructure

These unblock everything else. Do them before E1–E3.

**E0-1 — User roles & extended profile**
_As a user, I want the app to know whether I'm an adopter, a pet owner, or a vet, so it can show me the right features._
- Acceptance: `users` doc has a `role` field (`adopter` | `vet` | `admin`) and profile fields (phone, city, bio); role defaults to `adopter` on sign-up.
- Tasks: extend `UserEntity` / `UserModel` with `role`, `phone`, `city`; migrate `getCreateCurrentUser`; add role selector to sign-up; guard vet-only screens.

**E0-2 — Firestore data model & security rules**
_As the team, we want a documented schema and locked-down rules so data is consistent and safe._
- Acceptance: collections defined for `animals`, `products`, `orders`, `vets`, `appointments`, `chats/{id}/messages`, `favorites`; Firestore security rules deployed; composite indexes created for list queries.
- Tasks: write `firestore.rules`; document schema in `/docs`; add indexes for filtered/sorted queries.

**E0-3 — Reusable UI & error/loading states**
_As a developer, I want shared widgets so screens look consistent and handle empty/error/loading._
- Acceptance: shared `AppScaffold`, list skeletons, empty-state and error-retry widgets; central theme colors extended (`app_theme.dart`).
- Tasks: build widgets in `lib/core/`; replace ad-hoc `CircularProgressIndicator` usage.

**E0-4 — Image upload service**
_As a user, I want to attach photos (of animals, of chat), stored in Firebase Storage._
- Acceptance: a `StorageService` wrapping `image_picker` + `firebase_storage` returns a download URL; handles compression, progress, and failure.
- Tasks: add `core/services/storage_service.dart`; register in `injection.dart`.

**E0-5 — Fix hardcoded Home greeting**
_As a logged-in user, I want the Home screen to greet me by my real name, not the hardcoded "Hiba"._
- Acceptance: Home reads the current user's `name` from Firestore via a use case.
- Tasks: add `GetCurrentUserUseCase`; wire into `home_page.dart`.

---

## E1 — Animal adoption (core)

The reason the app exists: browse animals to adopt, and list your own animal for adoption.

**E1-1 — Browse adoptable animals**
_As an adopter, I want to browse a feed of animals available for adoption so I can find one to bring home._
- Acceptance: grid/list of animal cards (photo, name, species, breed, age, city, status=available); pull-to-refresh; pagination/infinite scroll; empty state.
- Tasks: `AnimalEntity`/`AnimalModel`; `AnimalRemoteDataSource` streaming `animals` where `status == available`; `GetAnimalsUseCase`; `AnimalListCubit`; `AdoptHomePage` (replaces static Home or becomes the Home tab).

**E1-2 — Filter & search animals**
_As an adopter, I want to filter by species, breed, age, size, and city so I see relevant matches._
- Acceptance: filter chips + search field; results update; "no results" state.
- Tasks: query params in data source; filter bar widget; index in Firestore (E0-2).

**E1-3 — Animal detail screen**
_As an adopter, I want a detailed page with photos and full info so I can decide._
- Acceptance: image carousel, description, health/vaccination notes, owner/shelter info, "Request adoption" CTA, favorite toggle.
- Tasks: `AnimalDetailPage`; `GetAnimalByIdUseCase`.

**E1-4 — Request to adopt**
_As an adopter, I want to send an adoption request to the animal's owner so we can proceed._
- Acceptance: request creates a doc in `adoption_requests` (animalId, adopterId, ownerId, status=pending, message); owner is notified (E4-1); duplicate requests prevented.
- Tasks: `AdoptionRequestEntity/Model`; `CreateAdoptionRequestUseCase`; request sheet UI.

**E1-5 — List my animal for adoption**
_As a pet owner, I want to post an animal I can no longer keep so others can adopt it._
- Acceptance: multi-step form (photos, species, breed, age, gender, description, location) writes to `animals` with `ownerId = me`, `status = available`; photos via E0-4.
- Tasks: `CreateAnimalUseCase`; `AddAnimalPage`; validation.

**E1-6 — Manage my listings & requests**
_As a pet owner, I want to see my posted animals and incoming adoption requests so I can accept/decline._
- Acceptance: "My Listings" tab shows my animals + request counts; accept sets `status = adopted` and notifies adopter; decline updates request; edit/delete listing.
- Tasks: `MyListingsPage`, `RequestsInboxPage`; `UpdateAdoptionRequestUseCase`; `UpdateAnimalUseCase`.

**E1-7 — Favorites / saved animals**
_As an adopter, I want to save animals I like so I can revisit them._
- Acceptance: heart toggle persists to `users/{uid}/favorites`; "Saved" screen lists them.
- Tasks: `ToggleFavoriteUseCase`, `GetFavoritesUseCase`, `FavoritesCubit`.

---

## E2 — Shop for food & supplies

Maps to the existing **Cart tab** placeholder. Sells pet food and everything animals need.

**E2-1 — Product catalog**
_As a shopper, I want to browse products (food, toys, accessories, health) by category so I can find supplies._
- Acceptance: category tabs/grid; product cards (image, name, price, rating); search; pagination.
- Tasks: `ProductEntity/Model`; `ProductRemoteDataSource` over `products`; `GetProductsUseCase`; `ShopHomePage`; `ProductListCubit`.

**E2-2 — Product detail**
_As a shopper, I want full product info so I can decide to buy._
- Acceptance: images, description, price, stock, quantity selector, "Add to cart".
- Tasks: `ProductDetailPage`; `GetProductByIdUseCase`.

**E2-3 — Cart**
_As a shopper, I want a cart so I can collect items and adjust quantities before checkout._
- Acceptance: add/remove/update quantity; live subtotal; persists per user (`users/{uid}/cart` or local); badge on Cart tab.
- Tasks: `CartCubit`; `CartRepository`; `CartPage`.

**E2-4 — Checkout & orders**
_As a shopper, I want to place an order with a delivery address so my supplies arrive._
- Acceptance: address form, order summary, place-order writes to `orders` (items, total, address, status=pending); cart clears; confirmation screen.
- Tasks: `OrderEntity/Model`; `PlaceOrderUseCase`; `CheckoutPage`.

**E2-5 — Order history & tracking**
_As a shopper, I want to see my past and current orders with status so I can track them._
- Acceptance: "My Orders" list with status (pending → shipped → delivered); order detail.
- Tasks: `GetMyOrdersUseCase`; `OrdersPage`, `OrderDetailPage`.

**E2-6 — Payment integration (see E4-3)**
Depends on the payments spike. MVP can ship cash-on-delivery only.

---

## E3 — Vet / doctor: chat, call, appointments

Maps to the existing **Chat tab** placeholder. Lets users reach vets by text, call, or booked appointment. (The project already declares the `bubble` chat-bubble package and `singleChatPage` page constants — partial groundwork exists.)

**E3-1 — Vet directory**
_As a pet owner, I want to browse available vets with specialties and ratings so I can pick one._
- Acceptance: list of vets (photo, name, specialty, clinic, city, rating, availability); search/filter by specialty & city.
- Tasks: `VetEntity/Model`; `vets` collection (seeded from users with `role = vet`); `GetVetsUseCase`; `VetListPage`.

**E3-2 — Vet profile**
_As a pet owner, I want a vet's detail page so I can see info and choose an action (chat / call / book)._
- Acceptance: bio, specialties, clinic address, hours, three CTAs (Chat, Call, Book appointment).
- Tasks: `VetDetailPage`.

**E3-3 — 1:1 chat with vet**
_As a pet owner, I want to text a vet so I can ask about my animal._
- Acceptance: real-time messaging via `chats/{chatId}/messages` (Firestore streams); text + image (E0-4); read receipts; uses `bubble` package; chat list of conversations.
- Tasks: `MessageEntity/Model`; `ChatRemoteDataSource` (streams); `SendMessageUseCase`, `GetMessagesUseCase`; `ChatCubit`; `SingleChatPage` (wire up existing `singleChatPage` route), `ChatListPage`.

**E3-4 — Voice/video call with vet**
_As a pet owner, I want to call a vet so I can talk directly._
- Acceptance: call button initiates a call. Phase 1 = launch device dialer via `url_launcher` (tel:) for clinics that share a number. Phase 2 = in-app calling (see spike E4-4).
- Tasks: add `url_launcher`; Phase-1 call action; spike for WebRTC/Agora/Twilio in Phase 2.

**E3-5 — Book an appointment**
_As a pet owner, I want to book an appointment slot with a vet so I get dedicated time._
- Acceptance: vet exposes availability; user picks date/time from open slots; booking writes to `appointments` (vetId, userId, animalId?, datetime, reason, status=requested); double-booking prevented; both parties notified (E4-1).
- Tasks: `AppointmentEntity/Model`; `CreateAppointmentUseCase`, `GetAvailabilityUseCase`; `BookAppointmentPage`; slot-picker widget.

**E3-6 — Manage appointments**
_As a pet owner or vet, I want to see, confirm, reschedule, or cancel appointments so schedules stay accurate._
- Acceptance: "My Appointments" list for users; a vet dashboard to confirm/decline/complete; status transitions; cancellation frees the slot.
- Tasks: `UpdateAppointmentUseCase`; `AppointmentsPage`, `VetDashboardPage` (role-gated via E0-1).

---

## E4 — Cross-cutting (phased)

**E4-1 — Push notifications** _(Should)_ — FCM for adoption requests, order status, new chat messages, appointment reminders. Tasks: add `firebase_messaging`; token storage; Cloud Function triggers.

**E4-2 — Global search & discovery** _(Could)_ — unified search across animals, products, vets.

**E4-3 — Payments spike + integration** _(Should, gated)_ — evaluate Stripe vs local gateways for the shop and paid appointments; MVP ships cash-on-delivery. Deliverable: decision doc + integration story.

**E4-4 — In-app calling spike** _(Could)_ — evaluate Agora / Twilio / WebRTC for E3-4 Phase 2. Deliverable: decision doc.

**E4-5 — Admin/moderation** _(Could)_ — report listings, approve vets, remove content.

**E4-6 — Analytics & crash reporting** _(Could)_ — Firebase Analytics + Crashlytics.

**E4-7 — Tests** _(Should, ongoing)_ — unit tests for use cases/cubits; widget tests for key screens; the `test/` folder is currently empty.

---

## Suggested delivery phases

**Phase 1 — MVP (core loop):** E0-1, E0-2, E0-3, E0-4, E0-5 → E1-1, E1-3, E1-4, E1-5, E1-6. _Outcome: a working adoption marketplace._

**Phase 2 — Shop:** E2-1 → E2-5 (cash-on-delivery). _Outcome: buy food & supplies._

**Phase 3 — Vet care:** E3-1, E3-2, E3-3, E3-5, E3-6 + E4-1 (notifications). _Outcome: chat + appointments with vets._

**Phase 4 — Polish & scale:** E1-2, E1-7, E2-6/E4-3 (payments), E3-4/E4-4 (calling), E4-2, E4-5, E4-6, E4-7.

---

## Notes / open questions

- **Payments:** which provider and which region? (affects E2-4/E2-6, E3-5, E4-3)
- **Calling:** is launching the device dialer enough for v1, or is in-app calling required?
- **Vet onboarding:** do vets self-register (role picker) or does an admin approve them?
- **Geography:** single city/country or multi-region? (affects filtering + delivery)
