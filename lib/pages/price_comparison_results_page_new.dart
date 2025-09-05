import 'dart:io';
import 'package:flutter/material.dart';
import '../models/item_model.dart';
import '../services/item_service.dart';
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
  List<Map<String, dynamic>> _allNearbyStores = []; // All available stores
  List<Map<String, dynamic>> _displayedStores = []; // Currently displayed stores
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _error;
  double? _userLatitude;
  double? _userLongitude;
  String _userCurrency = 'USD';
  
  // Pagination settings
  static const int _initialStoresCount = 4;
  static const int _loadMoreStoresCount = 6;

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
        _allNearbyStores = stores;
        _nearbyStores = stores;
        // Show only the first few stores initially
        _displayedStores = stores.take(_initialStoresCount).toList();
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
        title: const Text('Price Comparison Results'),
        backgroundColor: const Color(0xFF00838F),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back),
        ),
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
          // Tourist-focused header
          _buildTouristHeader(),
          const SizedBox(height: 24),
          
          // Price Analysis Card
          _buildPriceAnalysisCard(),
          const SizedBox(height: 24),
          
          // Nearby Stores Section
          _buildNearbyStoresSection(),
        ],
      ),
    );
  }

  Widget _buildTouristHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF00838F).withValues(alpha:0.1),
            const Color(0xFF00838F).withValues(alpha:0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF00838F).withValues(alpha:0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.travel_explore,
                color: const Color(0xFF00838F),
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Smart Shopping for Tourists',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: const Color(0xFF00838F),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'We\'ve analyzed your item and found nearby stores with better prices. Save money while exploring!',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF00838F).withValues(alpha:0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Item: ${widget.submittedItem.itemName}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF00838F),
              ),
            ),
          ),
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
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[700],
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
                    confidence,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isFair ? Colors.green[700] : Colors.red[700],
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Nearby Stores with Similar Items',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${_displayedStores.length} of ${_allNearbyStores.length} found',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Grid layout with 2 items per row
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: _displayedStores.length,
          itemBuilder: (context, index) {
            final store = _displayedStores[index];
            final item = store['item'] as Item;
            final distanceText = store['distanceText'] as String;
            final convertedPrice = store['convertedPrice'] as double;
            final originalPrice = store['originalPrice'] as double;
            final originalCurrency = store['originalCurrency'] as String;

            return _buildStoreCard(
              item: item,
              distanceText: distanceText,
              convertedPrice: convertedPrice,
              originalPrice: originalPrice,
              originalCurrency: originalCurrency,
            );
          },
        ),
        // Load more stores button (only show if there are more stores to load)
        if (_displayedStores.length < _allNearbyStores.length) ...[
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isLoadingMore ? null : _loadMoreStores,
              icon: _isLoadingMore 
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.add),
              label: Text(_isLoadingMore ? 'Loading...' : 'Load More Stores'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00838F),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStoreCard({
    required Item item,
    required String distanceText,
    required double convertedPrice,
    required double originalPrice,
    required String originalCurrency,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _navigateToStoreDetail(item),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Item Image
              Expanded(
                flex: 3,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: item.photoUrl.isNotEmpty
                      ? Image.network(
                          item.photoUrl,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: double.infinity,
                              color: Colors.grey[300],
                              child: Icon(
                                Icons.store,
                                color: Colors.grey[600],
                                size: 32,
                              ),
                            );
                          },
                        )
                      : Container(
                          width: double.infinity,
                          color: Colors.grey[300],
                          child: Icon(
                            Icons.store,
                            color: Colors.grey[600],
                            size: 32,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 8),
              // Store Name
              Text(
                item.storeName,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              // Item Name
              Text(
                item.itemName,
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              // Location
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 12,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 2),
                  Expanded(
                    child: Text(
                      distanceText,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              // Price
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '\$${convertedPrice.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Colors.green[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '($originalCurrency ${originalPrice.toStringAsFixed(0)})',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _loadMoreStores() async {
    if (_isLoadingMore || _displayedStores.length >= _allNearbyStores.length) {
      return;
    }

    setState(() {
      _isLoadingMore = true;
    });

    // Simulate a small delay for better UX
    await Future.delayed(const Duration(milliseconds: 500));

    // Calculate how many more stores to show
    final currentCount = _displayedStores.length;
    final nextCount = (currentCount + _loadMoreStoresCount).clamp(0, _allNearbyStores.length);
    
    setState(() {
      _displayedStores = _allNearbyStores.take(nextCount).toList();
      _isLoadingMore = false;
    });

    // Show feedback to user
    if (mounted) {
      if (_displayedStores.length >= _allNearbyStores.length) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All stores loaded!'),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Loaded ${nextCount - currentCount} more stores'),
            duration: const Duration(seconds: 1),
          ),
        );
      }
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
