import 'package:flutter/material.dart';
import '../services/currency_service.dart';

class NearbyItemsPage extends StatefulWidget {
  const NearbyItemsPage({super.key});

  @override
  State<NearbyItemsPage> createState() => _NearbyItemsPageState();
}

class _NearbyItemsPageState extends State<NearbyItemsPage> {
  List<Map<String, dynamic>> _itemsWithPrices = [];
  bool _isLoading = true;
  String _errorMessage = '';
  final String _userPreferredCurrency = 'USD';

  @override
  void initState() {
    super.initState();
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

      // Mock nearby items data
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
          },
          'originalPrice': 25000.0,
          'originalCurrency': 'KRW',
          'convertedPrice': 18.75,
          'conversionError': false,
        },
      ];

      setState(() {
        _itemsWithPrices = mockItems;
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
        title: const Text('Nearby Items'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _loadNearbyItems,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _buildBody(),
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
