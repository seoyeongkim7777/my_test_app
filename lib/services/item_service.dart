import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/item_model.dart';
import '../services/currency_service.dart';

class ItemService {
  // Mock data storage (in production, this would be a real database)
  static final List<Item> _mockItems = [];

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
      
      // Price analysis logic
      final isFair = priceComparison <= 20.0;
      final confidence = convertedPrices.length >= 3 ? 'high' : 
                        convertedPrices.length >= 2 ? 'medium' : 'low';
      
      String message;
      String description;
      
      if (isFair) {
        if (priceComparison <= -15.0) {
          message = 'Excellent Deal!';
          description = 'This price is significantly below average - great value!';
        } else if (priceComparison <= -5.0) {
          message = 'Good Deal';
          description = 'This price is below average - good value!';
        } else {
          message = 'Fair Price';
          description = 'This price is reasonable compared to similar items';
        }
      } else {
        if (priceComparison >= 50.0) {
          message = 'Very High Price';
          description = 'This price is much higher than average - consider other options';
        } else {
          message = 'High Price';
          description = 'This price is above average - you might find better deals nearby';
        }
      }

      return {
        'isFair': isFair,
        'message': message,
        'description': description,
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
}