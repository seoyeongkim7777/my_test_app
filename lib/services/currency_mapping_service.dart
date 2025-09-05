import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'location_service.dart';

class CurrencyMappingService {
  // Map country codes to their local currencies (China, US, Korea only)
  static const Map<String, String> _countryToCurrency = {
    'US': 'USD', // United States
    'KR': 'KRW', // South Korea
    'CN': 'CNY', // China
  };

  // Get currency symbol for a currency code (China, US, Korea only)
  static const Map<String, String> _currencySymbols = {
    'USD': '\$', // US Dollar
    'KRW': '₩', // Korean Won
    'CNY': '¥', // Chinese Yuan
  };

  // Get local currency based on coordinates
  static Future<String> getLocalCurrencyFromCoordinates(double latitude, double longitude) async {
    try {
      debugPrint('🌍 Getting currency for coordinates: $latitude, $longitude');
      
      // Get placemark from coordinates
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      
      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        final countryCode = placemark.isoCountryCode;
        final countryName = placemark.country;
        
        debugPrint('🌍 Country detected: $countryName (Code: $countryCode)');
        
        if (countryCode != null && _countryToCurrency.containsKey(countryCode)) {
          final currency = _countryToCurrency[countryCode]!;
          debugPrint('🌍 Currency mapped: $currency for $countryCode');
          return currency;
        } else {
          debugPrint('🌍 Country code $countryCode not found in currency mapping');
        }
      } else {
        debugPrint('🌍 No placemarks found for coordinates');
      }
      
      // Default to KRW for Korea (since user is expected to be in Korea)
      debugPrint('🌍 Defaulting to KRW (Korean Won)');
      return 'KRW';
    } catch (e) {
      debugPrint('🌍 Error getting currency from coordinates: $e');
      // Default to KRW for Korea instead of USD
      return 'KRW';
    }
  }

  // Get local currency based on address string
  static Future<String> getLocalCurrencyFromAddress(String address) async {
    try {
      // Get coordinates from address
      List<Location> locations = await locationFromAddress(address);
      
      if (locations.isNotEmpty) {
        final location = locations.first;
        return await getLocalCurrencyFromCoordinates(location.latitude, location.longitude);
      }
      
      // Default to USD if address not found
      return 'USD';
    } catch (e) {
      debugPrint('Error getting currency from address: $e');
      return 'USD';
    }
  }

  // Get currency symbol
  static String getCurrencySymbol(String currencyCode) {
    return _currencySymbols[currencyCode] ?? currencyCode;
  }

  // Get currency name (China, US, Korea only)
  static String getCurrencyName(String currencyCode) {
    switch (currencyCode) {
      case 'USD': return 'US Dollar';
      case 'KRW': return 'Korean Won';
      case 'CNY': return 'Chinese Yuan';
      default: return currencyCode;
    }
  }

  // Get user's home currency (this would typically come from user preferences)
  // For now, we'll use a simple method that could be enhanced with user settings
  static Future<String> getUserHomeCurrency() async {
    try {
      // Try to detect user's home currency based on their current location
      // This is a fallback approach - in a real app, this would come from user preferences
      final position = await LocationService.getCurrentLocation();
      if (position != null) {
        final currency = await getLocalCurrencyFromCoordinates(position.latitude, position.longitude);
        debugPrint('🌍 User home currency detected: $currency');
        return currency;
      }
    } catch (e) {
      debugPrint('🌍 Error detecting user home currency: $e');
    }
    
    // Default to KRW for Korea (since user is expected to be in Korea)
    debugPrint('🌍 Using default home currency: KRW');
    return 'KRW';
  }

  // Check if currency is supported
  static bool isCurrencySupported(String currencyCode) {
    return _currencySymbols.containsKey(currencyCode);
  }

  // Get all supported currencies
  static List<String> getSupportedCurrencies() {
    return _currencySymbols.keys.toList();
  }
}
