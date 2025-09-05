import 'package:shared_preferences/shared_preferences.dart';

class UserPreferencesService {
  static final UserPreferencesService _instance = UserPreferencesService._internal();
  factory UserPreferencesService() => _instance;
  UserPreferencesService._internal();

  static const String _languageKey = 'user_language';
  static const String _currencyKey = 'user_currency';
  static const String _usernameKey = 'user_username';
  static const String _emailKey = 'user_email';

  // Default values
  static const String _defaultLanguage = 'English';
  static const String _defaultCurrency = 'KRW';

  // Get user's preferred language
  Future<String> getPreferredLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_languageKey) ?? _defaultLanguage;
  }

  // Set user's preferred language
  Future<void> setPreferredLanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, language);
  }

  // Get user's preferred currency
  Future<String> getPreferredCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_currencyKey) ?? _defaultCurrency;
  }

  // Set user's preferred currency
  Future<void> setPreferredCurrency(String currency) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currencyKey, currency);
  }

  // Get user's username
  Future<String> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_usernameKey) ?? 'Guest User';
  }

  // Set user's username
  Future<void> setUsername(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_usernameKey, username);
  }

  // Get user's email
  Future<String> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_emailKey) ?? 'guest@example.com';
  }

  // Set user's email
  Future<void> setUserEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_emailKey, email);
  }

  // Set user's email (alias for setUserEmail)
  Future<void> setEmail(String email) async {
    await setUserEmail(email);
  }

  // Get all user preferences
  Future<Map<String, String>> getAllPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'language': prefs.getString(_languageKey) ?? _defaultLanguage,
      'currency': prefs.getString(_currencyKey) ?? _defaultCurrency,
      'username': prefs.getString(_usernameKey) ?? 'Guest User',
      'email': prefs.getString(_emailKey) ?? 'guest@example.com',
    };
  }

  // Clear all preferences (for logout)
  Future<void> clearAllPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_languageKey);
    await prefs.remove(_currencyKey);
    await prefs.remove(_usernameKey);
    await prefs.remove(_emailKey);
  }

  // Initialize preferences with default values if not set
  Future<void> initializePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Set default language if not set
    if (!prefs.containsKey(_languageKey)) {
      await prefs.setString(_languageKey, _defaultLanguage);
    }
    
    // Set default currency if not set
    if (!prefs.containsKey(_currencyKey)) {
      await prefs.setString(_currencyKey, _defaultCurrency);
    }
    
    // Set default username if not set
    if (!prefs.containsKey(_usernameKey)) {
      await prefs.setString(_usernameKey, 'Guest User');
    }
    
    // Set default email if not set
    if (!prefs.containsKey(_emailKey)) {
      await prefs.setString(_emailKey, 'guest@example.com');
    }
  }
}
