import 'package:flutter/material.dart';
import '../services/user_service.dart';
import '../services/language_service.dart';
import '../services/user_preferences_service.dart';
import '../theme/app_theme.dart';

class OnboardingPage extends StatefulWidget {
  final String userId;
  
  const OnboardingPage({super.key, required this.userId});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _userService = UserService();
  final _languageService = LanguageService();
  final _preferencesService = UserPreferencesService();
  late PageController _pageController;
  
  int _currentStep = 0;
  bool _isLoading = false;
  
  // Required fields
  String _selectedCurrency = 'USD';
  final TextEditingController _usernameController = TextEditingController();
  
  // Optional fields
  final List<String> _selectedInterests = [];
  String _selectedAgeGroup = '18-25';
  
  // Available options
  final List<String> _currencies = [
    'USD', 'KRW', 'CNY'
  ];
  
  final List<String> _interests = [
    'Fashion & Accessories', 'Electronics', 'Home & Living', 'Beauty & Health',
    'Sports & Outdoors', 'Books & Media', 'Art & Collectibles', 'Food & Beverages',
    'Travel Gear', 'Local Crafts', 'Antiques', 'Luxury Items'
  ];
  
  final List<String> _ageGroups = [
    'Under 18', '18-25', '26-35', '36-45', '46-55', '56-65', '65+'
  ];
  

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _loadExistingPreferences();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadExistingPreferences() async {
    // No Firebase - just use default values
    setState(() {
      _selectedCurrency = 'USD';
      _usernameController.text = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getLocalizedText('app.welcome')),
        centerTitle: true,
        automaticallyImplyLeading: false,
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
                  _getLocalizedText('onboarding.step_of').replaceAll('{step}', '${_currentStep + 1}').replaceAll('{total}', '4'),
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
                _buildCurrencyStep(),
                _buildUsernameStep(),
                _buildInterestsStep(),
                _buildAgeStep(),
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
                      child: Text(_getLocalizedText('common.previous')),
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
                      _currentStep == 3 ? _getLocalizedText('common.complete') : _getLocalizedText('common.next'),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Skip option for optional steps
          if (_currentStep >= 2) // Only show for optional steps
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Center(
                child: TextButton(
                  onPressed: _skipToComplete,
                  child: Text(_getLocalizedText('common.skip_optional')),
                ),
              ),
            ),
          
          // Test button to bypass Firebase (remove in production)
          Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: Center(
              child: OutlinedButton.icon(
                onPressed: () {
                  // Test mode - go directly to loading page
                  Navigator.pushReplacementNamed(context, '/loading');
                },
                icon: const Icon(Icons.flash_on),
                label: const Text('🧪 Test Mode (Skip Firebase)'),
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.orange.shade100,
                  foregroundColor: Colors.orange.shade800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildCurrencyStep() {
    return _buildStepContent(
      title: _getLocalizedText('onboarding.select_currency'),
      subtitle: _getLocalizedText('onboarding.currency_description'),
      icon: Icons.attach_money,
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            initialValue: _selectedCurrency,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              labelText: _getLocalizedText('onboarding.preferred_currency'),
            ),
            items: _currencies.map((String currency) {
              String currencyName = '';
              switch (currency) {
                case 'USD':
                  currencyName = 'USD - US Dollar';
                  break;
                case 'KRW':
                  currencyName = 'KRW - Korean Won';
                  break;
                case 'CNY':
                  currencyName = 'CNY - Chinese Yuan';
                  break;
                default:
                  currencyName = currency;
              }
              return DropdownMenuItem<String>(
                value: currency,
                child: Text(currencyName),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  _selectedCurrency = newValue;
                });
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildUsernameStep() {
    return _buildStepContent(
      title: _getLocalizedText('onboarding.choose_username'),
      subtitle: _getLocalizedText('onboarding.username_description'),
      icon: Icons.person,
      child: Column(
        children: [
          TextFormField(
            controller: _usernameController,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              labelText: _getLocalizedText('onboarding.username'),
              hintText: _getLocalizedText('onboarding.enter_username'),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return _getLocalizedText('onboarding.username_required');
              }
              if (value.trim().length < 3) {
                return _getLocalizedText('onboarding.username_min_length');
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInterestsStep() {
    return _buildStepContent(
      title: _getLocalizedText('onboarding.shopping_interests'),
      subtitle: _getLocalizedText('onboarding.interests_description'),
      icon: Icons.shopping_bag,
      child: Expanded(
        child: Column(
          children: [
            Text(
              _getLocalizedText('onboarding.interests_help'),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 3.0,
                ),
                itemCount: _interests.length,
                itemBuilder: (context, index) {
                  final interest = _interests[index];
                  final isSelected = _selectedInterests.contains(interest);
                  
                  return InkWell(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selectedInterests.remove(interest);
                        } else {
                          _selectedInterests.add(interest);
                        }
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isSelected 
                          ? AppTheme.lightTheme.colorScheme.primary
                          : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected 
                            ? AppTheme.lightTheme.colorScheme.primary
                            : Colors.grey.shade300,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          _getLocalizedText('interests.${interest.toLowerCase().replaceAll(' ', '_').replaceAll('&', '').replaceAll('-', '_')}'),
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            fontSize: 11,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAgeStep() {
    return _buildStepContent(
      title: _getLocalizedText('onboarding.age_group'),
      subtitle: _getLocalizedText('onboarding.age_description'),
      icon: Icons.person_outline,
      child: Column(
        children: [
          Text(
            _getLocalizedText('onboarding.age_help'),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          DropdownButtonFormField<String>(
            initialValue: _selectedAgeGroup,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              labelText: _getLocalizedText('onboarding.age_group'),
            ),
            items: _ageGroups.map((String ageGroup) {
              return DropdownMenuItem<String>(
                value: ageGroup,
                child: Text(_getLocalizedText('age_groups.${ageGroup.toLowerCase().replaceAll(' ', '_').replaceAll('-', '_').replaceAll('+', '_plus')}')),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  _selectedAgeGroup = newValue;
                });
              }
            },
          ),
        ],
      ),
    );
  }


  Widget _buildStepContent({
    required String title,
    required String subtitle,
    required IconData icon,
    required Widget child,
  }) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          Icon(
            icon,
            size: 64,
            color: AppTheme.lightTheme.colorScheme.primary,
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          child,
        ],
      ),
    );
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _nextStep() {
    if (_currentStep < 3) {
      // Validate required fields
      if (_currentStep == 1 && _usernameController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_getLocalizedText('onboarding.username_required'))),
        );
        return;
      }
      
      setState(() {
        _currentStep++;
      });
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _skipToComplete() async {
    // Save basic user data to UserService even when skipping
    _userService.setCurrency(_selectedCurrency);
    _userService.setUsername(_usernameController.text);
    
    // Save to preferences
    await _preferencesService.setUsername(_usernameController.text);
    await _preferencesService.setPreferredCurrency(_selectedCurrency);
    
    // Skip Firebase saving and go directly to loading page
    // This ensures the skip button always works
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/loading');
    }
  }


  // Localization function
  String _getLocalizedText(String text) {
    return _languageService.getLocalizedText(text);
  }


  Future<void> _completeOnboarding() async {
    setState(() {
      _isLoading = true;
    });

    // Save user data to UserService
    _userService.setCurrency(_selectedCurrency);
    _userService.setUsername(_usernameController.text);
    _userService.setInterests(_selectedInterests);
    _userService.setAgeGroup(_selectedAgeGroup);

    // Save to preferences
    await _preferencesService.setUsername(_usernameController.text);
    await _preferencesService.setPreferredCurrency(_selectedCurrency);

    // Simulate saving delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Navigate to loading page
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/loading');
    }
    
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // No Firebase - data is not saved
}
