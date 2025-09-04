import 'package:flutter/material.dart';
import '../services/language_service.dart';
import '../theme/app_theme.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _languageService = LanguageService();
  
  Map<String, dynamic>? _userData;
  List<Map<String, dynamic>> _userItems = [];
  bool _isLoading = true;
  
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
    // Simulate loading delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Mock user data
    setState(() {
      _userData = {
        'username': 'TestUser',
        'email': 'test@example.com',
        'preferredLanguage': 'English',
        'preferredCurrency': 'USD',
      };
      _selectedLanguage = 'English';
      _selectedCurrency = 'USD';
    });
    
    // Load user's posted items
    await _loadUserItems('test_user');
    
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadUserItems(String userId) async {
    try {
      // TODO: Implement loading user's posted items
      // For now, using mock data
      setState(() {
        _userItems = [
          {
            'id': '1',
            'name': 'Traditional Korean Hanbok',
            'price': 150000,
            'currency': 'KRW',
            'store': 'Gwangjang Market',
            'location': 'Seoul, Jongno-gu',
            'photoUrl': 'https://via.placeholder.com/150',
            'postedAt': DateTime.now().subtract(const Duration(days: 2)),
          },
          {
            'id': '2',
            'name': 'Local Ginseng Tea',
            'price': 25000,
            'currency': 'KRW',
            'store': 'Insadong Traditional Market',
            'location': 'Seoul, Jongno-gu',
            'photoUrl': 'https://via.placeholder.com/150',
            'postedAt': DateTime.now().subtract(const Duration(days: 5)),
          },
          {
            'id': '3',
            'name': 'Handcrafted Ceramic Bowl',
            'price': 45000,
            'currency': 'KRW',
            'store': 'Namdaemun Market',
            'location': 'Seoul, Jung-gu',
            'photoUrl': 'https://via.placeholder.com/150',
            'postedAt': DateTime.now().subtract(const Duration(days: 7)),
          },
        ];
      });
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _updatePreferences() async {
    // Simulate saving delay
    await Future.delayed(const Duration(seconds: 1));
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preferences updated successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _showSettings,
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
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
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatItem('Items Posted', _userItems.length.toString()),
                        _buildStatItem('Days Active', '7'),
                        _buildStatItem('Locations', '3'),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Temporary Test Button (Remove in production)
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _showSettings,
                        icon: const Icon(Icons.settings),
                        label: const Text('🧪 Test Settings'),
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
              'Your Posted Items',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Items you\'ve shared with the community',
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
                  'You haven\'t searched for local prices yet.',
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
                  'Settings',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Language Setting
                Text(
                  'Preferred Language',
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
                      // Update LanguageService to change app language globally
                      _languageService.changeLanguage(newValue);
                    }
                  },
                ),
                const SizedBox(height: 24),
                
                // Currency Setting
                Text(
                  'Preferred Currency',
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
                    child: const Text('Save Changes'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

