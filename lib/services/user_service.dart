import 'package:flutter/foundation.dart';

class UserService extends ChangeNotifier {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  String? _username;
  String? _email;
  String? _selectedLanguage;
  String? _selectedCurrency;
  List<String> _selectedInterests = [];
  String? _selectedAgeGroup;

  // Getters
  String? get username => _username;
  String? get email => _email;
  String? get selectedLanguage => _selectedLanguage;
  String? get selectedCurrency => _selectedCurrency;
  List<String> get selectedInterests => _selectedInterests;
  String? get selectedAgeGroup => _selectedAgeGroup;

  // Setters
  void setUsername(String username) {
    _username = username;
    notifyListeners();
  }

  void setEmail(String email) {
    _email = email;
    notifyListeners();
  }

  void setLanguage(String language) {
    _selectedLanguage = language;
    notifyListeners();
  }

  void setCurrency(String currency) {
    _selectedCurrency = currency;
    notifyListeners();
  }

  void setInterests(List<String> interests) {
    _selectedInterests = interests;
    notifyListeners();
  }

  void setAgeGroup(String ageGroup) {
    _selectedAgeGroup = ageGroup;
    notifyListeners();
  }

  // Clear all user data (for logout)
  void clearUserData() {
    _username = null;
    _email = null;
    _selectedLanguage = null;
    _selectedCurrency = null;
    _selectedInterests = [];
    _selectedAgeGroup = null;
    notifyListeners();
  }

  // Check if user is logged in
  bool get isLoggedIn => _username != null && _email != null;
}
