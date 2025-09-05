import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../services/ai_recognition_service.dart';
import '../services/location_service.dart';
import '../services/currency_service.dart';
import '../services/currency_mapping_service.dart';
import '../services/user_service.dart';
import '../services/language_service.dart';
import '../theme/app_theme.dart';
import '../models/item_model.dart';
import 'price_comparison_results_page.dart';

class ItemSubmissionPage extends StatefulWidget {
  const ItemSubmissionPage({super.key});

  @override
  State<ItemSubmissionPage> createState() => _ItemSubmissionPageState();
}

class _ItemSubmissionPageState extends State<ItemSubmissionPage> {
  final _imagePicker = ImagePicker();
  final _aiService = AIRecognitionService();
  final _languageService = LanguageService();
  late PageController _pageController;
  
  int _currentStep = 0;
  bool _isLoading = false;
  
  // Step 1: Photo
  XFile? _selectedImage;
  
  // Step 2: Auto-filled info (editable)
  String _itemName = '';
  String _category = '';
  String _storeName = '';
  String _address = '';
  
  // Step 3: Price
  final TextEditingController _priceController = TextEditingController();
  String _localCurrency = 'KRW'; // Currency based on location (default to KRW for Korea)
  String _userPreferredCurrency = 'USD'; // User's preferred currency
  double _convertedPrice = 0.0;
  bool _isLoadingCurrency = true; // Loading state for currency detection
  

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentStep);
    _loadUserPreferences();
    _loadLocationBasedCurrency();
    _priceController.addListener(_onPriceChanged);
  }

  @override
  void dispose() {
    _priceController.removeListener(_onPriceChanged);
    _priceController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadUserPreferences() async {
    // Load user's preferred currency from UserService
    final userService = UserService();
    String preferredCurrency = userService.selectedCurrency ?? 'USD';
    
    // If no currency is set, try to detect from user's home location
    if (preferredCurrency == 'USD') {
      try {
        // Get user's home currency (this could be from user preferences or device locale)
        // For now, we'll use a simple approach - in a real app, this would be more sophisticated
        preferredCurrency = await CurrencyMappingService.getUserHomeCurrency();
      } catch (e) {
        debugPrint('Error getting user home currency: $e');
        preferredCurrency = 'USD'; // Fallback to USD
      }
    }
    
    setState(() {
      _userPreferredCurrency = preferredCurrency;
    });
  }

  Future<void> _loadLocationBasedCurrency() async {
    try {
      // Get current location
      final locationDetails = await LocationService.getCurrentLocationWithDetails();
      final latitude = locationDetails['latitude'] as double;
      final longitude = locationDetails['longitude'] as double;
      
      // Get local currency based on location
      final localCurrency = await CurrencyMappingService.getLocalCurrencyFromCoordinates(latitude, longitude);
      
      if (mounted) {
        setState(() {
          _localCurrency = localCurrency;
          _isLoadingCurrency = false;
        });
        debugPrint('🌍 Location-based currency detected: $_localCurrency');
      }
    } catch (e) {
      debugPrint('Error loading location-based currency: $e');
      // Keep default currency (KRW for Korea) if location fails
      if (mounted) {
        setState(() {
          _localCurrency = 'KRW'; // Default to Korean Won for Korea
          _isLoadingCurrency = false;
        });
      }
    }
  }

  void _onPriceChanged() async {
    if (_priceController.text.isNotEmpty) {
      final price = double.tryParse(_priceController.text);
      if (price != null) {
        try {
          // Convert price to user's preferred currency
          _convertedPrice = await CurrencyService.convertPrice(
            price, 
            _localCurrency, 
            _userPreferredCurrency
          );
          setState(() {});
        } catch (e) {
          debugPrint('Failed to convert price: $e');
          // Set converted price to 0 if conversion fails
          _convertedPrice = 0.0;
          setState(() {});
        }
      }
    }
  }

  // Get price validation error message
  String? _getPriceValidationError(String priceText) {
    if (priceText.trim().isEmpty) {
      return _languageService.getLocalizedText('item_submission.price_required');
    }
    
    final price = double.tryParse(priceText.trim());
    if (price == null) {
      return _languageService.getLocalizedText('item_submission.price_invalid');
    }
    
    if (price <= 0) {
      return _languageService.getLocalizedText('item_submission.price_positive');
    }
    
    return null;
  }

  String _getCurrencySymbol(String currency) {
    return CurrencyMappingService.getCurrencySymbol(currency);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_languageService.getLocalizedText('item_submission.submit_item')),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Progress indicator
          Container(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                LinearProgressIndicator(
                  value: (_currentStep + 1) / 4,
                  backgroundColor: Colors.grey.shade300,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppTheme.lightTheme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _languageService.getLocalizedText('item_submission.step_of').replaceAll('{step}', '${_currentStep + 1}').replaceAll('{total}', '4'),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(), // Disable swiping
              onPageChanged: (index) {
                setState(() {
                  _currentStep = index;
                });
              },
              children: [
                _buildPhotoStep(),
                _buildInfoStep(),
                _buildPriceStep(),
                _buildSubmitStep(),
              ],
            ),
          ),
          
          // Navigation buttons
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                if (_currentStep > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _previousStep,
                      child: Text(_languageService.getLocalizedText('item_submission.previous')),
                    ),
                  ),
                if (_currentStep > 0) const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : (_currentStep == 3 ? _submitItem : _nextStep),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _currentStep == 3 
                        ? AppTheme.lightTheme.colorScheme.primary
                        : AppTheme.lightTheme.colorScheme.secondary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      _currentStep == 3 ? _languageService.getLocalizedText('item_submission.submit_item') : _languageService.getLocalizedText('item_submission.next'),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoStep() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
          Icon(
            Icons.camera_alt,
            size: 64,
            color: AppTheme.lightTheme.colorScheme.primary,
          ),
          const SizedBox(height: 24),
          Text(
            _languageService.getLocalizedText('item_submission.take_photo_title'),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            _languageService.getLocalizedText('item_submission.take_photo_description'),
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          
          if (_selectedImage != null) ...[
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _selectedImage!.path.contains('http')
                    ? Image.network(
                        _selectedImage!.path,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.image, size: 48, color: Colors.grey),
                          );
                        },
                      )
                    : Image.file(
                        File(_selectedImage!.path),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.image, size: 48, color: Colors.grey),
                          );
                        },
                      ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _languageService.getLocalizedText('item_submission.photo_captured'),
              style: TextStyle(
                color: Colors.green.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ] else ...[
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.camera_alt,
                    size: 48,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _languageService.getLocalizedText('item_submission.no_photo'),
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          const SizedBox(height: 32),
          
          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _takePhoto,
                  icon: const Icon(Icons.camera_alt),
                  label: Text(_languageService.getLocalizedText('item_submission.take_photo_button')),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickFromGallery,
                  icon: const Icon(Icons.photo_library),
                  label: Text(_languageService.getLocalizedText('item_submission.gallery')),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Test Dummy Image Button
          Center(
            child: OutlinedButton.icon(
              onPressed: _useDummyImage,
              icon: const Icon(Icons.image),
              label: const Text('🧪 Use Test Image (For Testing)'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                foregroundColor: Colors.orange,
                side: const BorderSide(color: Colors.orange),
              ),
            ),
          ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoStep() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          Icon(
            Icons.info_outline,
            size: 64,
            color: AppTheme.lightTheme.colorScheme.primary,
          ),
          const SizedBox(height: 24),
          Text(
            _languageService.getLocalizedText('item_submission.item_information'),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            _languageService.getLocalizedText('item_submission.review_edit'),
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          
          // Form fields
          TextFormField(
            initialValue: _itemName,
            decoration: InputDecoration(
              labelText: _languageService.getLocalizedText('item_submission.item_name_label'),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() {
                _itemName = value;
              });
            },
          ),
          const SizedBox(height: 16),
          
          TextFormField(
            initialValue: _category,
            decoration: InputDecoration(
              labelText: _languageService.getLocalizedText('item_submission.category_label'),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() {
                _category = value;
              });
            },
          ),
          const SizedBox(height: 16),
          
          TextFormField(
            initialValue: _storeName,
            decoration: InputDecoration(
              labelText: _languageService.getLocalizedText('item_submission.store_name'),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() {
                _storeName = value;
              });
            },
          ),
          const SizedBox(height: 16),
          
          TextFormField(
            initialValue: _address,
            decoration: InputDecoration(
              labelText: _languageService.getLocalizedText('item_submission.address'),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() {
                _address = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPriceStep() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          Icon(
            Icons.attach_money,
            size: 64,
            color: AppTheme.lightTheme.colorScheme.primary,
          ),
          const SizedBox(height: 24),
          Text(
            _languageService.getLocalizedText('item_submission.set_price'),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            _languageService.getLocalizedText('item_submission.price_description'),
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          
          // Currency detection status
          if (_isLoadingCurrency) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade700),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Detecting local currency based on your location...',
                    style: TextStyle(
                      color: Colors.blue.shade700,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          
          // Price input
          TextFormField(
            controller: _priceController,
            keyboardType: TextInputType.number,
            enabled: !_isLoadingCurrency,
            decoration: InputDecoration(
              labelText: 'Price in $_localCurrency (${CurrencyMappingService.getCurrencyName(_localCurrency)})',
              hintText: 'Enter the price you see in the store',
              prefixText: _getCurrencySymbol(_localCurrency),
              border: const OutlineInputBorder(),
              errorText: _priceController.text.isNotEmpty 
                ? _getPriceValidationError(_priceController.text)
                : null,
              errorStyle: const TextStyle(
                color: Colors.red,
                fontSize: 12,
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.red.shade600, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.red.shade400, width: 1),
              ),
            ),
          ),
          
          // Currency detection info
          if (!_isLoadingCurrency) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.location_on, color: Colors.green.shade700, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Enter the price you see in the store using ${_getCurrencySymbol(_localCurrency)} $_localCurrency (${CurrencyMappingService.getCurrencyName(_localCurrency)})',
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          // Currency conversion display
          if (_priceController.text.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.currency_exchange, color: Colors.blue.shade700),
                  const SizedBox(width: 8),
                  Text(
                    _convertedPrice > 0 
                      ? '≈ ${_getCurrencySymbol(_userPreferredCurrency)}${_convertedPrice.toStringAsFixed(2)} $_userPreferredCurrency'
                      : 'Conversion failed - check internet connection',
                    style: TextStyle(
                      color: _convertedPrice > 0 ? Colors.blue.shade700 : Colors.orange.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSubmitStep() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Icon(
              Icons.send,
              size: 64,
              color: AppTheme.lightTheme.colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              _languageService.getLocalizedText('item_submission.submit_item'),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              _languageService.getLocalizedText('item_submission.review_submission'),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            
            // Review Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_selectedImage != null) ...[
                      Container(
                        width: double.infinity,
                        height: 150,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: _selectedImage!.path.contains('http')
                              ? Image.network(
                                  _selectedImage!.path,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey.shade200,
                                      child: const Icon(Icons.image, size: 48, color: Colors.grey),
                                    );
                                  },
                                )
                              : Image.file(
                                  File(_selectedImage!.path),
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey.shade200,
                                      child: const Icon(Icons.image, size: 48, color: Colors.grey),
                                    );
                                  },
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    
                    _buildReviewRow(_languageService.getLocalizedText('item_submission.item_name_label'), _itemName),
                    _buildReviewRow(_languageService.getLocalizedText('item_submission.category_label'), _category),
                    _buildReviewRow(_languageService.getLocalizedText('item_submission.store_label'), _storeName),
                    _buildReviewRow(_languageService.getLocalizedText('item_submission.address_label'), _address),
                    _buildReviewRow(_languageService.getLocalizedText('item_submission.local_price'), '${_getCurrencySymbol(_localCurrency)}${_priceController.text} $_localCurrency'),
                    if (_localCurrency != _userPreferredCurrency)
                      _buildReviewRow(_languageService.getLocalizedText('item_submission.your_currency'), '${_getCurrencySymbol(_userPreferredCurrency)}${_convertedPrice.toStringAsFixed(2)} $_userPreferredCurrency'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      
      // Update PageView to show the previous step
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _nextStep() {
    if (_currentStep < 3) {
      // Validate current step
      if (_currentStep == 0 && _selectedImage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_languageService.getLocalizedText('item_submission.take_photo'))),
        );
        return;
      }
      
      if (_currentStep == 1 && _itemName.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_languageService.getLocalizedText('item_submission.enter_name'))),
        );
        return;
      }
      
      // Validate price input for step 2
      if (_currentStep == 2) {
        final priceError = _getPriceValidationError(_priceController.text);
        if (priceError != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(priceError),
              backgroundColor: Colors.red.shade600,
              duration: const Duration(seconds: 3),
            ),
          );
          return;
        }
      }
      
      setState(() {
        _currentStep++;
      });
      
      // Update PageView to show the next step
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _takePhoto() async {
    try {
      debugPrint('📸 Starting camera photo capture...');
      
      // Check current permission status
      var cameraStatus = await Permission.camera.status;
      debugPrint('📸 Camera permission status: $cameraStatus');
      
      // If permission is denied, show dialog
      if (cameraStatus == PermissionStatus.denied) {
        debugPrint('📸 Camera permission denied, showing dialog...');
        
        final shouldAllow = await _showPermissionDialog(
          _languageService.getLocalizedText('item_submission.camera_permission'),
          _languageService.getLocalizedText('item_submission.camera_permission_message'),
        );
        
        if (shouldAllow) {
          // User chose Allow, request permission
          cameraStatus = await Permission.camera.request();
          debugPrint('📸 Permission requested, new status: $cameraStatus');
        } else {
          // User chose Close, show message and return
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(_languageService.getLocalizedText('item_submission.camera_access_needed')),
                backgroundColor: Colors.orange,
                duration: Duration(seconds: 3),
              ),
            );
          }
          return;
        }
      }
      
      // If permission is permanently denied, show settings dialog
      if (cameraStatus == PermissionStatus.permanentlyDenied) {
        debugPrint('📸 Camera permission permanently denied');
        
        final shouldOpenSettings = await _showSettingsDialog(
          _languageService.getLocalizedText('item_submission.camera_permission_required'),
          _languageService.getLocalizedText('item_submission.camera_permission_denied'),
        );
        
        if (shouldOpenSettings) {
          await openAppSettings();
        }
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_languageService.getLocalizedText('item_submission.camera_access_needed')),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 3),
            ),
          );
        }
        return;
      }
      
      // If permission is granted, take photo
      if (cameraStatus == PermissionStatus.granted) {
        debugPrint('📸 Permission granted, opening camera...');
        
        final XFile? image = await _imagePicker.pickImage(
          source: ImageSource.camera,
          maxWidth: 1024,
          imageQuality: 80,
        );
        
        debugPrint('📸 Image picker result: ${image?.path ?? "null"}');
        
        if (image != null) {
          setState(() {
            _selectedImage = image;
          });
          _autoFillItemInfo();
        } else {
          debugPrint('📸 No image selected');
        }
      } else {
        debugPrint('📸 Camera permission still not granted: $cameraStatus');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_languageService.getLocalizedText('item_submission.camera_access_needed')),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('📸 Error taking photo: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_languageService.getLocalizedText('item_submission.error_taking_photo')}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      debugPrint('🖼️ Starting gallery photo selection...');
      
      // Check current permission status
      var photoStatus = await Permission.photos.status;
      debugPrint('🖼️ Photo permission status: $photoStatus');
      
      // If permission is denied, show dialog
      if (photoStatus == PermissionStatus.denied) {
        debugPrint('🖼️ Photo permission denied, showing dialog...');
        
        final shouldAllow = await _showPermissionDialog(
          _languageService.getLocalizedText('item_submission.photo_library_permission'),
          _languageService.getLocalizedText('item_submission.photo_library_permission_message'),
        );
        
        if (shouldAllow) {
          // User chose Allow, request permission
          photoStatus = await Permission.photos.request();
          debugPrint('🖼️ Permission requested, new status: $photoStatus');
        } else {
          // User chose Close, show message and return
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                content: Text(_languageService.getLocalizedText('item_submission.photo_library_access_needed')),
                backgroundColor: Colors.orange,
                duration: Duration(seconds: 3),
              ),
            );
          }
          return;
        }
      }
      
      // If permission is permanently denied, show settings dialog
      if (photoStatus == PermissionStatus.permanentlyDenied) {
        debugPrint('🖼️ Photo permission permanently denied');
        
        final shouldOpenSettings = await _showSettingsDialog(
          _languageService.getLocalizedText('item_submission.photo_library_permission_required'),
          _languageService.getLocalizedText('item_submission.photo_library_permission_denied'),
        );
        
        if (shouldOpenSettings) {
          await openAppSettings();
        }
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                content: Text(_languageService.getLocalizedText('item_submission.photo_library_access_needed')),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 3),
            ),
          );
        }
        return;
      }
      
      // If permission is granted, pick from gallery
      if (photoStatus == PermissionStatus.granted) {
        debugPrint('🖼️ Permission granted, opening gallery...');
        
        final XFile? image = await _imagePicker.pickImage(
          source: ImageSource.gallery,
          maxWidth: 1024,
          imageQuality: 80,
        );
        
        debugPrint('🖼️ Image picker result: ${image?.path ?? "null"}');
        
        if (image != null) {
          setState(() {
            _selectedImage = image;
          });
          _autoFillItemInfo();
        } else {
          debugPrint('🖼️ No image selected');
        }
      } else {
        debugPrint('🖼️ Photo permission still not granted: $photoStatus');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                content: Text(_languageService.getLocalizedText('item_submission.photo_library_access_needed')),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('🖼️ Error picking from gallery: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_languageService.getLocalizedText('item_submission.error_selecting_photo')}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<bool> _showPermissionDialog(String title, String message) async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(_languageService.getLocalizedText('item_submission.close')),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(_languageService.getLocalizedText('item_submission.allow')),
            ),
          ],
        );
      },
    ) ?? false;
  }

  Future<bool> _showSettingsDialog(String title, String message) async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(_languageService.getLocalizedText('item_submission.cancel')),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(_languageService.getLocalizedText('item_submission.open_settings')),
            ),
          ],
        );
      },
    ) ?? false;
  }


  void _useDummyImage() {
    // Create a dummy XFile for testing using a network URL
    // This simulates having an image without requiring camera/gallery access
    final dummyImage = XFile('https://via.placeholder.com/300x300/4CAF50/FFFFFF?text=Test+Image');
    
    setState(() {
      _selectedImage = dummyImage;
    });
    
    // Auto-fill information using AI
    _autoFillItemInfo();
    
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🧪 Test image loaded successfully!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _autoFillItemInfo() async {
    if (_selectedImage == null) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Check if it's a dummy image
      if (_selectedImage!.path.contains('via.placeholder.com')) {
        // Use dummy data for testing
        setState(() {
          _itemName = 'Test Product';
          _category = 'Electronics';
          _storeName = 'Test Store';
          _address = '123 Test Street, Test City';
        });
      } else {
        // Get current location for real images
        final position = await LocationService.getCurrentLocation();
        
        if (position != null) {
          // Mock AI recognition (replace with real AI service)
          final aiResult = await _aiService.recognizeItem(File(_selectedImage!.path));
          
          setState(() {
            _itemName = aiResult['itemName'] ?? '';
            _category = aiResult['category'] ?? '';
            _storeName = aiResult['storeName'] ?? '';
            _address = aiResult['address'] ?? '';
          });
        }
      }
    } catch (e) {
      // Fallback to default values
      setState(() {
        _itemName = 'Item';
        _category = 'General';
        _storeName = 'Store';
        _address = 'Location';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _submitItem() async {
    // Validate all required fields
    if (_selectedImage == null || _itemName.trim().isEmpty || _priceController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_languageService.getLocalizedText('item_submission.complete_fields'))),
      );
      return;
    }
    
    // Validate price format
    final priceError = _getPriceValidationError(_priceController.text);
    if (priceError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(priceError),
          backgroundColor: Colors.red.shade600,
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Get user data from UserService
      final userService = UserService();
      final userId = userService.username ?? 'anonymous_user';
      final userEmail = userService.email ?? 'anonymous@example.com';
      
      // Get current location
      double latitude = 0.0;
      double longitude = 0.0;
      try {
        final position = await LocationService.getCurrentLocation();
        if (position != null) {
          latitude = position.latitude;
          longitude = position.longitude;
        }
      } catch (e) {
        debugPrint('Warning: Could not get current location: $e');
        // Continue with default coordinates (0.0, 0.0)
      }
      
      // Create Item object from submitted data
      final submittedItem = Item(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        userEmail: userEmail,
        itemName: _itemName,
        category: _category,
        description: _itemName, // Use item name as description for now
        photoUrl: _selectedImage?.path ?? '',
        storeName: _storeName,
        address: _address,
        price: double.tryParse(_priceController.text) ?? 0.0,
        currency: _localCurrency,
        submittedAt: DateTime.now(),
        updatedAt: DateTime.now(),
        tags: [_category], // Use category as tag
        latitude: latitude,
        longitude: longitude,
      );
      
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));
      
      if (mounted) {
        // Navigate to price comparison results page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PriceComparisonResultsPage(
              submittedItem: submittedItem,
              photoFile: _selectedImage != null ? File(_selectedImage!.path) : null,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_languageService.getLocalizedText('item_submission.error_submitting')}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
