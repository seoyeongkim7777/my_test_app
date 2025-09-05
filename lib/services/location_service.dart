import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  // Get current user location
  static Future<Position?> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    // Check location permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied');
    }

    // Get current position
    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
    } catch (e) {
      throw Exception('Failed to get current location: $e');
    }
  }

  // Convert address to coordinates (geocoding)
  static Future<Position?> getLocationFromAddress(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        return Position(
          latitude: locations.first.latitude,
          longitude: locations.first.longitude,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          heading: 0,
          speed: 0,
          speedAccuracy: 0,
          altitudeAccuracy: 0,
          headingAccuracy: 0,
        );
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get location from address: $e');
    }
  }

  // Convert coordinates to address (reverse geocoding)
  static Future<String> getAddressFromLocation(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        return '${place.street}, ${place.locality}, ${place.country}';
      }
      return 'Unknown location';
    } catch (e) {
      throw Exception('Failed to get address from location: $e');
    }
  }

  // Get country from coordinates
  static Future<String?> getCountryFromCoordinates(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        return place.country;
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get country from location: $e');
    }
  }

  // Calculate distance between two points
  static double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }

  // Calculate distance from coordinates
  static double calculateDistanceFromCoordinates(double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }

  // Format distance for display
  static String formatDistance(double distanceInMeters) {
    if (distanceInMeters < 1000) {
      return '${distanceInMeters.round()}m';
    } else {
      final km = distanceInMeters / 1000;
      return '${km.toStringAsFixed(1)}km';
    }
  }

  // Get location permission status
  static Future<LocationPermission> getLocationPermissionStatus() async {
    return await Geolocator.checkPermission();
  }

  // Request location permission
  static Future<LocationPermission> requestLocationPermission() async {
    return await Geolocator.requestPermission();
  }

  // Check if location services are enabled
  static Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  // ===== ENHANCED LOCATION FUNCTIONALITY =====

  // Get current location with enhanced information
  static Future<Map<String, dynamic>> getCurrentLocationWithDetails() async {
    try {
      final position = await getCurrentLocation();
      if (position == null) {
        throw Exception('Failed to get current location');
      }

      final address = await getAddressFromLocation(position.latitude, position.longitude);
      
      return {
        'position': position,
        'address': address,
        'latitude': position.latitude,
        'longitude': position.longitude,
        'accuracy': position.accuracy,
        'timestamp': position.timestamp,
      };
    } catch (e) {
      throw Exception('Failed to get location with details: $e');
    }
  }

  // Get nearby stores based on current location
  static Future<List<Map<String, dynamic>>> getNearbyStores(double userLat, double userLon, {double radiusInMeters = 1000}) async {
    try {
      // In production, integrate with Google Places API
      // For now, return mock nearby stores
      final mockStores = [
        {
          'storeName': 'Foot Locker',
          'address': '123 Gangnam-daero, Gangnam-gu, Seoul',
          'type': 'Shoe Store',
          'rating': 4.2,
          'distance': 150.0,
          'latitude': userLat + 0.001,
          'longitude': userLon + 0.001,
        },
        {
          'storeName': 'Nike Store',
          'address': '456 Gangnam-daero, Gangnam-gu, Seoul',
          'type': 'Shoe Store',
          'rating': 4.4,
          'distance': 250.0,
          'latitude': userLat + 0.002,
          'longitude': userLon + 0.001,
        },
        {
          'storeName': 'Adidas Store',
          'address': '789 Gangnam-daero, Gangnam-gu, Seoul',
          'type': 'Shoe Store',
          'rating': 4.1,
          'distance': 350.0,
          'latitude': userLat + 0.003,
          'longitude': userLon + 0.001,
        },
        {
          'storeName': 'Converse Store',
          'address': '321 Gangnam-daero, Gangnam-gu, Seoul',
          'type': 'Shoe Store',
          'rating': 4.0,
          'distance': 450.0,
          'latitude': userLat + 0.004,
          'longitude': userLon + 0.001,
        }
      ];

      // Filter by distance
      return mockStores.where((store) {
        final storeLat = store['latitude'] as double;
        final storeLon = store['longitude'] as double;
        final distance = calculateDistance(userLat, userLon, storeLat, storeLon);
        return distance <= radiusInMeters;
      }).toList();
    } catch (e) {
      throw Exception('Failed to get nearby stores: $e');
    }
  }

  // Get store suggestions based on item category
  static List<String> getStoreSuggestions(String category) {
    switch (category.toLowerCase()) {
      case 'shoes':
      case 'footwear':
        return ['Foot Locker', 'Nike Store', 'Adidas Store', 'Converse Store', 'New Balance'];
      case 'electronics':
        return ['Apple Store', 'Samsung Store', 'Best Buy', 'Electronics Mart', 'Tech Store'];
      case 'clothing':
        return ['Zara', 'H&M', 'Uniqlo', 'Forever 21', 'Gap'];
      case 'food & beverage':
        return ['Starbucks', 'McDonald\'s', 'KFC', 'Local Cafe', 'Restaurant'];
      default:
        return ['General Store', 'Department Store', 'Local Shop'];
    }
  }
}
