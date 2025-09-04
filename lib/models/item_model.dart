import 'dart:math' show pi, sin, cos, sqrt, atan2;

class Item {
  final String id;
  final String userId;
  final String userEmail;
  final String itemName;
  final String description;
  final double price;
  final String currency;
  final String photoUrl;
  final double latitude;
  final double longitude;
  final String storeName;
  final String address;
  final DateTime submittedAt;
  final DateTime updatedAt;
  final List<String> tags;
  final String category;

  Item({
    required this.id,
    required this.userId,
    required this.userEmail,
    required this.itemName,
    required this.description,
    required this.price,
    required this.currency,
    required this.photoUrl,
    required this.latitude,
    required this.longitude,
    required this.storeName,
    required this.address,
    required this.submittedAt,
    required this.updatedAt,
    required this.tags,
    required this.category,
  });

  // Convert from map
  factory Item.fromMap(Map<String, dynamic> map, String documentId) {
    return Item(
      id: documentId,
      userId: map['userId'] ?? '',
      userEmail: map['userEmail'] ?? '',
      itemName: map['itemName'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      currency: map['currency'] ?? 'USD',
      photoUrl: map['photoUrl'] ?? '',
      latitude: (map['latitude'] ?? 0.0).toDouble(),
      longitude: (map['longitude'] ?? 0.0).toDouble(),
      storeName: map['storeName'] ?? '',
      address: map['address'] ?? '',
      submittedAt: map['submittedAt'] != null 
          ? DateTime.parse(map['submittedAt'])
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null 
          ? DateTime.parse(map['updatedAt'])
          : DateTime.now(),
      tags: List<String>.from(map['tags'] ?? []),
      category: map['category'] ?? 'General',
    );
  }

  // Convert to map
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userEmail': userEmail,
      'itemName': itemName,
      'description': description,
      'price': price,
      'currency': currency,
      'photoUrl': photoUrl,
      'latitude': latitude,
      'longitude': longitude,
      'storeName': storeName,
      'address': address,
      'submittedAt': submittedAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'tags': tags,
      'category': category,
    };
  }

  // Copy with new values
  Item copyWith({
    String? id,
    String? userId,
    String? userEmail,
    String? itemName,
    String? description,
    double? price,
    String? currency,
    String? photoUrl,
    double? latitude,
    double? longitude,
    String? storeName,
    String? address,
    DateTime? submittedAt,
    DateTime? updatedAt,
    List<String>? tags,
    String? category,
  }) {
    return Item(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userEmail: userEmail ?? this.userEmail,
      itemName: itemName ?? this.itemName,
      description: description ?? this.description,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      photoUrl: photoUrl ?? this.photoUrl,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      storeName: storeName ?? this.storeName,
      address: address ?? this.address,
      submittedAt: submittedAt ?? this.submittedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      tags: tags ?? this.tags,
      category: category ?? this.category,
    );
  }

  // Calculate distance from another location
  double calculateDistance(double otherLatitude, double otherLongitude) {
    const double earthRadius = 6371; // Earth's radius in kilometers
    
    double lat1 = latitude * (pi / 180);
    double lat2 = otherLatitude * (pi / 180);
    double deltaLat = (otherLatitude - latitude) * (pi / 180);
    double deltaLon = (otherLongitude - longitude) * (pi / 180);

    double a = sin(deltaLat / 2) * sin(deltaLat / 2) +
        cos(lat1) * cos(lat2) * sin(deltaLon / 2) * sin(deltaLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }
}
