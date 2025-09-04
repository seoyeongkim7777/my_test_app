class UserPreferences {
  final String userId;
  final String language;
  final String currency;
  final bool locationPermissionGranted;
  final bool cameraPermissionGranted;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserPreferences({
    required this.userId,
    required this.language,
    required this.currency,
    required this.locationPermissionGranted,
    required this.cameraPermissionGranted,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert from Firestore document
  factory UserPreferences.fromMap(Map<String, dynamic> map) {
    return UserPreferences(
      userId: map['userId'] ?? '',
      language: map['language'] ?? 'English',
      currency: map['currency'] ?? 'USD',
      locationPermissionGranted: map['locationPermissionGranted'] ?? false,
      cameraPermissionGranted: map['cameraPermissionGranted'] ?? false,
      createdAt: map['createdAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'])
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['updatedAt'])
          : DateTime.now(),
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'language': language,
      'currency': currency,
      'locationPermissionGranted': locationPermissionGranted,
      'cameraPermissionGranted': cameraPermissionGranted,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  // Copy with new values
  UserPreferences copyWith({
    String? userId,
    String? language,
    String? currency,
    bool? locationPermissionGranted,
    bool? cameraPermissionGranted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserPreferences(
      userId: userId ?? this.userId,
      language: language ?? this.language,
      currency: currency ?? this.currency,
      locationPermissionGranted: locationPermissionGranted ?? this.locationPermissionGranted,
      cameraPermissionGranted: cameraPermissionGranted ?? this.cameraPermissionGranted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

