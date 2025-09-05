import 'package:flutter/material.dart';
import '../services/language_service.dart';
import '../services/user_preferences_service.dart';
import '../services/item_service.dart';
import '../services/user_service.dart';
import '../theme/app_theme.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _languageService = LanguageService();
  final _preferencesService = UserPreferencesService();
  final _itemService = ItemService();
  final _userService = UserService();
  
  Map<String, dynamic>? _userData;
  List<Map<String, dynamic>> _userItems = [];
  bool _isLoading = true;
  String? _errorMessage;
  
  String _selectedLanguage = 'English';
  String _selectedCurrency = 'USD';

  final List<String> _languages = [
    'English', 'Korean', 'Chinese'
  ];

  final List<String> _currencies = [
    'USD', 'KRW', 'CNY'
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    
    // Listen to language changes
    _languageService.addListener(_onLanguageChanged);
    
    // Initialize with current language from LanguageService
    _selectedLanguage = _languageService.currentLanguage;
  }

  @override
  void dispose() {
    _languageService.removeListener(_onLanguageChanged);
    super.dispose();
  }

  void _onLanguageChanged() {
    setState(() {
      // Update local language to match LanguageService
      _selectedLanguage = _languageService.currentLanguage;
    });
  }

  Future<void> _loadUserData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      
      // Load user preferences
      final preferences = await _preferencesService.getAllPreferences();
      
      // Get user data from UserService
      final username = _userService.username ?? preferences['username'] ?? 'TestUser';
      final email = _userService.email ?? preferences['email'] ?? 'test@example.com';
      
      setState(() {
        _userData = {
          'username': username,
          'email': email,
          'preferredLanguage': preferences['language'] ?? 'English',
          'preferredCurrency': preferences['currency'] ?? 'USD',
        };
        _selectedLanguage = preferences['language'] ?? 'English';
        _selectedCurrency = preferences['currency'] ?? 'USD';
      });
      
      // Load user's posted items using actual user ID
      await _loadUserItems(username);
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load user data: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadUserItems(String userId) async {
    try {
      // Get user's posted items from ItemService
      final items = await _itemService.getItemsByUser(userId);
      
      // Convert Item objects to Map format for display
      setState(() {
        _userItems = items.map((item) => {
          'id': item.id,
          'name': item.itemName,
          'price': item.price,
          'currency': item.currency,
          'store': item.storeName,
          'location': item.address,
          'photoUrl': item.photoUrl.isNotEmpty ? item.photoUrl : 'https://via.placeholder.com/150',
          'postedAt': item.submittedAt,
        }).toList();
      });
    } catch (e) {
      // If no items found or error, show empty list
      setState(() {
        _userItems = [];
      });
      debugPrint('Error loading user items: $e');
    }
  }

  Future<void> _updatePreferences() async {
    // Save language preference
    await _preferencesService.setPreferredLanguage(_selectedLanguage);
    
    // Update LanguageService to change app language globally
    _languageService.changeLanguage(_selectedLanguage);
    
    // Save currency preference
    await _preferencesService.setPreferredCurrency(_selectedCurrency);
    
    // Simulate saving delay
    await Future.delayed(const Duration(seconds: 1));
    
    if (mounted) {
      // Close the settings modal
      Navigator.of(context).pop();
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_languageService.getLocalizedText('profile.preferences_updated')),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
      
      // Refresh the profile page to show updated language
      setState(() {
        _selectedLanguage = _languageService.currentLanguage;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(_languageService.getLocalizedText('navigation.profile')),
          centerTitle: true,
        ),
        body: Center(
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
                _languageService.getLocalizedText('common.error'),
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadUserData,
                child: Text(_languageService.getLocalizedText('common.retry')),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_languageService.getLocalizedText('navigation.profile')),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _showSettings,
            icon: const Icon(Icons.settings),
            tooltip: _languageService.getLocalizedText('profile.settings'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Info Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    // Profile Picture
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: AppTheme.lightTheme.colorScheme.primary,
                      child: Text(
                        _userData?['username']?.substring(0, 1).toUpperCase() ?? 'U',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // User Name
                    Text(
                      _userData?['username'] ?? 'User',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // User Email
                    Text(
                      _userData?['email'] ?? 'user@example.com',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Stats Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildStatItem(_languageService.getLocalizedText('profile.items_posted'), _userItems.length.toString()),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Edit Profile Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _showEditProfile,
                        icon: const Icon(Icons.edit),
                        label: Text(_languageService.getLocalizedText('profile.edit_profile')),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.lightTheme.colorScheme.primary,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // Settings Button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _showSettings,
                        icon: const Icon(Icons.settings),
                        label: Text(_languageService.getLocalizedText('profile.settings')),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.blue.shade100,
                          foregroundColor: Colors.blue.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Posted Items Section
            Text(
              _languageService.getLocalizedText('profile.your_items'),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _languageService.getLocalizedText('profile.items_description'),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 16),
            
            if (_userItems.isEmpty)
              // Empty state - show plain text message
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(40.0),
                child: Text(
                  _languageService.getLocalizedText('profile.no_items'),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
              )
            else
              // Show user's posts in 2-column scrollable grid (same layout as homepage)
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.0, // Perfect square like homepage
                ),
                itemCount: _userItems.length,
                itemBuilder: (context, index) {
                  final item = _userItems[index];
                  return _buildItemCard(item);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.lightTheme.colorScheme.primary,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildItemCard(Map<String, dynamic> item) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Item Image
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                image: DecorationImage(
                  image: NetworkImage(item['photoUrl']),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          
          // Item Details
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'],
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${item['price'].toStringAsFixed(0)} ${item['currency']}',
                  style: TextStyle(
                    color: AppTheme.lightTheme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item['store'],
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  _formatDate(item['postedAt']),
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _showSettings() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildSettingsSheet(),
    );
  }

  Widget _buildSettingsSheet() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _languageService.getLocalizedText('profile.settings'),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Language Setting
                Text(
                  _languageService.getLocalizedText('profile.preferred_language'),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _selectedLanguage,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  items: _languages.map((String language) {
                    return DropdownMenuItem<String>(
                      value: language,
                      child: Text(language),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedLanguage = newValue;
                      });
                    }
                  },
                ),
                const SizedBox(height: 24),
                
                // Currency Setting
                Text(
                  _languageService.getLocalizedText('profile.preferred_currency'),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _selectedCurrency,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  items: _currencies.map((String currency) {
                    return DropdownMenuItem<String>(
                      value: currency,
                      child: Text(currency),
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
                
                const SizedBox(height: 32),
                
                // Save Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _updatePreferences,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(_languageService.getLocalizedText('profile.save_changes')),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showEditProfile() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildEditProfileSheet(),
    );
  }

  Widget _buildEditProfileSheet() {
    final TextEditingController usernameController = TextEditingController(text: _userData?['username'] ?? '');
    final TextEditingController emailController = TextEditingController(text: _userData?['email'] ?? '');

    return StatefulBuilder(
      builder: (context, setModalState) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _languageService.getLocalizedText('profile.edit_profile'),
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Profile Picture Section
                    Center(
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: AppTheme.lightTheme.colorScheme.primary,
                            child: Text(
                              (_userData?['username'] ?? 'U').substring(0, 1).toUpperCase(),
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _languageService.getLocalizedText('profile.profile_picture'),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Username Field
                    Text(
                      _languageService.getLocalizedText('profile.username'),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: usernameController,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        hintText: _languageService.getLocalizedText('profile.enter_username'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Email Field (Read-only)
                    Text(
                      _languageService.getLocalizedText('profile.email'),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: emailController,
                      enabled: false, // Make email field read-only
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        hintText: _languageService.getLocalizedText('profile.enter_email'),
                        filled: true,
                        fillColor: Colors.grey[100],
                        suffixIcon: Icon(
                          Icons.lock,
                          color: Colors.grey[600],
                          size: 20,
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _languageService.getLocalizedText('profile.email_readonly_note'),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _saveProfileChanges(
                          usernameController.text,
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(_languageService.getLocalizedText('profile.save_changes')),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _saveProfileChanges(String username) async {
    try {
      // Validate inputs
      if (username.trim().isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_languageService.getLocalizedText('profile.username_required')),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }
      
      // Update UserService (only username)
      _userService.setUsername(username.trim());
      
      // Update local state (only username)
      setState(() {
        _userData = {
          ..._userData!,
          'username': username.trim(),
          // Keep existing email unchanged
        };
      });
      
      // Save to preferences (only username)
      await _preferencesService.setUsername(username.trim());
      
      // Close the modal
      if (mounted) {
        Navigator.of(context).pop();
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_languageService.getLocalizedText('profile.profile_updated')),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_languageService.getLocalizedText('profile.error_updating')}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

