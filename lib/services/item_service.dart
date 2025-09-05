import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/item_model.dart';
import '../services/currency_service.dart';
import '../services/currency_mapping_service.dart';

class ItemService {
  // Mock data storage (in production, this would be a real database)
  static final List<Item> _mockItems = _generateMockItems();

  // Add a new item
  Future<String> addItem(Item item, File? photoFile) async {
    try {
      // Simulate photo upload delay
      if (photoFile != null) {
        await Future.delayed(const Duration(seconds: 1));
      }

      // Create item with photo URL (mock)
      final itemWithPhoto = item.copyWith(
        photoUrl: photoFile != null ? 'https://via.placeholder.com/300' : '',
        submittedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Add to mock storage
      _mockItems.add(itemWithPhoto);
      
      return itemWithPhoto.id;
    } catch (e) {
      throw Exception('Failed to add item: $e');
    }
  }

  // Get item by ID
  Future<Item?> getItem(String itemId) async {
    try {
      return _mockItems.firstWhere(
        (item) => item.id == itemId,
        orElse: () => throw Exception('Item not found'),
      );
    } catch (e) {
      return null;
    }
  }

  // Get items by user ID
  Future<List<Item>> getItemsByUser(String userId) async {
    try {
      return _mockItems
          .where((item) => item.userId == userId)
          .toList()
        ..sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
    } catch (e) {
      throw Exception('Failed to get user items: $e');
    }
  }

  // Search items by name or description
  Future<List<Item>> searchItems(String searchTerm) async {
    try {
      final searchLower = searchTerm.toLowerCase();
      return _mockItems
          .where((item) => 
            item.itemName.toLowerCase().contains(searchLower) ||
            item.description.toLowerCase().contains(searchLower))
          .take(20)
          .toList();
    } catch (e) {
      throw Exception('Failed to search items: $e');
    }
  }

  // Get nearby items
  Future<List<Item>> getNearbyItems(double userLat, double userLon, double radiusInMeters) async {
    try {
      return _mockItems
          .where((item) {
            final distance = item.calculateDistance(userLat, userLon);
            return distance <= radiusInMeters;
          })
          .toList()
        ..sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
    } catch (e) {
      throw Exception('Failed to get nearby items: $e');
    }
  }

  // Get similar items (by category and tags)
  Future<List<Item>> getSimilarItems(Item item, int limit) async {
    try {
      return _mockItems
          .where((i) => i.category == item.category && i.id != item.id)
          .take(limit)
          .toList();
    } catch (e) {
      throw Exception('Failed to get similar items: $e');
    }
  }

  // Update item
  Future<void> updateItem(Item item) async {
    try {
      final index = _mockItems.indexWhere((i) => i.id == item.id);
      if (index != -1) {
        _mockItems[index] = item.copyWith(updatedAt: DateTime.now());
      }
    } catch (e) {
      throw Exception('Failed to update item: $e');
    }
  }

  // Delete item
  Future<void> deleteItem(String itemId) async {
    try {
      _mockItems.removeWhere((item) => item.id == itemId);
    } catch (e) {
      throw Exception('Failed to delete item: $e');
    }
  }

  // Get items with converted prices
  Future<List<Map<String, dynamic>>> getItemsWithConvertedPrices(
    List<Item> items,
    String targetCurrency,
  ) async {
    final List<Map<String, dynamic>> result = [];

    for (final item in items) {
      try {
        final convertedPrice = await CurrencyService.convertPrice(
          item.price,
          item.currency,
          targetCurrency,
        );

        result.add({
          'item': item,
          'originalPrice': item.price,
          'originalCurrency': item.currency,
          'convertedPrice': convertedPrice,
          'targetCurrency': targetCurrency,
        });
      } catch (e) {
        // If conversion fails, add item without converted price
        result.add({
          'item': item,
          'originalPrice': item.price,
          'originalCurrency': item.currency,
          'convertedPrice': item.price,
          'targetCurrency': targetCurrency,
          'conversionError': true,
        });
      }
    }

    return result;
  }

  // Get item statistics
  Future<Map<String, dynamic>> getItemStatistics() async {
    try {
      final totalItems = _mockItems.length;
      
      // Calculate total value in different currencies
      double totalUSD = 0;
      double totalKRW = 0;
      double totalCNY = 0;

      for (final item in _mockItems) {
        switch (item.currency) {
          case 'USD':
            totalUSD += item.price;
            break;
          case 'KRW':
            totalKRW += item.price;
            break;
          case 'CNY':
            totalCNY += item.price;
            break;
        }
      }

      return {
        'totalItems': totalItems,
        'totalUSD': totalUSD,
        'totalKRW': totalKRW,
        'totalCNY': totalCNY,
      };
    } catch (e) {
      throw Exception('Failed to get item statistics: $e');
    }
  }

  // Find similar items by name
  Future<List<Item>> findSimilarItemsByName(String itemName, String category, {int limit = 20}) async {
    try {
      final keywords = itemName.toLowerCase().split(' ');
      final similarItems = _mockItems.where((item) {
        if (item.category != category) return false;
        
        final itemNameLower = item.itemName.toLowerCase();
        final itemWords = itemNameLower.split(' ');
        
        // Check if any keywords match
        return keywords.any((keyword) => 
          itemWords.any((word) => word.contains(keyword) || keyword.contains(word)));
      }).toList();

      // Sort by relevance
      similarItems.sort((a, b) {
        int scoreA = _calculateRelevanceScore(itemName, a.itemName);
        int scoreB = _calculateRelevanceScore(itemName, b.itemName);
        return scoreB.compareTo(scoreA);
      });

      return similarItems.take(limit).toList();
    } catch (e) {
      throw Exception('Failed to find similar items: $e');
    }
  }

  // Calculate relevance score for item name matching
  int _calculateRelevanceScore(String searchTerm, String itemName) {
    final searchWords = searchTerm.toLowerCase().split(' ');
    final itemWords = itemName.toLowerCase().split(' ');
    
    int score = 0;
    for (final searchWord in searchWords) {
      for (final itemWord in itemWords) {
        if (itemWord.contains(searchWord) || searchWord.contains(itemWord)) {
          score += searchWord.length == itemWord.length ? 3 : 1;
        }
      }
    }
    return score;
  }

  // Analyze if price is fair compared to similar items
  Future<Map<String, dynamic>> analyzePriceFairness(Item item) async {
    try {
      final similarItems = await findSimilarItemsByName(item.itemName, item.category);
      
      if (similarItems.isEmpty) {
        return {
          'isFair': true,
          'message': 'Fair Price',
          'description': 'No similar items found for comparison',
          'averagePrice': item.price,
          'priceComparison': 0.0,
          'similarItemsCount': 0,
          'confidence': 'low',
        };
      }

      // Convert all prices to the same currency for comparison
      final List<double> convertedPrices = [];
      for (final similarItem in similarItems) {
        try {
          final convertedPrice = await CurrencyService.convertPrice(
            similarItem.price,
            similarItem.currency,
            item.currency,
          );
          convertedPrices.add(convertedPrice);
        } catch (e) {
          debugPrint('Failed to convert price: $e');
        }
      }

      if (convertedPrices.isEmpty) {
        return {
          'isFair': true,
          'message': 'Fair Price',
          'description': 'Unable to compare prices due to currency conversion issues',
          'averagePrice': item.price,
          'priceComparison': 0.0,
          'similarItemsCount': 0,
          'confidence': 'low',
        };
      }

      final averagePrice = convertedPrices.reduce((a, b) => a + b) / convertedPrices.length;
      final priceComparison = ((item.price - averagePrice) / averagePrice) * 100;
      
      // Price analysis logic with detailed reasoning
      final isFair = priceComparison <= 20.0;
      final confidence = convertedPrices.length >= 3 ? 'high' : 
                        convertedPrices.length >= 2 ? 'medium' : 'low';
      
      String message;
      String description;
      String reasoning;
      
      if (isFair) {
        if (priceComparison <= -15.0) {
          message = 'Excellent Deal!';
          description = 'This price is significantly below average - great value!';
          reasoning = _generateExcellentDealReasoning(item, averagePrice, convertedPrices.length);
        } else if (priceComparison <= -5.0) {
          message = 'Good Deal';
          description = 'This price is below average - good value!';
          reasoning = _generateGoodDealReasoning(item, averagePrice, convertedPrices.length);
        } else {
          message = 'Fair Price';
          description = 'This price is reasonable compared to similar items';
          reasoning = _generateFairPriceReasoning(item, averagePrice, convertedPrices.length);
        }
      } else {
        if (priceComparison >= 50.0) {
          message = 'Very High Price';
          description = 'This price is much higher than average - consider other options';
          reasoning = _generateOverpricedReasoning(item, averagePrice, convertedPrices.length);
        } else {
          message = 'High Price';
          description = 'This price is above average - you might find better deals nearby';
          reasoning = _generateSlightlyOverpricedReasoning(item, averagePrice, convertedPrices.length);
        }
      }

      return {
        'isFair': isFair,
        'message': message,
        'description': description,
        'reasoning': reasoning,
        'averagePrice': averagePrice,
        'priceComparison': priceComparison,
        'similarItemsCount': convertedPrices.length,
        'similarItems': similarItems,
        'confidence': confidence,
      };
    } catch (e) {
      throw Exception('Failed to analyze price fairness: $e');
    }
  }

  // Get nearby stores selling similar items
  Future<List<Map<String, dynamic>>> getNearbyStoresWithSimilarItems(
    String itemName,
    String category,
    double userLat,
    double userLon,
    String userCurrency,
    {double radiusInMeters = 10000}
  ) async {
    try {
      final similarItems = await findSimilarItemsByName(itemName, category);
      
      // Filter by distance and convert prices
      final List<Map<String, dynamic>> storeResults = [];
      
      for (final item in similarItems) {
        final distance = item.calculateDistance(userLat, userLon);
        
        if (distance <= radiusInMeters) {
          try {
            final convertedPrice = await CurrencyService.convertPrice(
              item.price,
              item.currency,
              userCurrency,
            );
            
            storeResults.add({
              'item': item,
              'distance': distance,
              'convertedPrice': convertedPrice,
              'originalPrice': item.price,
              'originalCurrency': item.currency,
              'distanceText': _formatDistance(distance),
            });
          } catch (e) {
            debugPrint('Failed to convert price for store item: $e');
          }
        }
      }
      
      // Sort by distance (closest first)
      storeResults.sort((a, b) => a['distance'].compareTo(b['distance']));
      
      return storeResults;
    } catch (e) {
      throw Exception('Failed to get nearby stores: $e');
    }
  }

  // Format distance for display
  String _formatDistance(double distanceInMeters) {
    if (distanceInMeters < 1000) {
      return '${distanceInMeters.round()}m';
    } else {
      final km = distanceInMeters / 1000;
      return '${km.toStringAsFixed(1)}km';
    }
  }

  // Generate detailed reasoning for price analysis
  String _generateExcellentDealReasoning(Item item, double averagePrice, int itemCount) {
    final savings = averagePrice - item.price;
    final localSymbol = CurrencyMappingService.getCurrencySymbol(item.currency);
    return "🎉 This is an exceptional deal! You're saving $localSymbol${savings.toStringAsFixed(item.currency == 'KRW' ? 0 : 2)} compared to the average price of $localSymbol${averagePrice.toStringAsFixed(item.currency == 'KRW' ? 0 : 2)}. Based on $itemCount similar items in the area, this price is ${((averagePrice - item.price) / averagePrice * 100).toStringAsFixed(1)}% below market rate. This could be due to a clearance sale, bulk discount, or competitive pricing strategy. We recommend purchasing this item as it offers outstanding value for money.";
  }

  String _generateGoodDealReasoning(Item item, double averagePrice, int itemCount) {
    final savings = averagePrice - item.price;
    final localSymbol = CurrencyMappingService.getCurrencySymbol(item.currency);
    return "👍 This is a good deal! You're saving $localSymbol${savings.toStringAsFixed(item.currency == 'KRW' ? 0 : 2)} compared to the average price of $localSymbol${averagePrice.toStringAsFixed(item.currency == 'KRW' ? 0 : 2)}. Based on $itemCount similar items in the area, this price is ${((averagePrice - item.price) / averagePrice * 100).toStringAsFixed(1)}% below market rate. This suggests the store is offering competitive pricing or may have lower overhead costs. It's a solid choice for value-conscious shoppers.";
  }

  String _generateFairPriceReasoning(Item item, double averagePrice, int itemCount) {
    final localSymbol = CurrencyMappingService.getCurrencySymbol(item.currency);
    return "✅ This is a fair price! At $localSymbol${item.price.toStringAsFixed(item.currency == 'KRW' ? 0 : 2)}, it's very close to the average market price of $localSymbol${averagePrice.toStringAsFixed(item.currency == 'KRW' ? 0 : 2)}. Based on $itemCount similar items in the area, this pricing is within normal market range. The price difference of ${((item.price - averagePrice) / averagePrice * 100).toStringAsFixed(1)}% is typical for this type of product and reflects standard retail margins. You're paying a reasonable price for this item.";
  }

  String _generateSlightlyOverpricedReasoning(Item item, double averagePrice, int itemCount) {
    final extra = item.price - averagePrice;
    final localSymbol = CurrencyMappingService.getCurrencySymbol(item.currency);
    return "⚠️ This price is slightly above average. You're paying $localSymbol${extra.toStringAsFixed(item.currency == 'KRW' ? 0 : 2)} more than the average price of $localSymbol${averagePrice.toStringAsFixed(item.currency == 'KRW' ? 0 : 2)}. Based on $itemCount similar items in the area, this represents a ${((item.price - averagePrice) / averagePrice * 100).toStringAsFixed(1)}% premium. This could be due to the store's location (premium area), brand reputation, or additional services offered. Consider if the convenience or service justifies the extra cost.";
  }

  String _generateOverpricedReasoning(Item item, double averagePrice, int itemCount) {
    final extra = item.price - averagePrice;
    final localSymbol = CurrencyMappingService.getCurrencySymbol(item.currency);
    return "🚨 This price is significantly above average! You're paying $localSymbol${extra.toStringAsFixed(item.currency == 'KRW' ? 0 : 2)} more than the average price of $localSymbol${averagePrice.toStringAsFixed(item.currency == 'KRW' ? 0 : 2)}. Based on $itemCount similar items in the area, this represents a ${((item.price - averagePrice) / averagePrice * 100).toStringAsFixed(1)}% premium. This high markup could be due to tourist pricing, premium location, or limited competition. We strongly recommend shopping around - you could save a substantial amount by visiting other stores in the area.";
  }

  // Generate comprehensive mock data for testing
  static List<Item> _generateMockItems() {
    final now = DateTime.now();
    return [
      // Electronics - iPhone cases (Seoul, Korea - using KRW)
      Item(
        id: 'mock_1',
        userId: 'user_1',
        userEmail: 'user1@example.com',
        itemName: 'iPhone 15 Pro Case',
        category: 'Electronics',
        description: 'Clear protective case for iPhone 15 Pro',
        price: 35000.0, // 25.99 USD ≈ 35,000 KRW
        currency: 'KRW',
        storeName: 'TechMart',
        address: '123 Tech Street, Seoul',
        latitude: 37.5665,
        longitude: 126.9780,
        photoUrl: 'https://via.placeholder.com/300',
        submittedAt: now.subtract(const Duration(hours: 2)),
        updatedAt: now.subtract(const Duration(hours: 2)),
        tags: ['electronics', 'phone', 'case', 'protection'],
      ),
      Item(
        id: 'mock_2',
        userId: 'user_2',
        userEmail: 'user2@example.com',
        itemName: 'iPhone 15 Pro Case',
        category: 'Electronics',
        description: 'Silicone case for iPhone 15 Pro with MagSafe',
        price: 27000.0, // 19.99 USD ≈ 27,000 KRW
        currency: 'KRW',
        storeName: 'Mobile World',
        address: '456 Mobile Ave, Seoul',
        latitude: 37.5651,
        longitude: 126.9895,
        photoUrl: 'https://via.placeholder.com/300',
        submittedAt: now.subtract(const Duration(hours: 5)),
        updatedAt: now.subtract(const Duration(hours: 5)),
        tags: ['electronics', 'phone', 'case', 'magsafe'],
      ),
      Item(
        id: 'mock_3',
        userId: 'user_3',
        userEmail: 'user3@example.com',
        itemName: 'iPhone 15 Pro Case',
        category: 'Electronics',
        description: 'Premium leather case for iPhone 15 Pro',
        price: 60000.0, // 45.00 USD ≈ 60,000 KRW
        currency: 'KRW',
        storeName: 'Luxury Accessories',
        address: '789 Luxury Blvd, Seoul',
        latitude: 37.5680,
        longitude: 126.9750,
        photoUrl: 'https://via.placeholder.com/300',
        submittedAt: now.subtract(const Duration(days: 1)),
        updatedAt: now.subtract(const Duration(days: 1)),
        tags: ['electronics', 'phone', 'case', 'leather', 'premium'],
      ),
      Item(
        id: 'mock_4',
        userId: 'user_4',
        userEmail: 'user4@example.com',
        itemName: 'iPhone 15 Pro Case',
        category: 'Electronics',
        description: 'Basic clear case for iPhone 15 Pro',
        price: 17500.0, // 12.99 USD ≈ 17,500 KRW
        currency: 'KRW',
        storeName: 'Budget Tech',
        address: '321 Budget St, Seoul',
        latitude: 37.5640,
        longitude: 126.9820,
        photoUrl: 'https://via.placeholder.com/300',
        submittedAt: now.subtract(const Duration(days: 2)),
        updatedAt: now.subtract(const Duration(days: 2)),
        tags: ['electronics', 'phone', 'case', 'budget'],
      ),

      // Fashion - Sneakers
      Item(
        id: 'mock_5',
        userId: 'user_5',
        userEmail: 'user5@example.com',
        itemName: 'Nike Air Max 270',
        category: 'Fashion',
        description: 'White Nike Air Max 270 sneakers size 10',
        price: 200000.0, // 150.00 USD ≈ 200,000 KRW
        currency: 'KRW',
        storeName: 'Sneaker Palace',
        address: '555 Sneaker St, Seoul',
        latitude: 37.5700,
        longitude: 126.9900,
        photoUrl: 'https://via.placeholder.com/300',
        submittedAt: now.subtract(const Duration(hours: 3)),
        updatedAt: now.subtract(const Duration(hours: 3)),
        tags: ['fashion', 'shoes', 'nike', 'sneakers', 'white'],
      ),
      Item(
        id: 'mock_6',
        userId: 'user_6',
        userEmail: 'user6@example.com',
        itemName: 'Nike Air Max 270',
        category: 'Fashion',
        description: 'Black Nike Air Max 270 sneakers size 10',
        price: 180000.0, // 135.99 USD ≈ 180,000 KRW
        currency: 'KRW',
        storeName: 'Sports World',
        address: '777 Sports Ave, Seoul',
        latitude: 37.5720,
        longitude: 126.9850,
        photoUrl: 'https://via.placeholder.com/300',
        submittedAt: now.subtract(const Duration(hours: 6)),
        updatedAt: now.subtract(const Duration(hours: 6)),
        tags: ['fashion', 'shoes', 'nike', 'sneakers', 'black'],
      ),
      Item(
        id: 'mock_7',
        userId: 'user_7',
        userEmail: 'user7@example.com',
        itemName: 'Nike Air Max 270',
        category: 'Fashion',
        description: 'Blue Nike Air Max 270 sneakers size 10',
        price: 240000.0, // 180.00 USD ≈ 240,000 KRW
        currency: 'KRW',
        storeName: 'Premium Footwear',
        address: '999 Premium Rd, Seoul',
        latitude: 37.5750,
        longitude: 126.9800,
        photoUrl: 'https://via.placeholder.com/300',
        submittedAt: now.subtract(const Duration(days: 1, hours: 2)),
        updatedAt: now.subtract(const Duration(days: 1, hours: 2)),
        tags: ['fashion', 'shoes', 'nike', 'sneakers', 'blue', 'premium'],
      ),

      // Food & Beverages - Coffee
      Item(
        id: 'mock_8',
        userId: 'user_8',
        userEmail: 'user8@example.com',
        itemName: 'Starbucks Grande Latte',
        category: 'Food & Beverages',
        description: 'Grande size latte from Starbucks',
        price: 8000.0, // 5.95 USD ≈ 8,000 KRW
        currency: 'KRW',
        storeName: 'Starbucks Myeongdong',
        address: '111 Myeongdong St, Seoul',
        latitude: 37.5636,
        longitude: 126.9826,
        photoUrl: 'https://via.placeholder.com/300',
        submittedAt: now.subtract(const Duration(hours: 1)),
        updatedAt: now.subtract(const Duration(hours: 1)),
        tags: ['food', 'beverages', 'coffee', 'starbucks', 'latte'],
      ),
      Item(
        id: 'mock_9',
        userId: 'user_9',
        userEmail: 'user9@example.com',
        itemName: 'Starbucks Grande Latte',
        category: 'Food & Beverages',
        description: 'Grande size latte from Starbucks',
        price: 8400.0, // 6.25 USD ≈ 8,400 KRW
        currency: 'KRW',
        storeName: 'Starbucks Gangnam',
        address: '222 Gangnam St, Seoul',
        latitude: 37.5172,
        longitude: 127.0473,
        photoUrl: 'https://via.placeholder.com/300',
        submittedAt: now.subtract(const Duration(hours: 4)),
        updatedAt: now.subtract(const Duration(hours: 4)),
        tags: ['food', 'beverages', 'coffee', 'starbucks', 'latte'],
      ),
      Item(
        id: 'mock_10',
        userId: 'user_10',
        userEmail: 'user10@example.com',
        itemName: 'Starbucks Grande Latte',
        category: 'Food & Beverages',
        description: 'Grande size latte from Starbucks',
        price: 7400.0, // 5.50 USD ≈ 7,400 KRW
        currency: 'KRW',
        storeName: 'Starbucks Hongdae',
        address: '333 Hongdae St, Seoul',
        latitude: 37.5563,
        longitude: 126.9226,
        photoUrl: 'https://via.placeholder.com/300',
        submittedAt: now.subtract(const Duration(hours: 7)),
        updatedAt: now.subtract(const Duration(hours: 7)),
        tags: ['food', 'beverages', 'coffee', 'starbucks', 'latte'],
      ),

      // Beauty & Health - Skincare
      Item(
        id: 'mock_11',
        userId: 'user_11',
        userEmail: 'user11@example.com',
        itemName: 'Laneige Water Sleeping Mask',
        category: 'Beauty & Health',
        description: '75ml Laneige Water Sleeping Mask',
        price: 38000.0, // 28.00 USD ≈ 38,000 KRW
        currency: 'KRW',
        storeName: 'Beauty Plus',
        address: '444 Beauty St, Seoul',
        latitude: 37.5600,
        longitude: 126.9700,
        photoUrl: 'https://via.placeholder.com/300',
        submittedAt: now.subtract(const Duration(hours: 2)),
        updatedAt: now.subtract(const Duration(hours: 2)),
        tags: ['beauty', 'skincare', 'laneige', 'mask', 'korean'],
      ),
      Item(
        id: 'mock_12',
        userId: 'user_12',
        userEmail: 'user12@example.com',
        itemName: 'Laneige Water Sleeping Mask',
        category: 'Beauty & Health',
        description: '75ml Laneige Water Sleeping Mask',
        price: 44000.0, // 32.50 USD ≈ 44,000 KRW
        currency: 'KRW',
        storeName: 'K-Beauty Store',
        address: '555 K-Beauty Ave, Seoul',
        latitude: 37.5650,
        longitude: 126.9750,
        photoUrl: 'https://via.placeholder.com/300',
        submittedAt: now.subtract(const Duration(days: 1)),
        updatedAt: now.subtract(const Duration(days: 1)),
        tags: ['beauty', 'skincare', 'laneige', 'mask', 'korean'],
      ),
      Item(
        id: 'mock_13',
        userId: 'user_13',
        userEmail: 'user13@example.com',
        itemName: 'Laneige Water Sleeping Mask',
        category: 'Beauty & Health',
        description: '75ml Laneige Water Sleeping Mask',
        price: 34000.0, // 24.99 USD ≈ 34,000 KRW
        currency: 'KRW',
        storeName: 'Cosmetic World',
        address: '666 Cosmetic Rd, Seoul',
        latitude: 37.5700,
        longitude: 126.9800,
        photoUrl: 'https://via.placeholder.com/300',
        submittedAt: now.subtract(const Duration(days: 2)),
        updatedAt: now.subtract(const Duration(days: 2)),
        tags: ['beauty', 'skincare', 'laneige', 'mask', 'korean'],
      ),

      // Home & Living - Kitchen items
      Item(
        id: 'mock_14',
        userId: 'user_14',
        userEmail: 'user14@example.com',
        itemName: 'Instant Pot Duo 6Qt',
        category: 'Home & Living',
        description: '6 Quart Instant Pot Duo pressure cooker',
        price: 135000.0, // 99.99 USD ≈ 135,000 KRW
        currency: 'KRW',
        storeName: 'Home Essentials',
        address: '777 Home St, Seoul',
        latitude: 37.5750,
        longitude: 126.9850,
        photoUrl: 'https://via.placeholder.com/300',
        submittedAt: now.subtract(const Duration(hours: 5)),
        updatedAt: now.subtract(const Duration(hours: 5)),
        tags: ['home', 'kitchen', 'instant pot', 'pressure cooker', 'appliance'],
      ),
      Item(
        id: 'mock_15',
        userId: 'user_15',
        userEmail: 'user15@example.com',
        itemName: 'Instant Pot Duo 6Qt',
        category: 'Home & Living',
        description: '6 Quart Instant Pot Duo pressure cooker',
        price: 120000.0, // 89.99 USD ≈ 120,000 KRW
        currency: 'KRW',
        storeName: 'Kitchen Pro',
        address: '888 Kitchen Ave, Seoul',
        latitude: 37.5800,
        longitude: 126.9900,
        photoUrl: 'https://via.placeholder.com/300',
        submittedAt: now.subtract(const Duration(days: 1, hours: 3)),
        updatedAt: now.subtract(const Duration(days: 1, hours: 3)),
        tags: ['home', 'kitchen', 'instant pot', 'pressure cooker', 'appliance'],
      ),
      Item(
        id: 'mock_16',
        userId: 'user_16',
        userEmail: 'user16@example.com',
        itemName: 'Instant Pot Duo 6Qt',
        category: 'Home & Living',
        description: '6 Quart Instant Pot Duo pressure cooker',
        price: 160000.0, // 119.99 USD ≈ 160,000 KRW
        currency: 'KRW',
        storeName: 'Premium Appliances',
        address: '999 Premium St, Seoul',
        latitude: 37.5850,
        longitude: 126.9950,
        photoUrl: 'https://via.placeholder.com/300',
        submittedAt: now.subtract(const Duration(days: 3)),
        updatedAt: now.subtract(const Duration(days: 3)),
        tags: ['home', 'kitchen', 'instant pot', 'pressure cooker', 'appliance', 'premium'],
      ),

      // Books & Media
      Item(
        id: 'mock_17',
        userId: 'user_17',
        userEmail: 'user17@example.com',
        itemName: 'Harry Potter and the Sorcerer\'s Stone',
        category: 'Books & Media',
        description: 'Hardcover edition of Harry Potter book 1',
        price: 25000.0, // 18.99 USD ≈ 25,000 KRW
        currency: 'KRW',
        storeName: 'Book World',
        address: '101 Book St, Seoul',
        latitude: 37.5900,
        longitude: 127.0000,
        photoUrl: 'https://via.placeholder.com/300',
        submittedAt: now.subtract(const Duration(hours: 8)),
        updatedAt: now.subtract(const Duration(hours: 8)),
        tags: ['books', 'harry potter', 'fantasy', 'hardcover'],
      ),
      Item(
        id: 'mock_18',
        userId: 'user_18',
        userEmail: 'user18@example.com',
        itemName: 'Harry Potter and the Sorcerer\'s Stone',
        category: 'Books & Media',
        description: 'Hardcover edition of Harry Potter book 1',
        price: 30000.0, // 22.50 USD ≈ 30,000 KRW
        currency: 'KRW',
        storeName: 'Literary Corner',
        address: '202 Literary Ave, Seoul',
        latitude: 37.5950,
        longitude: 127.0050,
        photoUrl: 'https://via.placeholder.com/300',
        submittedAt: now.subtract(const Duration(days: 1, hours: 5)),
        updatedAt: now.subtract(const Duration(days: 1, hours: 5)),
        tags: ['books', 'harry potter', 'fantasy', 'hardcover'],
      ),

      // Sports & Outdoors
      Item(
        id: 'mock_19',
        userId: 'user_19',
        userEmail: 'user19@example.com',
        itemName: 'Yoga Mat Premium',
        category: 'Sports & Outdoors',
        description: 'Non-slip premium yoga mat 6mm thick',
        price: 47000.0, // 35.00 USD ≈ 47,000 KRW
        currency: 'KRW',
        storeName: 'Fitness Plus',
        address: '303 Fitness St, Seoul',
        latitude: 37.6000,
        longitude: 127.0100,
        photoUrl: 'https://via.placeholder.com/300',
        submittedAt: now.subtract(const Duration(hours: 6)),
        updatedAt: now.subtract(const Duration(hours: 6)),
        tags: ['sports', 'yoga', 'fitness', 'mat', 'premium'],
      ),
      Item(
        id: 'mock_20',
        userId: 'user_20',
        userEmail: 'user20@example.com',
        itemName: 'Yoga Mat Premium',
        category: 'Sports & Outdoors',
        description: 'Non-slip premium yoga mat 6mm thick',
        price: 40000.0, // 29.99 USD ≈ 40,000 KRW
        currency: 'KRW',
        storeName: 'Sports Central',
        address: '404 Sports Rd, Seoul',
        latitude: 37.6050,
        longitude: 127.0150,
        photoUrl: 'https://via.placeholder.com/300',
        submittedAt: now.subtract(const Duration(days: 2, hours: 2)),
        updatedAt: now.subtract(const Duration(days: 2, hours: 2)),
        tags: ['sports', 'yoga', 'fitness', 'mat', 'premium'],
      ),

      // Additional Korea-specific mock data (more items near user location)
      
      // Korea - Gangnam District items
      Item(
        id: 'mock_21',
        userId: 'user_21',
        userEmail: 'user21@example.com',
        itemName: 'Samsung Galaxy S24 Ultra',
        category: 'Electronics',
        description: 'Samsung Galaxy S24 Ultra 512GB in Titanium Black',
        price: 1500000.0, // ₩1,500,000
        currency: 'KRW',
        storeName: 'Samsung Digital Plaza',
        address: 'Gangnam Station, Seoul',
        latitude: 37.4979,
        longitude: 127.0276,
        photoUrl: 'https://via.placeholder.com/300',
        submittedAt: now.subtract(const Duration(hours: 3)),
        updatedAt: now.subtract(const Duration(hours: 3)),
        tags: ['electronics', 'samsung', 'smartphone', 'android'],
      ),

      Item(
        id: 'mock_22',
        userId: 'user_22',
        userEmail: 'user22@example.com',
        itemName: 'LG OLED TV 65인치',
        category: 'Electronics',
        description: 'LG OLED 65인치 4K 스마트 TV',
        price: 2500000.0, // ₩2,500,000
        currency: 'KRW',
        storeName: 'LG전자 매장',
        address: '코엑스몰, 강남구',
        latitude: 37.5115,
        longitude: 127.0590,
        photoUrl: 'https://via.placeholder.com/300',
        submittedAt: now.subtract(const Duration(days: 1)),
        updatedAt: now.subtract(const Duration(days: 1)),
        tags: ['electronics', 'tv', 'lg', 'oled'],
      ),

      // Korea - Hongdae District items
      Item(
        id: 'mock_23',
        userId: 'user_23',
        userEmail: 'user23@example.com',
        itemName: 'Nike Air Force 1',
        category: 'Fashion',
        description: '화이트 나이키 에어포스 1 스니커즈',
        price: 120000.0, // ₩120,000
        currency: 'KRW',
        storeName: '나이키 홍대점',
        address: '홍대입구역, 마포구',
        latitude: 37.5563,
        longitude: 126.9226,
        photoUrl: 'https://via.placeholder.com/300',
        submittedAt: now.subtract(const Duration(hours: 5)),
        updatedAt: now.subtract(const Duration(hours: 5)),
        tags: ['fashion', 'sneakers', 'nike', 'white'],
      ),

      Item(
        id: 'mock_24',
        userId: 'user_24',
        userEmail: 'user24@example.com',
        itemName: '아디다스 스탠스미스',
        category: 'Fashion',
        description: '그린 아디다스 스탠스미스 클래식',
        price: 95000.0, // ₩95,000
        currency: 'KRW',
        storeName: '아디다스 홍대점',
        address: '홍대 상권, 마포구',
        latitude: 37.5563,
        longitude: 126.9226,
        photoUrl: 'https://via.placeholder.com/300',
        submittedAt: now.subtract(const Duration(hours: 8)),
        updatedAt: now.subtract(const Duration(hours: 8)),
        tags: ['fashion', 'sneakers', 'adidas', 'green'],
      ),

      // Korea - Myeongdong District items
      Item(
        id: 'mock_25',
        userId: 'user_25',
        userEmail: 'user25@example.com',
        itemName: '스타벅스 그란데 라떼',
        category: 'Food & Beverages',
        description: '스타벅스 그란데 사이즈 라떼',
        price: 5500.0, // ₩5,500
        currency: 'KRW',
        storeName: '스타벅스 명동점',
        address: '명동역, 중구',
        latitude: 37.5636,
        longitude: 126.9826,
        photoUrl: 'https://via.placeholder.com/300',
        submittedAt: now.subtract(const Duration(hours: 2)),
        updatedAt: now.subtract(const Duration(hours: 2)),
        tags: ['food', 'coffee', 'starbucks', 'latte'],
      ),

      Item(
        id: 'mock_26',
        userId: 'user_26',
        userEmail: 'user26@example.com',
        itemName: '스타벅스 그란데 아메리카노',
        category: 'Food & Beverages',
        description: '스타벅스 그란데 사이즈 아메리카노',
        price: 4500.0, // ₩4,500
        currency: 'KRW',
        storeName: '스타벅스 명동점',
        address: '명동역, 중구',
        latitude: 37.5636,
        longitude: 126.9826,
        photoUrl: 'https://via.placeholder.com/300',
        submittedAt: now.subtract(const Duration(hours: 4)),
        updatedAt: now.subtract(const Duration(hours: 4)),
        tags: ['food', 'coffee', 'starbucks', 'americano'],
      ),

      // Korea - Itaewon District items
      Item(
        id: 'mock_27',
        userId: 'user_27',
        userEmail: 'user27@example.com',
        itemName: '라네즈 워터 슬리핑 마스크',
        category: 'Beauty & Health',
        description: '라네즈 워터 슬리핑 마스크 75ml',
        price: 25000.0, // ₩25,000
        currency: 'KRW',
        storeName: '올리브영 이태원점',
        address: '이태원역, 용산구',
        latitude: 37.5347,
        longitude: 126.9947,
        photoUrl: 'https://via.placeholder.com/300',
        submittedAt: now.subtract(const Duration(hours: 6)),
        updatedAt: now.subtract(const Duration(hours: 6)),
        tags: ['beauty', 'skincare', 'laneige', 'mask'],
      ),

      Item(
        id: 'mock_28',
        userId: 'user_28',
        userEmail: 'user28@example.com',
        itemName: '설화수 자음생크림',
        category: 'Beauty & Health',
        description: '설화수 자음생크림 60ml',
        price: 120000.0, // ₩120,000
        currency: 'KRW',
        storeName: '설화수 이태원점',
        address: '이태원 상권, 용산구',
        latitude: 37.5347,
        longitude: 126.9947,
        photoUrl: 'https://via.placeholder.com/300',
        submittedAt: now.subtract(const Duration(days: 1)),
        updatedAt: now.subtract(const Duration(days: 1)),
        tags: ['beauty', 'skincare', 'sulwhasoo', 'cream'],
      ),

      // China - Beijing items
      Item(
        id: 'mock_29',
        userId: 'user_29',
        userEmail: 'user29@example.com',
        itemName: 'iPhone 15 Pro',
        category: 'Electronics',
        description: 'iPhone 15 Pro 256GB in Natural Titanium',
        price: 8999.0, // ¥8,999
        currency: 'CNY',
        storeName: 'Apple Store 三里屯',
        address: '三里屯, 北京',
        latitude: 39.9378,
        longitude: 116.4471,
        photoUrl: 'https://via.placeholder.com/300',
        submittedAt: now.subtract(const Duration(hours: 7)),
        updatedAt: now.subtract(const Duration(hours: 7)),
        tags: ['electronics', 'iphone', 'apple', 'smartphone'],
      ),

      Item(
        id: 'mock_30',
        userId: 'user_30',
        userEmail: 'user30@example.com',
        itemName: '华为 Mate 60 Pro',
        category: 'Electronics',
        description: '华为 Mate 60 Pro 512GB 黑色',
        price: 6999.0, // ¥6,999
        currency: 'CNY',
        storeName: '华为体验店',
        address: '王府井, 北京',
        latitude: 39.9042,
        longitude: 116.4074,
        photoUrl: 'https://via.placeholder.com/300',
        submittedAt: now.subtract(const Duration(days: 2)),
        updatedAt: now.subtract(const Duration(days: 2)),
        tags: ['electronics', 'huawei', 'smartphone', 'android'],
      ),

      // China - Shanghai items
      Item(
        id: 'mock_31',
        userId: 'user_31',
        userEmail: 'user31@example.com',
        itemName: '星巴克大杯拿铁',
        category: 'Food & Beverages',
        description: '星巴克大杯拿铁咖啡',
        price: 35.0, // ¥35
        currency: 'CNY',
        storeName: '星巴克南京路店',
        address: '南京路, 上海',
        latitude: 31.2304,
        longitude: 121.4737,
        photoUrl: 'https://via.placeholder.com/300',
        submittedAt: now.subtract(const Duration(hours: 3)),
        updatedAt: now.subtract(const Duration(hours: 3)),
        tags: ['food', 'coffee', 'starbucks', 'latte'],
      ),

      // United States - New York items
      Item(
        id: 'mock_32',
        userId: 'user_32',
        userEmail: 'user32@example.com',
        itemName: 'iPhone 15 Pro Max',
        category: 'Electronics',
        description: 'iPhone 15 Pro Max 256GB in Natural Titanium',
        price: 1199.0, // $1,199
        currency: 'USD',
        storeName: 'Apple Store Fifth Avenue',
        address: '767 Fifth Avenue, New York',
        latitude: 40.7505,
        longitude: -73.9934,
        photoUrl: 'https://via.placeholder.com/300',
        submittedAt: now.subtract(const Duration(hours: 9)),
        updatedAt: now.subtract(const Duration(hours: 9)),
        tags: ['electronics', 'iphone', 'apple', 'smartphone'],
      ),

      Item(
        id: 'mock_33',
        userId: 'user_33',
        userEmail: 'user33@example.com',
        itemName: 'Starbucks Grande Latte',
        category: 'Food & Beverages',
        description: 'Starbucks Grande size latte',
        price: 5.95, // $5.95
        currency: 'USD',
        storeName: 'Starbucks Times Square',
        address: 'Times Square, New York',
        latitude: 40.7580,
        longitude: -73.9855,
        photoUrl: 'https://via.placeholder.com/300',
        submittedAt: now.subtract(const Duration(hours: 5)),
        updatedAt: now.subtract(const Duration(hours: 5)),
        tags: ['food', 'coffee', 'starbucks', 'latte'],
      ),

      // United States - Los Angeles items
      Item(
        id: 'mock_34',
        userId: 'user_34',
        userEmail: 'user34@example.com',
        itemName: 'Nike Air Jordan 1',
        category: 'Fashion',
        description: 'Nike Air Jordan 1 Retro High OG',
        price: 170.0, // $170
        currency: 'USD',
        storeName: 'Nike Store Beverly Center',
        address: 'Beverly Center, Los Angeles',
        latitude: 34.0736,
        longitude: -118.4004,
        photoUrl: 'https://via.placeholder.com/300',
        submittedAt: now.subtract(const Duration(days: 1)),
        updatedAt: now.subtract(const Duration(days: 1)),
        tags: ['fashion', 'sneakers', 'nike', 'jordan'],
      ),
    ];
  }
}