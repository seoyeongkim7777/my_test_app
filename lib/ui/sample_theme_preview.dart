import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'widgets/accent_button.dart';
import 'widgets/price_badge.dart';
import 'widgets/store_card.dart';

class SampleThemePreview extends StatelessWidget {
  const SampleThemePreview({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.lightTheme,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Local Price Lens - Theme Preview'),
          backgroundColor: Theme.of(context).colorScheme.surface,
          foregroundColor: Theme.of(context).colorScheme.onSurface,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              _buildHeaderSection(context),
              
              const SizedBox(height: 32),
              
              // Buttons Section
              _buildButtonsSection(context),
              
              const SizedBox(height: 32),
              
              // Price Badges Section
              _buildPriceBadgesSection(context),
              
              const SizedBox(height: 32),
              
              // Store Cards Section
              _buildStoreCardsSection(context),
              
              const SizedBox(height: 32),
              
              // Typography Section
              _buildTypographySection(context),
              
              const SizedBox(height: 32),
              
              // Form Elements Section
              _buildFormElementsSection(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.camera_alt,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Local Price Lens',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Discover the best prices for souvenirs and local items',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButtonsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Buttons',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 16),
        
        // Primary Buttons
        Row(
          children: [
            Expanded(
              child: AccentButton(
                text: 'Take Photo',
                icon: Icons.camera_alt,
                onPressed: () {},
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: AccentButton(
                text: 'Submit Item',
                icon: Icons.upload,
                onPressed: () {},
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Outlined Buttons
        Row(
          children: [
            Expanded(
              child: AccentButton(
                text: 'Browse Items',
                icon: Icons.search,
                onPressed: () {},
                isOutlined: true,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: AccentButton(
                text: 'Settings',
                icon: Icons.settings,
                onPressed: () {},
                isOutlined: true,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Loading Button
        SizedBox(
          width: double.infinity,
          child: AccentButton(
            text: 'Processing...',
            onPressed: () {},
            isLoading: true,
          ),
        ),
      ],
    );
  }

  Widget _buildPriceBadgesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Price Badges',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 16),
        
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            PriceBadge(
              localPrice: 25.99,
              localCurrency: 'USD',
              convertedPrice: 34.50,
              preferredCurrency: 'EUR',
              isPrimary: true,
            ),
            PriceBadge(
              localPrice: 1500,
              localCurrency: 'KRW',
              convertedPrice: 1.12,
              preferredCurrency: 'USD',
            ),
            PriceBadge(
              localPrice: 89.99,
              localCurrency: 'JPY',
              convertedPrice: 0.60,
              preferredCurrency: 'USD',
            ),
            PriceBadge(
              localPrice: 299,
              localCurrency: 'CNY',
              convertedPrice: 41.50,
              preferredCurrency: 'USD',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStoreCardsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Store Cards',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 16),
        
        StoreCard(
          title: 'Souvenir Shop - Gangnam',
          distanceKm: 0.8,
          priceLocal: 25.99,
          localCurrency: 'USD',
          priceConverted: 34.50,
          preferredCurrency: 'EUR',
          submittedAt: DateTime.now().subtract(const Duration(hours: 2)),
          onTap: () {},
          isHighlighted: true,
        ),
        
        StoreCard(
          title: 'Traditional Market - Myeongdong',
          distanceKm: 2.3,
          priceLocal: 1500,
          localCurrency: 'KRW',
          priceConverted: 1.12,
          preferredCurrency: 'USD',
          submittedAt: DateTime.now().subtract(const Duration(days: 1)),
          onTap: () {},
        ),
        
        StoreCard(
          title: 'Tourist Center - Hongdae',
          distanceKm: 3.7,
          priceLocal: 89.99,
          localCurrency: 'JPY',
          priceConverted: 0.60,
          preferredCurrency: 'USD',
          submittedAt: DateTime.now().subtract(const Duration(days: 3)),
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildTypographySection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Typography',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 16),
        
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Display Large - 32px Bold',
                  style: Theme.of(context).textTheme.displayLarge,
                ),
                const SizedBox(height: 16),
                Text(
                  'Display Medium - 28px Semi-Bold',
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                const SizedBox(height: 16),
                Text(
                  'Headline Large - 22px Semi-Bold',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: 16),
                Text(
                  'Title Large - 16px Semi-Bold',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                Text(
                  'Body Large - 16px Regular with comfortable line height for easy reading. This text demonstrates the body style used for main content.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
                Text(
                  'Label Large - 14px Medium',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormElementsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Form Elements',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 16),
        
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Item Name',
                    hintText: 'Enter the name of the item',
                    prefixIcon: Icon(Icons.shopping_bag),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Price',
                    hintText: '0.00',
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                  keyboardType: TextInputType.number,
                ),
                
                const SizedBox(height: 16),
                
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Currency',
                    prefixIcon: Icon(Icons.currency_exchange),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'USD', child: Text('USD')),
                    DropdownMenuItem(value: 'EUR', child: Text('EUR')),
                    DropdownMenuItem(value: 'KRW', child: Text('KRW')),
                    DropdownMenuItem(value: 'JPY', child: Text('JPY')),
                  ],
                  onChanged: (value) {},
                ),
                
                const SizedBox(height: 20),
                
                // Chips
                Wrap(
                  spacing: 8,
                  children: [
                    Chip(label: Text('Souvenirs')),
                    Chip(label: Text('Electronics')),
                    Chip(label: Text('Clothing')),
                    Chip(label: Text('Food')),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
