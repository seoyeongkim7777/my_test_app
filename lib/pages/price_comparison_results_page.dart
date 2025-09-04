import 'dart:io';
import 'package:flutter/material.dart';
import '../models/item_model.dart';
import '../services/item_service.dart';
import '../services/currency_service.dart';
import '../services/location_service.dart';
import 'store_detail_page.dart';

class PriceComparisonResultsPage extends StatefulWidget {
  final Item submittedItem;
  final File? photoFile;

  const PriceComparisonResultsPage({
    super.key,
    required this.submittedItem,
    this.photoFile,
  });

  @override
  State<PriceComparisonResultsPage> createState() => _PriceComparisonResultsPageState();
}

class _PriceComparisonResultsPageState extends State<PriceComparisonResultsPage> {
  final ItemService _itemService = ItemService();
  
  Map<String, dynamic>? _priceAnalysis;
  List<Map<String, dynamic>> _nearbyStores = [];
  bool _isLoading = true;
  String? _error;
  double? _userLatitude;
  double? _userLongitude;
  String _userCurrency = 'USD';

  @override
  void initState() {
    super.initState();
    _initializePage();
  }

  Future<void> _initializePage() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Get user's current location
      final position = await LocationService.getCurrentLocation();
      if (position != null) {
        _userLatitude = position.latitude;
      _userLongitude = position.longitude;
      }

      // Get user's preferred currency (mock data)
      _userCurrency = 'USD';

      // Analyze price fairness
      final analysis = await _itemService.analyzePriceFairness(widget.submittedItem);
      
      // Get nearby stores with similar items
      List<Map<String, dynamic>> stores = [];
      if (_userLatitude != null && _userLongitude != null) {
        stores = await _itemService.getNearbyStoresWithSimilarItems(
          widget.submittedItem.itemName,
          widget.submittedItem.category,
          _userLatitude!,
          _userLongitude!,
          _userCurrency,
        );
      }

      setState(() {
        _priceAnalysis = analysis;
        _nearbyStores = stores;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Price Analysis Results'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorWidget()
              : _buildResultsContent(),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Something went wrong',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            _error!,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _initializePage,
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsContent() {
    if (_priceAnalysis == null) {
      return const Center(child: Text('No analysis available'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Price Analysis Card
          _buildPriceAnalysisCard(),
          const SizedBox(height: 24),
          
          // Nearby Stores Section
          _buildNearbyStoresSection(),
        ],
      ),
    );
  }

  Widget _buildPriceAnalysisCard() {
    final analysis = _priceAnalysis!;
    final isFair = analysis['isFair'] as bool;
    final message = analysis['message'] as String;
    final description = analysis['description'] as String;
    final confidence = analysis['confidence'] as String;
    final similarItemsCount = analysis['similarItemsCount'] as int;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: isFair ? Colors.green[50] : Colors.red[50],
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isFair ? Colors.green[200]! : Colors.red[200]!,
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isFair ? Icons.check_circle : Icons.warning,
                  color: isFair ? Colors.green[600] : Colors.red[600],
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    message,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: isFair ? Colors.green[800] : Colors.red[800],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: isFair ? Colors.green[700] : Colors.red[700],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isFair ? Colors.green[100] : Colors.red[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Confidence: ${confidence.toUpperCase()}',
                    style: TextStyle(
                      color: isFair ? Colors.green[700] : Colors.red[700],
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  'Based on $similarItemsCount similar items',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNearbyStoresSection() {
    if (_nearbyStores.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(
                Icons.store_outlined,
                size: 48,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'No nearby stores found',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'We couldn\'t find any stores selling similar items in your area.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nearby Stores with Similar Items',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _nearbyStores.length,
          itemBuilder: (context, index) {
            final store = _nearbyStores[index];
            final item = store['item'] as Item;
            final distanceText = store['distanceText'] as String;
            final convertedPrice = store['convertedPrice'] as double;
            final originalPrice = store['originalPrice'] as double;
            final originalCurrency = store['originalCurrency'] as String;

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: () => _navigateToStoreDetail(item),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Store/Item Image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: item.photoUrl.isNotEmpty
                            ? Image.network(
                                item.photoUrl,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 60,
                                    height: 60,
                                    color: Colors.grey[300],
                                    child: Icon(
                                      Icons.store,
                                      color: Colors.grey[600],
                                    ),
                                  );
                                },
                              )
                            : Container(
                                width: 60,
                                height: 60,
                                color: Colors.grey[300],
                                child: Icon(
                                  Icons.store,
                                  color: Colors.grey[600],
                                ),
                              ),
                      ),
                      const SizedBox(width: 16),
                      
                      // Store/Item Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.storeName.isNotEmpty ? item.storeName : 'Unknown Store',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.itemName,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on_outlined,
                                  size: 16,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  distanceText,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      // Price Information
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            CurrencyService.formatPrice(convertedPrice, _userCurrency),
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          if (originalCurrency != _userCurrency)
                            Text(
                              CurrencyService.formatPrice(originalPrice, originalCurrency),
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                          const SizedBox(height: 4),
                          Text(
                            _formatDate(item.submittedAt),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  void _navigateToStoreDetail(Item item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StoreDetailPage(item: item),
      ),
    );
  }
}
