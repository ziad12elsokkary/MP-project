class Gift {
  final String id; // Firestore document ID
  final String name;
  final String description;
  final String category;
  final double price;
  String status; // "available" or "pledged"
  final String eventId;
  String? pledgedBy; // Nullable field to track the user who pledged the gift

  Gift({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    this.status = "available", // Default to "available"
    required this.eventId,
    this.pledgedBy, // Optional parameter
  });

  // Factory constructor to create a Gift object from Firestore data
  factory Gift.fromFirestore(Map<String, dynamic> json, String id) {
    return Gift(
      id: id,
      name: json['name'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      price: (json['price'] as num).toDouble(),
      status: json['status'] as String,
      eventId: json['eventId'] as String,
      pledgedBy: json['pledgedBy'] as String?, // Map the pledgedBy field
    );
  }

  // Convert Gift object to JSON for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'category': category,
      'price': price,
      'status': status,
      'eventId': eventId,
      'pledgedBy': pledgedBy, // Include pledgedBy in the Firestore data
    };
  }
}
