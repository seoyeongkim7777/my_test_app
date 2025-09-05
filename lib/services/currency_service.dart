import 'dart:convert';
import 'package:http/http.dart' as http;

class CurrencyService {
  static const String _baseUrl = 'https://api.exchangerate-api.com/v4/latest/';
  
  // Cache for exchange rates to avoid excessive API calls
  static final Map<String, Map<String, double>> _rateCache = {};
  static final Map<String, DateTime> _cacheTimestamps = {};
  static const Duration _cacheValidDuration = Duration(minutes: 5);

  // Get exchange rate from one currency to another
  static Future<double> getExchangeRate(String fromCurrency, String toCurrency) async {
    if (fromCurrency == toCurrency) return 1.0;

    // Check cache first
    final cacheKey = fromCurrency;
    if (_isCacheValid(cacheKey)) {
      final rates = _rateCache[cacheKey];
      if (rates != null && rates.containsKey(toCurrency)) {
        return rates[toCurrency]!;
      }
    }

    try {
      final response = await http.get(Uri.parse('$_baseUrl$fromCurrency'));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final rawRates = data['rates'] as Map<String, dynamic>;
        
        // Convert rates to double, handling both int and double values
        final rates = <String, double>{};
        rawRates.forEach((key, value) {
          if (value is int) {
            rates[key] = value.toDouble();
          } else if (value is double) {
            rates[key] = value;
          } else if (value is num) {
            rates[key] = value.toDouble();
          }
        });
        
        // Cache the rates
        _rateCache[fromCurrency] = rates;
        _cacheTimestamps[fromCurrency] = DateTime.now();
        
        return rates[toCurrency] ?? 1.0;
      } else {
        throw Exception('Failed to load exchange rates: ${response.statusCode}');
      }
    } catch (e) {
      // Return cached rate if available, otherwise return 1.0
      if (_isCacheValid(cacheKey)) {
        final rates = _rateCache[cacheKey];
        if (rates != null && rates.containsKey(toCurrency)) {
          return rates[toCurrency]!;
        }
      }
      throw Exception('Failed to get exchange rate: $e');
    }
  }

  // Convert price from one currency to another
  static Future<double> convertPrice(double amount, String fromCurrency, String toCurrency) async {
    if (fromCurrency == toCurrency) return amount;
    
    final rate = await getExchangeRate(fromCurrency, toCurrency);
    return amount * rate;
  }

  // Get all available currencies (China, US, Korea only)
  static Future<List<String>> getAvailableCurrencies() async {
    try {
      final response = await http.get(Uri.parse('${_baseUrl}USD'));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final rates = data['rates'] as Map<String, dynamic>;
        // Filter to only return supported currencies
        final supportedCurrencies = ['USD', 'KRW', 'CNY'];
        return rates.keys.where((currency) => supportedCurrencies.contains(currency)).toList();
      } else {
        throw Exception('Failed to load currencies: ${response.statusCode}');
      }
    } catch (e) {
      // Return default currencies if API fails (China, US, Korea only)
      return ['USD', 'KRW', 'CNY'];
    }
  }

  // Check if cache is still valid
  static bool _isCacheValid(String currency) {
    final timestamp = _cacheTimestamps[currency];
    if (timestamp == null) return false;
    
    return DateTime.now().difference(timestamp) < _cacheValidDuration;
  }

  // Clear cache (useful for testing or when rates seem stale)
  static void clearCache() {
    _rateCache.clear();
    _cacheTimestamps.clear();
  }

  // Get formatted price string with currency symbol (China, US, Korea only)
  static String formatPrice(double price, String currency) {
    switch (currency) {
      case 'USD':
        return '\$${price.toStringAsFixed(2)}';
      case 'KRW':
        return '₩${price.toStringAsFixed(0)}';
      case 'CNY':
        return '¥${price.toStringAsFixed(2)}';
      default:
        return '${price.toStringAsFixed(2)} $currency';
    }
  }
}
