import 'dart:io';

class AIRecognitionService {
  // Mock AI responses for development
  // In production, integrate with Google Cloud Vision API, Google Places API, etc.
  
  // Recognize item from photo
  Future<Map<String, dynamic>> recognizeItem(File image) async {
    // Simulate AI processing delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Mock AI response - in production, this would call actual AI service
    final mockResponses = [
      {
        'itemName': 'Nike Air Max 270',
        'category': 'Shoes',
        'brand': 'Nike',
        'confidence': 0.89,
        'suggestions': ['Nike Air Max', 'Running Shoes', 'Athletic Footwear'],
        'tags': ['sports', 'running', 'athletic', 'casual']
      },
      {
        'itemName': 'iPhone 15 Pro',
        'category': 'Electronics',
        'brand': 'Apple',
        'confidence': 0.92,
        'suggestions': ['Smartphone', 'Mobile Phone', 'iPhone'],
        'tags': ['technology', 'mobile', 'smartphone', 'apple']
      },
      {
        'itemName': 'Starbucks Coffee',
        'category': 'Food & Beverage',
        'brand': 'Starbucks',
        'confidence': 0.95,
        'suggestions': ['Coffee', 'Hot Beverage', 'Drink'],
        'tags': ['food', 'beverage', 'coffee', 'hot']
      },
      {
        'itemName': 'Zara T-Shirt',
        'category': 'Clothing',
        'brand': 'Zara',
        'confidence': 0.87,
        'suggestions': ['T-Shirt', 'Shirt', 'Top'],
        'tags': ['clothing', 'fashion', 'casual', 'top']
      },
      {
        'itemName': 'Samsung Galaxy Watch',
        'category': 'Electronics',
        'brand': 'Samsung',
        'confidence': 0.91,
        'suggestions': ['Smartwatch', 'Watch', 'Wearable'],
        'tags': ['technology', 'wearable', 'smartwatch', 'samsung']
      }
    ];
    
    // Return random mock response for demo
    final random = DateTime.now().millisecond % mockResponses.length;
    return mockResponses[random];
  }
  
  // Detect store from photo and location
  Future<Map<String, dynamic>> detectStore(File image, double latitude, double longitude) async {
    // Simulate AI processing delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Mock store detection - in production, use Google Places API
    final mockStores = [
      {
        'storeName': 'Foot Locker',
        'address': '123 Gangnam-daero, Gangnam-gu, Seoul',
        'confidence': 0.85,
        'type': 'Shoe Store',
        'rating': 4.2,
        'distance': 150.0
      },
      {
        'storeName': 'Apple Store',
        'address': '456 Myeongdong-gil, Jung-gu, Seoul',
        'confidence': 0.88,
        'type': 'Electronics Store',
        'rating': 4.5,
        'distance': 300.0
      },
      {
        'storeName': 'Starbucks',
        'address': '789 Hongdae-ro, Mapo-gu, Seoul',
        'confidence': 0.92,
        'type': 'Coffee Shop',
        'rating': 4.1,
        'distance': 75.0
      },
      {
        'storeName': 'Zara',
        'address': '321 Garosu-gil, Gangnam-gu, Seoul',
        'confidence': 0.83,
        'type': 'Clothing Store',
        'rating': 4.0,
        'distance': 200.0
      },
      {
        'storeName': 'Samsung Store',
        'address': '654 Yeouido-dong, Yeongdeungpo-gu, Seoul',
        'confidence': 0.87,
        'type': 'Electronics Store',
        'rating': 4.3,
        'distance': 450.0
      }
    ];
    
    // Return random mock store for demo
    final random = DateTime.now().millisecond % mockStores.length;
    return mockStores[random];
  }
  
  // Get nearby stores based on location
  Future<List<Map<String, dynamic>>> getNearbyStores(double latitude, double longitude) async {
    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Mock nearby stores - in production, use Google Places API
    return [
      {
        'storeName': 'Foot Locker',
        'address': '123 Gangnam-daero, Gangnam-gu, Seoul',
        'type': 'Shoe Store',
        'rating': 4.2,
        'distance': 150.0,
        'latitude': latitude + 0.001,
        'longitude': longitude + 0.001,
      },
      {
        'storeName': 'Nike Store',
        'address': '456 Gangnam-daero, Gangnam-gu, Seoul',
        'type': 'Shoe Store',
        'rating': 4.4,
        'distance': 250.0,
        'latitude': latitude + 0.002,
        'longitude': longitude + 0.001,
      },
      {
        'storeName': 'Adidas Store',
        'address': '789 Gangnam-daero, Gangnam-gu, Seoul',
        'type': 'Shoe Store',
        'rating': 4.1,
        'distance': 350.0,
        'latitude': latitude + 0.003,
        'longitude': longitude + 0.001,
      },
      {
        'storeName': 'Converse Store',
        'address': '321 Gangnam-daero, Gangnam-gu, Seoul',
        'type': 'Shoe Store',
        'rating': 4.0,
        'distance': 450.0,
        'latitude': latitude + 0.004,
        'longitude': longitude + 0.001,
      }
    ];
  }
  
  // Get category suggestions based on item name
  List<String> getCategorySuggestions(String itemName) {
    final itemNameLower = itemName.toLowerCase();
    
    if (itemNameLower.contains('shoe') || itemNameLower.contains('sneaker') || 
        itemNameLower.contains('boot') || itemNameLower.contains('sandal')) {
      return ['Shoes', 'Footwear', 'Athletic', 'Casual'];
    } else if (itemNameLower.contains('phone') || itemNameLower.contains('iphone') || 
               itemNameLower.contains('samsung') || itemNameLower.contains('android')) {
      return ['Electronics', 'Mobile', 'Smartphone', 'Technology'];
    } else if (itemNameLower.contains('coffee') || itemNameLower.contains('tea') || 
               itemNameLower.contains('drink') || itemNameLower.contains('beverage')) {
      return ['Food & Beverage', 'Drinks', 'Hot Beverages', 'Coffee'];
    } else if (itemNameLower.contains('shirt') || itemNameLower.contains('t-shirt') || 
               itemNameLower.contains('dress') || itemNameLower.contains('pants')) {
      return ['Clothing', 'Fashion', 'Apparel', 'Casual'];
    } else if (itemNameLower.contains('watch') || itemNameLower.contains('clock') || 
               itemNameLower.contains('timepiece')) {
      return ['Electronics', 'Wearables', 'Accessories', 'Technology'];
    }
    
    return ['General', 'Other', 'Unknown'];
  }
  
  // Get brand suggestions based on item name
  List<String> getBrandSuggestions(String itemName) {
    final itemNameLower = itemName.toLowerCase();
    
    if (itemNameLower.contains('nike')) return ['Nike', 'Nike Sportswear', 'Nike SB'];
    if (itemNameLower.contains('adidas')) return ['Adidas', 'Adidas Originals', 'Adidas Sportswear'];
    if (itemNameLower.contains('apple') || itemNameLower.contains('iphone')) return ['Apple', 'Apple Inc.'];
    if (itemNameLower.contains('samsung')) return ['Samsung', 'Samsung Electronics'];
    if (itemNameLower.contains('starbucks')) return ['Starbucks', 'Starbucks Coffee'];
    if (itemNameLower.contains('zara')) return ['Zara', 'Zara Fashion'];
    
    return ['Unknown Brand', 'Generic', 'No Brand'];
  }
}
