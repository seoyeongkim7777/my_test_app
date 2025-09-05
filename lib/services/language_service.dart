import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LanguageService extends ChangeNotifier {
  static final LanguageService _instance = LanguageService._internal();
  factory LanguageService() => _instance;
  LanguageService._internal();

  String _currentLanguage = 'English';
  Map<String, dynamic> _translations = {};
  
  String get currentLanguage => _currentLanguage;
  
  void changeLanguage(String newLanguage) async {
    if (_currentLanguage != newLanguage) {
      _currentLanguage = newLanguage;
      await _loadTranslations();
      notifyListeners();
    }
  }
  
  Future<void> _loadTranslations() async {
    try {
      String fileName;
    switch (_currentLanguage) {
      case 'Korean':
          fileName = 'lib/l10n/app_ko.json';
          break;
      case 'Chinese':
          fileName = 'lib/l10n/app_zh.json';
          break;
      default:
          fileName = 'lib/l10n/app_en.json';
      }
      
      final String jsonString = await rootBundle.loadString(fileName);
      _translations = json.decode(jsonString);
    } catch (e) {
      debugPrint('Error loading translations: $e');
      _translations = {};
    }
  }
  
  // Get localized text using dot notation (e.g., 'navigation.home')
  String getLocalizedText(String key) {
    if (_translations.isEmpty) {
      return key; // Fallback to key if translations not loaded
    }
    
    // Handle dot notation for nested keys
    List<String> keys = key.split('.');
    dynamic value = _translations;
    
    for (String k in keys) {
      if (value is Map<String, dynamic> && value.containsKey(k)) {
        value = value[k];
      } else {
        return key; // Fallback to key if not found
      }
    }
    
    return value is String ? value : key;
  }
  
  // Initialize translations on first use
  Future<void> initialize() async {
    if (_translations.isEmpty) {
      await _loadTranslations();
    }
  }
}