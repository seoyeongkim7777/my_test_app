import 'package:flutter/material.dart';
import '../services/currency_service.dart';
import '../services/user_preferences_service.dart';
import '../services/language_service.dart';
import '../ui/widgets/location_overlay.dart';

class NearbyItemsPage extends StatefulWidget {
  final double searchRadius;
  
  const NearbyItemsPage({
    super.key,
    this.searchRadius = 1000.0,
  });

  @override
  State<NearbyItemsPage> createState() => _NearbyItemsPageState();
}

class _NearbyItemsPageState extends State<NearbyItemsPage> {
  final _preferencesService = UserPreferencesService();
  final _languageService = LanguageService();
  List<Map<String, dynamic>> _itemsWithPrices = [];
  bool _isLoading = true;
  String _errorMessage = '';
  String _userPreferredCurrency = 'USD';
  bool _showLocationOverlay = false;
  double _currentSearchRadius = 1000.0;

  String _formatDistance(double distanceInMeters) {
    if (distanceInMeters < 1000) {
      return '${distanceInMeters.round()}m';
    } else {
      final km = distanceInMeters / 1000;
      return '${km.toStringAsFixed(1)}km';
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserPreferences();
  }

  Future<void> _loadUserPreferences() async {
    _userPreferredCurrency = await _preferencesService.getPreferredCurrency();
    _currentSearchRadius = widget.searchRadius;
    _loadNearbyItems();
  }

  void _onRadiusChanged(double radius) {
    setState(() {
      _currentSearchRadius = radius;
    });
    _loadNearbyItems();
  }

  Future<void> _loadNearbyItems() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      // Simulate loading delay
      await Future.delayed(const Duration(seconds: 1));

      // Mock nearby items data with distance information
      final mockItems = [
        {
          'item': {
            'itemName': 'Traditional Korean Hanbok',
            'category': 'Clothing',
            'description': 'Beautiful traditional Korean dress',
            'photoUrl': 'https://via.placeholder.com/300',
            'storeName': 'Heritage Market',
            'address': 'Busan, Jung-gu',
            'submittedAt': DateTime.now().subtract(const Duration(hours: 2)),
            'distance': 500.0, // in meters
          },
          'originalPrice': 150000.0,
          'originalCurrency': 'KRW',
          'convertedPrice': 112.50,
          'conversionError': false,
        },
        {
          'item': {
            'itemName': 'Local Ginseng Tea',
            'category': 'Food & Beverages',
            'description': 'Premium Korean ginseng tea',
            'photoUrl': 'https://via.placeholder.com/300',
            'storeName': 'Traditional Goods Shop',
            'address': 'Busan, Haeundae-gu',
            'submittedAt': DateTime.now().subtract(const Duration(hours: 4)),
            'distance': 800.0, // in meters
          },
          'originalPrice': 25000.0,
          'originalCurrency': 'KRW',
          'convertedPrice': 18.75,
          'conversionError': false,
        },
        {
          'item': {
            'itemName': 'Korean Ceramic Bowl',
            'category': 'Home & Garden',
            'description': 'Handcrafted traditional ceramic bowl',
            'photoUrl': 'https://via.placeholder.com/300',
            'storeName': 'Artisan Pottery',
            'address': 'Busan, Saha-gu',
            'submittedAt': DateTime.now().subtract(const Duration(hours: 6)),
            'distance': 1200.0, // in meters
          },
          'originalPrice': 45000.0,
          'originalCurrency': 'KRW',
          'convertedPrice': 33.75,
          'conversionError': false,
        },
        {
          'item': {
            'itemName': 'Korean Traditional Shoes',
            'category': 'Clothing',
            'description': 'Comfortable traditional Korean shoes',
            'photoUrl': 'https://via.placeholder.com/300',
            'storeName': 'Cultural Footwear',
            'address': 'Busan, Dong-gu',
            'submittedAt': DateTime.now().subtract(const Duration(hours: 8)),
            'distance': 2000.0, // in meters
          },
          'originalPrice': 80000.0,
          'originalCurrency': 'KRW',
          'convertedPrice': 60.00,
          'conversionError': false,
        },
        {
          'item': {
            'itemName': 'Korean Rice Wine (Makgeolli)',
            'category': 'Food & Beverages',
            'description': 'Traditional Korean rice wine',
            'photoUrl': 'https://via.placeholder.com/300',
            'storeName': 'Local Liquor Store',
            'address': 'Busan, Nam-gu',
            'submittedAt': DateTime.now().subtract(const Duration(hours: 10)),
            'distance': 1500.0, // in meters
          },
          'originalPrice': 12000.0,
          'originalCurrency': 'KRW',
          'convertedPrice': 9.00,
          'conversionError': false,
        },
        {
          'item': {
            'itemName': 'Korean Traditional Fan',
            'category': 'Accessories',
            'description': 'Beautiful hand-painted traditional fan',
            'photoUrl': 'https://via.placeholder.com/300',
            'storeName': 'Cultural Arts Center',
            'address': 'Busan, Yeonje-gu',
            'submittedAt': DateTime.now().subtract(const Duration(hours: 12)),
            'distance': 1800.0, // in meters
          },
          'originalPrice': 35000.0,
          'originalCurrency': 'KRW',
          'convertedPrice': 26.25,
          'conversionError': false,
        },
        {
          'item': {
            'itemName': 'Korean Seaweed Snacks',
            'category': 'Food & Beverages',
            'description': 'Crispy roasted seaweed snacks',
            'photoUrl': 'https://via.placeholder.com/300',
            'storeName': 'Seafood Market',
            'address': 'Busan, Haeundae-gu',
            'submittedAt': DateTime.now().subtract(const Duration(hours: 14)),
            'distance': 2200.0, // in meters
          },
          'originalPrice': 8000.0,
          'originalCurrency': 'KRW',
          'convertedPrice': 6.00,
          'conversionError': false,
        },
        {
          'item': {
            'itemName': 'Korean Traditional Jewelry',
            'category': 'Accessories',
            'description': 'Elegant traditional Korean jewelry set',
            'photoUrl': 'https://via.placeholder.com/300',
            'storeName': 'Jewelry Boutique',
            'address': 'Busan, Seo-gu',
            'submittedAt': DateTime.now().subtract(const Duration(hours: 16)),
            'distance': 2500.0, // in meters
          },
          'originalPrice': 200000.0,
          'originalCurrency': 'KRW',
          'convertedPrice': 150.00,
          'conversionError': false,
        },
        {
          'item': {
            'itemName': 'Korean Green Tea',
            'category': 'Food & Beverages',
            'description': 'Premium Korean green tea leaves',
            'photoUrl': 'https://via.placeholder.com/300',
            'storeName': 'Tea House',
            'address': 'Busan, Busanjin-gu',
            'submittedAt': DateTime.now().subtract(const Duration(hours: 18)),
            'distance': 3000.0, // in meters
          },
          'originalPrice': 30000.0,
          'originalCurrency': 'KRW',
          'convertedPrice': 22.50,
          'conversionError': false,
        },
        {
          'item': {
            'itemName': 'Korean Traditional Mask',
            'category': 'Accessories',
            'description': 'Colorful traditional Korean mask',
            'photoUrl': 'https://via.placeholder.com/300',
            'storeName': 'Cultural Store',
            'address': 'Busan, Gangseo-gu',
            'submittedAt': DateTime.now().subtract(const Duration(hours: 20)),
            'distance': 3500.0, // in meters
          },
          'originalPrice': 25000.0,
          'originalCurrency': 'KRW',
          'convertedPrice': 18.75,
          'conversionError': false,
        },
      ];

      // Filter items based on search radius
      final filteredItems = mockItems.where((item) {
        final itemData = item['item'] as Map<String, dynamic>?;
        final distance = itemData?['distance'] as double?;
        return distance != null && distance <= _currentSearchRadius;
      }).toList();

      setState(() {
        _itemsWithPrices = filteredItems;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_languageService.getLocalizedText('navigation.nearby')),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _loadNearbyItems,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Search radius header (clickable)
              InkWell(
                onTap: () {
                  setState(() {
                    _showLocationOverlay = !_showLocationOverlay;
                  });
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00838F).withValues(alpha: 0.1),
                    border: Border(
                      bottom: BorderSide(
                        color: const Color(0xFF00838F).withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _showLocationOverlay ? Icons.location_on : Icons.location_on_outlined,
                        color: _showLocationOverlay ? Colors.yellow : const Color(0xFF00838F),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${_languageService.getLocalizedText('home.search_radius')}: ${_formatDistance(_currentSearchRadius)}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF00838F),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${_itemsWithPrices.length} items found',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        _showLocationOverlay ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                        color: const Color(0xFF00838F),
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
              // Items list
              Expanded(child: _buildBody()),
            ],
          ),
          
          // Location overlay
          if (_showLocationOverlay)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: LocationOverlay(
                onRadiusChanged: _onRadiusChanged,
                onClose: () {
                  setState(() {
                    _showLocationOverlay = false;
                  });
                },
                initialRadius: _currentSearchRadius,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading nearby items...'),
          ],
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading items',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadNearbyItems,
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (_itemsWithPrices.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.location_off,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              'No items found nearby',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Items submitted by other users will appear here',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/submit-item'),
              child: const Text('Submit First Item'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadNearbyItems,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _itemsWithPrices.length,
        itemBuilder: (context, index) {
          final itemData = _itemsWithPrices[index];
          final item = itemData['item'] as Map<String, dynamic>;
          final originalPrice = itemData['originalPrice'] as double;
          final originalCurrency = itemData['originalCurrency'] as String;
          final convertedPrice = itemData['convertedPrice'] as double;
          final conversionError = itemData['conversionError'] as bool? ?? false;

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Item Photo
                if (item['photoUrl'].isNotEmpty)
                  Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                      child: Image.network(
                        item['photoUrl'],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey.shade200,
                            child: const Center(
                              child: Icon(
                                Icons.image_not_supported,
                                size: 48,
                                color: Colors.grey,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Item Name and Category
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item['itemName'],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              item['category'],
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Description
                      if (item['description'].isNotEmpty) ...[
                        Text(
                          item['description'],
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],

                      // Price Information
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Original Price',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  CurrencyService.formatPrice(originalPrice, originalCurrency),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (!conversionError) ...[
                            const Icon(Icons.arrow_forward, color: Colors.grey),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'Your Currency ($_userPreferredCurrency)',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    CurrencyService.formatPrice(convertedPrice, _userPreferredCurrency),
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Store and Location
                      Row(
                        children: [
                          const Icon(Icons.store, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              item['storeName'].isNotEmpty ? item['storeName'] : 'Unknown Store',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              item['address'].isNotEmpty ? item['address'] : 'Location not specified',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Submitted Date
                      Row(
                        children: [
                          const Icon(Icons.access_time, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            'Submitted ${_formatDate(item['submittedAt'])}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }
}
