import 'package:flutter/material.dart';

class PriceBadge extends StatelessWidget {
  final double localPrice;
  final String localCurrency;
  final double? convertedPrice;
  final String? preferredCurrency;
  final bool isPrimary;
  final bool showConversion;

  const PriceBadge({
    super.key,
    required this.localPrice,
    required this.localCurrency,
    this.convertedPrice,
    this.preferredCurrency,
    this.isPrimary = false,
    this.showConversion = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isPrimary 
            ? theme.colorScheme.primary.withValues(alpha: 0.1)
            : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isPrimary 
              ? theme.colorScheme.primary.withValues(alpha: 0.3)
              : theme.colorScheme.outline,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Local Price (Primary)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _formatPrice(localPrice),
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isPrimary 
                      ? theme.colorScheme.primary 
                      : theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                localCurrency,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: isPrimary 
                      ? theme.colorScheme.primary 
                      : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          
          // Converted Price (Secondary)
          if (showConversion && convertedPrice != null && preferredCurrency != null) ...[
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatPrice(convertedPrice!),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  preferredCurrency!,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _formatPrice(double price) {
    // Format price with appropriate decimal places
    if (price == price.toInt()) {
      return price.toInt().toString();
    } else {
      return price.toStringAsFixed(2);
    }
  }
}
