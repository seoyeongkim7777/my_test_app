import 'package:flutter/material.dart';
import '../models/item_model.dart';
import '../services/currency_service.dart';
import '../services/location_service.dart';

class StoreDetailPage extends StatefulWidget {
  final Item item;

  const StoreDetailPage({
    super.key,
    required this.item,
  });

  @override
  State<StoreDetailPage> createState() => _StoreDetailPageState();
}

class _StoreDetailPageState extends State<StoreDetailPage> {
  String _userCurrency = 'USD';
  double? _convertedPrice;
  bool _isLoadingPrice = true;
  String? _userAddress = 'Unknown location';

  @override
  void initState() {
    super.initState();
    _initializePage();
  }

  Future<void> _initializePage() async {
    try {
      // Get user's preferred currency (mock data)
      _userCurrency = 'USD';

      // Convert price to user's preferred currency
      if (_userCurrency != widget.item.currency) {
        try {
          _convertedPrice = await CurrencyService.convertPrice(
            widget.item.price,
            widget.item.currency,
            _userCurrency,
          );
        } catch (e) {
          // Conversion failed, keep original price
          _convertedPrice = widget.item.price;
        }
      } else {
        _convertedPrice = widget.item.price;
      }

      // Get user's current address for distance calculation
      try {
        final position = await LocationService.getCurrentLocation();
        if (position != null) {
          final address = await LocationService.getAddressFromLocation(
            position.latitude,
            position.longitude,
          );
          _userAddress = address;
        }
      } catch (e) {
        // Location failed, keep default
      }

      setState(() {
        _isLoadingPrice = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingPrice = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Store Details'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Item Image
            _buildItemImage(),
            
            // Item Details
            _buildItemDetails(),
            
            // Store Information
            _buildStoreInformation(),
            
            // Price Information
            _buildPriceInformation(),
            
            // Location Information
            _buildLocationInformation(),
            
            // Additional Details
            _buildAdditionalDetails(),
          ],
        ),
      ),
    );
  }

  Widget _buildItemImage() {
    return Container(
      width: double.infinity,
      height: 250,
      decoration: BoxDecoration(
        color: Colors.grey[200],
      ),
      child: widget.item.photoUrl.isNotEmpty
          ? Image.network(
              widget.item.photoUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.image_not_supported,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Image not available',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                );
              },
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.image,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No image available',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildItemDetails() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.item.itemName,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          if (widget.item.description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              widget.item.description,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[700],
              ),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  widget.item.category,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (widget.item.tags.isNotEmpty) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    widget.item.tags.first,
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStoreInformation() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.store,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Store Information',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Store Name', widget.item.storeName.isNotEmpty ? widget.item.storeName : 'Unknown Store'),
            if (widget.item.address.isNotEmpty) _buildInfoRow('Address', widget.item.address),
            _buildInfoRow('Submitted', _formatDate(widget.item.submittedAt)),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceInformation() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.attach_money,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Price Information',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_isLoadingPrice)
              const Center(child: CircularProgressIndicator())
            else ...[
              _buildInfoRow('Original Price', 
                CurrencyService.formatPrice(widget.item.price, widget.item.currency)),
              if (_convertedPrice != null && _userCurrency != widget.item.currency)
                _buildInfoRow('Price in $_userCurrency', 
                  CurrencyService.formatPrice(_convertedPrice!, _userCurrency)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLocationInformation() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Location Information',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Item Location', 
              '${widget.item.latitude.toStringAsFixed(4)}, ${widget.item.longitude.toStringAsFixed(4)}'),
            _buildInfoRow('Your Location', _userAddress ?? 'Unknown location'),
            _buildInfoRow('Distance', _calculateDistanceText()),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalDetails() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Additional Details',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Item ID', widget.item.id),
            _buildInfoRow('Submitted By', widget.item.userId),
            _buildInfoRow('Last Updated', _formatDate(widget.item.updatedAt)),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }

  String _calculateDistanceText() {
    try {
      // This would need to be calculated from the user's current location
      // For now, return a placeholder
      return 'Calculating...';
    } catch (e) {
      return 'Unable to calculate';
    }
  }
}
