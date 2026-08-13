# Seeding test data in the Firebase Console

The app reads these collections live from Firestore. Add documents in
**Firestore → Data**, and they appear in the app on the next refresh.

## How to add a document
1. Firestore → **Data** tab → **Start collection** (first time) or **+ Add document**.
2. Type the **Collection ID** (e.g. `animals`).
3. **Document ID** → click **Auto-ID**.
4. Add each field below: type the **Field** name, pick the **Type**, enter the **Value**, **Save**.

> Tip: for `number` fields pick type **number** (not string), and for `inStock` pick **boolean**.

---

## `animals`  → shows in the Adopt grid & detail
Set **status = `available`** or it won't appear. Set **ownerId = your UID** so it also
shows under Profile → My listings. (Find your UID in **Authentication → Users**.)

| Field | Type | Example |
|-------|------|---------|
| name | string | Bella |
| species | string | dog  *(dog / cat / bird)* |
| breed | string | Beagle |
| age | string | 2 yr |
| gender | string | Female |
| size | string | Medium  *(Small / Medium / Large)* |
| weight | string | 12 kg |
| city | string | Cairo |
| area | string | Maadi, Cairo |
| description | string | Friendly and house-trained. |
| health | string | Vaccinated · Spayed |
| ownerName | string | You |
| ownerId | string | *(your UID)* |
| status | string | available |
| photoLabel | string | dog photo |

Add 3–4 with different `species`/`size` so the category chips + filter have variety.

---

## `products`  → shows in the Shop
| Field | Type | Example |
|-------|------|---------|
| name | string | Premium Dry Food 5kg |
| category | string | Food  *(Food / Toys / Accessories / Health)* |
| description | string | Grain-free recipe with real chicken. |
| price | number | 450 |
| rating | number | 4.8 |
| reviews | number | 214 |
| inStock | boolean | true |
| photoLabel | string | kibble bag |

---

## `vets`  → shows in the Vets tab
| Field | Type | Example |
|-------|------|---------|
| name | string | Dr. Ahmed Hassan |
| specialty | string | Canine specialist |
| clinic | string | Golden Paws Clinic |
| city | string | Maadi, Cairo |
| initials | string | DA |
| category | string | Canine  *(Canine / Feline / Exotic)* |
| rating | number | 4.9 |
| availability | string | Available today |
| about | string | Surgery and preventive care for dogs. |
| experience | string | 12 yr experience |
| patients | string | 320+ |
| price | number | 250 |
| address | string | 5 Road 218, Maadi |
| hours | string | Sat-Thu · 10:00 AM - 8:00 PM |
| phone | string | +201001112233 |

---

## User-scoped collections (easier to create *from the app*)
These need your UID and are simplest to generate by using the app while signed in:

- **`adoption_requests`** — open an animal → *Request adoption* → Send.
- **`orders`** — add to cart → Checkout → Place order.
- **`appointments`** — open a vet → Book → Confirm.
- **`chats/{id}/messages`** — open a vet → Chat → send a message.
- **`users/{uid}/favorites`** — tap the heart on any animal.

If you'd rather add these by hand, the key field is the owner id:
`orders.userId`, `appointments.userId`, `adoption_requests.adopterId` / `ownerId`,
`animals.ownerId` — all must equal your Auth UID for them to show for you.
