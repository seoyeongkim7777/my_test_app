import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../services/ai_recognition_service.dart';
import '../services/location_service.dart';
import '../services/currency_service.dart';
import '../theme/app_theme.dart';

class ItemSubmissionPage extends StatefulWidget {
  const ItemSubmissionPage({super.key});

  @override
  State<ItemSubmissionPage> createState() => _ItemSubmissionPageState();
}

class _ItemSubmissionPageState extends State<ItemSubmissionPage> {
  final _imagePicker = ImagePicker();
  final _aiService = AIRecognitionService();
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
  String _localCurrency = 'KRW'; // Currency based on location
  String _userPreferredCurrency = 'USD'; // User's preferred currency
  double _convertedPrice = 0.0;
  

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
    // Load user's preferred currency from LanguageService or user data
    // For now, using default values
    setState(() {
      _userPreferredCurrency = 'USD'; // This should come from user preferences
    });
  }

  Future<void> _loadLocationBasedCurrency() async {
    try {
      // Get current location and determine local currency
      final position = await LocationService.getCurrentLocation();
      if (position != null) {
        // Mock location-based currency detection
        // In real app, this would be based on country/region
        setState(() {
          _localCurrency = 'KRW'; // Default to Korean Won for Korea
        });
      }
    } catch (e) {
      // Use default currency if location fails
      setState(() {
        _localCurrency = 'KRW';
      });
    }
  }

  void _onPriceChanged() {
    if (_priceController.text.isNotEmpty) {
      _convertPrice();
    }
  }

  Future<void> _convertPrice() async {
    try {
      final price = double.tryParse(_priceController.text);
      if (price != null && _localCurrency != _userPreferredCurrency) {
        final converted = await CurrencyService.convertPrice(
          price, 
          _localCurrency, 
          _userPreferredCurrency
        );
        setState(() {
          _convertedPrice = converted;
        });
      }
    } catch (e) {
      // Handle conversion error
    }
  }

  String _getCurrencySymbol(String currency) {
    switch (currency) {
      case 'USD': return '\$';
      case 'KRW': return '₩';
      case 'EUR': return '€';
      case 'JPY': return '¥';
      case 'CNY': return '¥';
      case 'VND': return '₫';
      case 'THB': return '฿';
      default: return currency;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('See the Real Price'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Progress indicator
          Container(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                LinearProgressIndicator(
                  value: (_currentStep + 1) / 4, // 4 total steps
                  backgroundColor: Colors.grey.shade300,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppTheme.lightTheme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Step ${_currentStep + 1} of 4',
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
                      child: const Text('Previous'),
                    ),
                  ),
                if (_currentStep > 0) const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _nextStep,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _currentStep == 3 
                        ? AppTheme.lightTheme.colorScheme.primary
                        : AppTheme.lightTheme.colorScheme.secondary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      _currentStep == 3 ? 'Submit Item' : 'Next',
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
            'Take a Photo',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Take a photo of the item you want to price check',
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
              'Photo captured!',
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
                    'No photo yet',
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
          
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _takePhoto,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Take Photo'),
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
                  label: const Text('Gallery'),
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
            Icons.auto_awesome,
            size: 64,
            color: AppTheme.lightTheme.colorScheme.primary,
          ),
          const SizedBox(height: 24),
          Text(
            'Item Information',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'AI has detected the item details. You can edit them if needed.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Item Name
                  TextFormField(
                    initialValue: _itemName,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Item Name',
                      hintText: 'e.g., Traditional Korean Hanbok',
                    ),
                    onChanged: (value) {
                      _itemName = value;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Category
                  TextFormField(
                    initialValue: _category,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Category',
                      hintText: 'e.g., Clothing, Food, Electronics',
                    ),
                    onChanged: (value) {
                      _category = value;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Store Name
                  TextFormField(
                    initialValue: _storeName,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Store Name',
                      hintText: 'e.g., Heritage Market',
                    ),
                    onChanged: (value) {
                      _storeName = value;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Address
                  TextFormField(
                    initialValue: _address,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Store Address',
                      hintText: 'e.g., Busan, Jung-gu',
                    ),
                    onChanged: (value) {
                      _address = value;
                    },
                  ),
                ],
              ),
            ),
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
            'Enter Price',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Enter the price you found for this item',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          
          // Price Input with Local Currency
          TextFormField(
            controller: _priceController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelText: 'Price in $_localCurrency',
              hintText: 'e.g., 150000',
              prefixIcon: Text(
                _getCurrencySymbol(_localCurrency),
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              prefixIconConstraints: const BoxConstraints(minWidth: 50),
            ),
          ),
          const SizedBox(height: 16),
          
          // Show converted price if different from local currency
          if (_priceController.text.isNotEmpty && _localCurrency != _userPreferredCurrency) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.compare_arrows,
                    color: Colors.blue.shade600,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '≈ ${_getCurrencySymbol(_userPreferredCurrency)}${_convertedPrice.toStringAsFixed(2)} $_userPreferredCurrency',
                    style: TextStyle(
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          
          const Spacer(),
          
          // Price Preview
          if (_priceController.text.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.green.shade600,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Local Price: ${_getCurrencySymbol(_localCurrency)}${_priceController.text} $_localCurrency',
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  if (_localCurrency != _userPreferredCurrency) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Your Currency: ${_getCurrencySymbol(_userPreferredCurrency)}${_convertedPrice.toStringAsFixed(2)} $_userPreferredCurrency',
                      style: TextStyle(
                        color: Colors.green.shade600,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ],
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
              'Submit Item',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Review your submission and submit to help other travelers',
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
                    
                    _buildReviewRow('Item Name', _itemName),
                    _buildReviewRow('Category', _category),
                    _buildReviewRow('Store', _storeName),
                    _buildReviewRow('Address', _address),
                    _buildReviewRow('Local Price', '${_getCurrencySymbol(_localCurrency)}${_priceController.text} $_localCurrency'),
                    if (_localCurrency != _userPreferredCurrency)
                      _buildReviewRow('Your Currency', '${_getCurrencySymbol(_userPreferredCurrency)}${_convertedPrice.toStringAsFixed(2)} $_userPreferredCurrency'),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 32), // Fixed height instead of Spacer
            
            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _submitItem,
                icon: _isLoading 
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.send),
                label: Text(_isLoading ? 'Submitting...' : 'Submit Item'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.lightTheme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
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
              value.isEmpty ? 'Not specified' : value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
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
          const SnackBar(content: Text('Please take a photo first')),
        );
        return;
      }
      
      if (_currentStep == 1 && _itemName.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter an item name')),
        );
        return;
      }
      
      if (_currentStep == 2 && _priceController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a price')),
        );
        return;
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
      print('📸 Starting camera photo capture...');
      
      // Check current permission status
      var cameraStatus = await Permission.camera.status;
      print('📸 Camera permission status: $cameraStatus');
      
      // If permission is denied, show dialog
      if (cameraStatus == PermissionStatus.denied) {
        print('📸 Camera permission denied, showing dialog...');
        
        final shouldAllow = await _showPermissionDialog(
          'Camera Permission',
          'This app needs camera access to take photos of items. Would you like to allow camera access?',
        );
        
        if (shouldAllow) {
          // User chose Allow, request permission
          cameraStatus = await Permission.camera.request();
          print('📸 Permission requested, new status: $cameraStatus');
        } else {
          // User chose Close, show message and return
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Camera access is needed to take photos. You can use "Use Test Image" button for testing.'),
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
        print('📸 Camera permission permanently denied');
        
        final shouldOpenSettings = await _showSettingsDialog(
          'Camera Permission Required',
          'Camera access has been permanently denied. Please enable it in Settings to take photos.',
        );
        
        if (shouldOpenSettings) {
          await openAppSettings();
        }
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Camera access is needed to take photos. You can use "Use Test Image" button for testing.'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 3),
            ),
          );
        }
        return;
      }
      
      // If permission is granted, take photo
      if (cameraStatus == PermissionStatus.granted) {
        print('📸 Permission granted, opening camera...');
        
        final XFile? image = await _imagePicker.pickImage(
          source: ImageSource.camera,
          maxWidth: 1024,
          imageQuality: 80,
        );
        
        print('📸 Image picker result: ${image?.path ?? "null"}');
        
        if (image != null) {
          setState(() {
            _selectedImage = image;
          });
          
          print('📸 Image selected successfully: ${image.path}');
          
          // Auto-fill information using AI
          _autoFillItemInfo();
        } else {
          print('📸 No image selected (user cancelled)');
        }
      } else {
        print('📸 Camera permission still not granted: $cameraStatus');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Camera permission is required to take photos. Use "Use Test Image" button for testing.'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      print('📸 Error taking photo: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error taking photo: $e')),
        );
      }
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      print('🖼️ Starting gallery photo selection...');
      
      // Check current permission status
      var photoStatus = await Permission.photos.status;
      print('🖼️ Photo permission status: $photoStatus');
      
      // If permission is denied, show dialog
      if (photoStatus == PermissionStatus.denied) {
        print('🖼️ Photo permission denied, showing dialog...');
        
        final shouldAllow = await _showPermissionDialog(
          'Photo Library Permission',
          'This app needs access to your photo library to select photos. Would you like to allow photo library access?',
        );
        
        if (shouldAllow) {
          // User chose Allow, request permission
          photoStatus = await Permission.photos.request();
          print('🖼️ Permission requested, new status: $photoStatus');
        } else {
          // User chose Close, show message and return
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Photo library access is needed to select images. You can use "Use Test Image" button for testing.'),
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
        print('🖼️ Photo permission permanently denied');
        
        final shouldOpenSettings = await _showSettingsDialog(
          'Photo Library Permission Required',
          'Photo library access has been permanently denied. Please enable it in Settings to select photos.',
        );
        
        if (shouldOpenSettings) {
          await openAppSettings();
        }
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Photo library access is needed to select images. You can use "Use Test Image" button for testing.'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 3),
            ),
          );
        }
        return;
      }
      
      // If permission is granted, pick from gallery
      if (photoStatus == PermissionStatus.granted) {
        print('🖼️ Permission granted, opening gallery...');
        
        final XFile? image = await _imagePicker.pickImage(
          source: ImageSource.gallery,
          maxWidth: 1024,
          imageQuality: 80,
        );
        
        print('🖼️ Image picker result: ${image?.path ?? "null"}');
        
        if (image != null) {
          setState(() {
            _selectedImage = image;
          });
          
          print('🖼️ Image selected successfully: ${image.path}');
          
          // Auto-fill information using AI
          _autoFillItemInfo();
        } else {
          print('🖼️ No image selected (user cancelled)');
        }
      } else {
        print('🖼️ Photo permission still not granted: $photoStatus');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Photo library permission is required to select images. Use "Use Test Image" button for testing.'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      print('🖼️ Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
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
              child: const Text('Close'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Allow'),
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
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Open Settings'),
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
      // Use default values if AI fails
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
    if (_selectedImage == null || _itemName.trim().isEmpty || _priceController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all required fields')),
      );
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // TODO: Implement actual submission to Firebase
      // For now, just show success message
      
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Item submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Navigate to price comparison results
        Navigator.pushReplacementNamed(context, '/price-comparison');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting item: $e'),
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
