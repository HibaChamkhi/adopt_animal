/// Temporary in-memory sample data so the UI renders exactly like the mockups.
/// Swap for Firestore-backed cubits when wiring the data layer (backlog E1-1+).
class Animal {
  final String name;
  final String species; // dog / cat / bird
  final String breed;
  final String age;
  final String city;
  final String photoLabel;
  final String gender;
  final String size;
  final String weight;
  final String area;
  final String distance;
  final String description;
  final String health;
  final String ownerName;
  final String ownerSince;
  final String status;
  final String id;
  final String ownerId;
  final String photoUrl;
  bool favorite;

  Animal({
    required this.name,
    required this.species,
    required this.breed,
    required this.age,
    required this.city,
    required this.photoLabel,
    this.gender = "Female",
    this.size = "Medium",
    this.weight = "-",
    this.area = "",
    this.distance = "",
    this.description = "",
    this.health = "Vaccinated",
    this.ownerName = "Owner",
    this.ownerSince = "2024",
    this.status = "Available",
    this.id = "",
    this.ownerId = "",
    this.photoUrl = "",
    this.favorite = false,
  });
}

final List<Animal> sampleAnimals = [
  Animal(
    name: "Luna", species: "dog", breed: "Golden Retriever", age: "2 yr",
    city: "Cairo", photoLabel: "dog photo", gender: "Female", size: "Large",
    weight: "28 kg", area: "Maadi, Cairo", distance: "2.4 km away",
    description:
        "Luna is a gentle, house-trained retriever who loves kids and long walks. Her family is relocating abroad and can't take her along.",
    health: "Vaccinated · Spayed · Microchipped",
    ownerName: "Omar K.", ownerSince: "2024", favorite: true,
  ),
  Animal(
    name: "Milo", species: "cat", breed: "Tabby", age: "8 mo",
    city: "Giza", photoLabel: "cat photo", gender: "Male", size: "Small",
    weight: "3.5 kg", area: "Dokki, Giza", distance: "5.1 km away",
    description:
        "Milo is a playful, litter-trained tabby who gets along well with other cats and loves a sunny window.",
    health: "Vaccinated · Dewormed",
    ownerName: "Sara M.", ownerSince: "2023",
  ),
  Animal(
    name: "Rex", species: "dog", breed: "German Shepherd", age: "4 yr",
    city: "Cairo", photoLabel: "dog photo", gender: "Male", size: "Large",
    weight: "32 kg", area: "Nasr City, Cairo", distance: "8.0 km away",
    description:
        "Rex is a loyal, well-trained shepherd looking for an active family with space to run.",
    health: "Vaccinated · Neutered · Microchipped",
    ownerName: "Karim S.", ownerSince: "2022",
  ),
  Animal(
    name: "Kiwi", species: "bird", breed: "Cockatiel", age: "1 yr",
    city: "Alexandria", photoLabel: "bird photo", gender: "Female", size: "Small",
    weight: "90 g", area: "Smouha, Alexandria", distance: "",
    description:
        "Kiwi is a cheerful cockatiel who loves to whistle and perch on a friendly shoulder.",
    health: "Healthy · Vet-checked",
    ownerName: "Nour A.", ownerSince: "2024",
  ),
];


class Product {
  final String name;
  final String category; // Food / Toys / Accessories / Health
  final String photoLabel;
  final String description;
  final int price; // EGP
  final double rating;
  final int reviews;
  final bool inStock;

  Product({
    required this.name,
    required this.category,
    required this.photoLabel,
    required this.description,
    required this.price,
    required this.rating,
    required this.reviews,
    this.inStock = true,
  });
}

final List<Product> sampleProducts = [
  Product(name: "Premium Dry Food 5kg", category: "Food", photoLabel: "kibble bag", price: 450, rating: 4.8, reviews: 214,
      description: "Grain-free recipe with real chicken as the first ingredient. Suited for adult dogs of all breeds; supports coat and joint health."),
  Product(name: "Salmon Cat Pouches x12", category: "Food", photoLabel: "wet food", price: 180, rating: 4.6, reviews: 98,
      description: "Tender salmon in gravy, complete and balanced for adult cats. Twelve single-serve pouches."),
  Product(name: "Puppy Starter Mix 2kg", category: "Food", photoLabel: "puppy food", price: 260, rating: 4.9, reviews: 156,
      description: "Soft, easy-to-chew kibble formulated for weaning puppies up to 12 months."),
  Product(name: "Tropical Seed Blend 1kg", category: "Food", photoLabel: "bird seed", price: 95, rating: 4.5, reviews: 41,
      description: "A vitamin-enriched seed mix for cockatiels, budgies and small parrots."),
  Product(name: "Rope Tug Toy", category: "Toys", photoLabel: "rope toy", price: 75, rating: 4.7, reviews: 63,
      description: "Durable cotton rope for tug-of-war and dental play. Machine washable."),
  Product(name: "Feather Teaser Wand", category: "Toys", photoLabel: "cat toy", price: 55, rating: 4.4, reviews: 29,
      description: "Interactive feather wand that keeps cats active and entertained."),
  Product(name: "Adjustable Collar", category: "Accessories", photoLabel: "collar", price: 120, rating: 4.6, reviews: 88,
      description: "Soft padded nylon collar with a secure quick-release buckle."),
  Product(name: "Ceramic Food Bowl", category: "Accessories", photoLabel: "bowl", price: 140, rating: 4.8, reviews: 52,
      description: "Non-slip ceramic bowl, dishwasher-safe and easy to clean."),
  Product(name: "Golden Coat Shampoo", category: "Health", photoLabel: "shampoo", price: 120, rating: 4.5, reviews: 37,
      description: "Gentle oatmeal shampoo that soothes skin and leaves a shiny coat."),
  Product(name: "Flea & Tick Drops", category: "Health", photoLabel: "health", price: 210, rating: 4.7, reviews: 74,
      description: "Monthly spot-on treatment protecting against fleas, ticks and lice."),
];


class Vet {
  final String name;
  final String specialty;
  final String clinic;
  final String city;
  final String initials;
  final String category; // Canine / Feline / Exotic
  final double rating;
  final String availability;
  final String about;
  final String experience;
  final String patients;
  final int price; // EGP per visit
  final String address;
  final String hours;
  final String phone;

  Vet({
    required this.name,
    required this.specialty,
    required this.clinic,
    required this.city,
    required this.initials,
    required this.category,
    required this.rating,
    required this.availability,
    required this.about,
    required this.experience,
    required this.patients,
    required this.price,
    required this.address,
    required this.hours,
    this.phone = "+201001112222",
  });

  bool get availableToday => availability.toLowerCase().contains("today");
}

final List<Vet> sampleVets = [
  Vet(
    name: "Dr. Ahmed Hassan", specialty: "Canine specialist", clinic: "Golden Paws Clinic",
    city: "Maadi, Cairo", initials: "DA", category: "Canine", rating: 4.9,
    availability: "Available today",
    about: "Surgery and preventive care for dogs of all breeds. Graduate of Cairo University Vet Med; leads the canine unit at Golden Paws Clinic.",
    experience: "12 yr experience", patients: "320+", price: 250,
    address: "Golden Paws Clinic, 5 Road 218, Maadi", hours: "Sat-Thu · 10:00 AM - 8:00 PM", phone: "+201001112233",
  ),
  Vet(
    name: "Dr. Mona Nabil", specialty: "Feline specialist", clinic: "Whiskers Vet Center",
    city: "Zamalek, Cairo", initials: "MN", category: "Feline", rating: 4.7,
    availability: "Next: tomorrow",
    about: "Feline internal medicine and dentistry. Passionate about stress-free handling and preventive wellness plans for cats.",
    experience: "9 yr experience", patients: "210+", price: 220,
    address: "Whiskers Vet Center, 14 Brazil St, Zamalek", hours: "Sun-Fri · 11:00 AM - 7:00 PM", phone: "+201002223344",
  ),
  Vet(
    name: "Dr. Karim Said", specialty: "Exotic & avian", clinic: "BirdLife Clinic",
    city: "Giza", initials: "KS", category: "Exotic", rating: 4.8,
    availability: "Available today",
    about: "Care for birds, reptiles and small mammals. One of the few certified avian vets in Greater Cairo.",
    experience: "8 yr experience", patients: "140+", price: 200,
    address: "BirdLife Clinic, 3 Nile St, Giza", hours: "Sat-Wed · 10:00 AM - 6:00 PM", phone: "+201003334455",
  ),
];


/// Build an Animal from a Firestore document map.
Animal animalFromMap(String id, Map<String, dynamic> m) {
  return Animal(
    name: (m['name'] ?? '') as String,
    species: (m['species'] ?? 'dog') as String,
    breed: (m['breed'] ?? '') as String,
    age: (m['age'] ?? '') as String,
    city: (m['city'] ?? '') as String,
    photoLabel: (m['photoLabel'] ?? 'photo') as String,
    gender: (m['gender'] ?? 'Female') as String,
    size: (m['size'] ?? 'Medium') as String,
    weight: (m['weight'] ?? '-') as String,
    area: (m['area'] ?? '') as String,
    description: (m['description'] ?? '') as String,
    health: (m['health'] ?? 'Vaccinated') as String,
    ownerName: (m['ownerName'] ?? 'Owner') as String,
    status: (m['status'] ?? 'available') as String,
    id: id,
    ownerId: (m['ownerId'] ?? '') as String,
    photoUrl: () {
      final urls = m['photoUrls'];
      if (urls is List && urls.isNotEmpty) return urls.first as String;
      return (m['photoUrl'] ?? '') as String;
    }(),
  );
}
