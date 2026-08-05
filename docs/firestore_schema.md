# Firestore data model — adopt_animal

This is the backend schema the UI screens are being wired to. Collections, key
fields, and the read/write rules that guard them (see `firestore.rules`).

## users/{uid}
The signed-in user's profile (created on sign-up).

| field | type | notes |
|---|---|---|
| uid | string | == auth uid |
| name | string | |
| email | string | |
| role | string | `adopter` \| `vet` \| `admin` (default `adopter`) |
| phone | string | |
| city | string | |
| bio | string | |
| profileUrl | string | avatar (Firebase Storage URL) |
| status | string | short status line |

Sub-collections: `favorites/{animalId}` (saved animals), `cart/{itemId}`.

## animals/{animalId}
An adoption listing.

| field | type | notes |
|---|---|---|
| ownerId | string | uid of the person listing it (guards writes) |
| name, species, breed, gender, size | string | |
| ageMonths | number | render as "2 yr" / "8 mo" |
| weight | string | |
| city, area | string | |
| description | string | |
| health | string | "Vaccinated · Spayed …" |
| photoUrls | array<string> | Storage URLs |
| status | string | `available` \| `adopted` |
| createdAt | timestamp | for ordering the feed |

Feed query: `where status == 'available' orderBy createdAt desc`.

## adoption_requests/{reqId}
| field | type | notes |
|---|---|---|
| animalId | string | |
| adopterId | string | who is requesting |
| ownerId | string | animal's owner (can accept/decline) |
| message | string | |
| homeInfo | map | outdoor space, owned-before, other-pets |
| status | string | `pending` \| `accepted` \| `declined` |
| createdAt | timestamp | |

## products/{productId}  (admin-managed)
| field | type | notes |
|---|---|---|
| name, category, description | string | category: Food/Toys/Accessories/Health |
| price | number | EGP |
| rating | number | |
| reviews | number | |
| inStock | bool | |
| photoUrls | array<string> | |

## orders/{orderId}
| field | type | notes |
|---|---|---|
| userId | string | owner of the order |
| items | array<map> | { productId, name, price, qty } |
| subtotal, deliveryFee, total | number | |
| address | map | |
| paymentMethod | string | `cod` (card later) |
| status | string | `pending` \| `confirmed` \| `shipped` \| `delivered` |
| createdAt | timestamp | |

## vets/{vetId}
`vetId` == the vet user's uid.

| field | type | notes |
|---|---|---|
| name, specialty, clinic, city | string | |
| category | string | Canine/Feline/Exotic |
| rating | number | |
| price | number | EGP per visit |
| about, address, hours | string | |
| availability | map | open slots per day |

## appointments/{apptId}
| field | type | notes |
|---|---|---|
| userId | string | pet owner |
| vetId | string | |
| animalId | string? | optional |
| datetime | timestamp | |
| reason | string | |
| status | string | `requested` \| `confirmed` \| `cancelled` \| `completed` |

## chats/{chatId} + messages/{messageId}
- `chats/{chatId}`: `{ participants: [uidA, uidB], lastMessage, updatedAt }`
- `messages/{messageId}`: `{ senderId, text, imageUrl?, createdAt, read }`

## Suggested composite indexes
- `animals`: status ASC, createdAt DESC
- `adoption_requests`: ownerId ASC, createdAt DESC
- `orders`: userId ASC, createdAt DESC
- `appointments`: userId ASC, datetime ASC
- `messages`: (collection-group) createdAt ASC

Create these in Console when a query first prompts for them, or add to
`firestore.indexes.json`.
