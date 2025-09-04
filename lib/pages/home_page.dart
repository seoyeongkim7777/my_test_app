import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/language_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final String _currentLocation = 'Busan, South Korea';
  double _searchRadius = 5.0; // km
  final LanguageService _languageService = LanguageService();
  
  // Mock data for posts - replace with real data later
  final List<Map<String, dynamic>> _posts = [
    {
      'id': '1',
      'title': 'Traditional Korean Hanbok',
      'price': 150000,
      'currency': 'KRW',
      'store': 'Heritage Market',
      'location': 'Busan, Jung-gu',
      'photoUrl': 'https://via.placeholder.com/300',
      'postedAt': DateTime.now().subtract(const Duration(hours: 2)),
      'distance': '0.5 km',
    },
    {
      'id': '2',
      'title': 'Local Ginseng Tea',
      'price': 25000,
      'currency': 'KRW',
      'store': 'Traditional Goods Shop',
      'location': 'Busan, Haeundae-gu',
      'photoUrl': 'https://via.placeholder.com/300',
      'postedAt': DateTime.now().subtract(const Duration(hours: 4)),
      'distance': '1.2 km',
    },
    {
      'id': '3',
      'title': 'Handcrafted Ceramic Bowl',
      'price': 45000,
      'currency': 'KRW',
      'store': 'Artisan Market',
      'location': 'Busan, Saha-gu',
      'photoUrl': 'https://via.placeholder.com/300',
      'postedAt': DateTime.now().subtract(const Duration(hours: 6)),
      'distance': '2.1 km',
    },
    {
      'id': '4',
      'title': 'Local Street Food Set',
      'price': 8000,
      'currency': 'KRW',
      'store': 'Local Food Market',
      'location': 'Busan, Dongnae-gu',
      'photoUrl': 'https://via.placeholder.com/300',
      'postedAt': DateTime.now().subtract(const Duration(hours: 8)),
      'distance': '3.5 km',
    },
    {
      'id': '5',
      'title': 'Traditional Korean Fan',
      'price': 35000,
      'currency': 'KRW',
      'store': 'Cultural Corner',
      'location': 'Busan, Yeongdo-gu',
      'photoUrl': 'https://via.placeholder.com/300',
      'postedAt': DateTime.now().subtract(const Duration(hours: 10)),
      'distance': '4.2 km',
    },
    {
      'id': '6',
      'title': 'Local Honey Jar',
      'price': 18000,
      'currency': 'KRW',
      'store': 'Organic Corner',
      'location': 'Busan, Geumjeong-gu',
      'photoUrl': 'https://via.placeholder.com/300',
      'postedAt': DateTime.now().subtract(const Duration(hours: 12)),
      'distance': '5.8 km',
    },
  ];

  @override
  void initState() {
    super.initState();
    // Sort posts by most recent
    _posts.sort((a, b) => b['postedAt'].compareTo(a['postedAt']));
    
    // Listen to language changes
    _languageService.addListener(_onLanguageChanged);
    
    // Request permissions after onboarding
    _requestPermissions();
  }

  @override
  void dispose() {
    _languageService.removeListener(_onLanguageChanged);
    super.dispose();
  }

  void _onLanguageChanged() {
    setState(() {
      // Rebuild UI when language changes
    });
  }

  Future<void> _requestPermissions() async {
    // Only request location permission on app start
    // Camera and photo permissions will be requested when user tries to use those features
    var locationStatus = await Permission.location.status;
    if (locationStatus != PermissionStatus.granted) {
      locationStatus = await Permission.location.request();
    }
    if (locationStatus != PermissionStatus.granted) {
      if (mounted) {
        final allow = await _showPermissionDialog('Location', 'Location permission is required to show nearby items');
        if (allow) {
          locationStatus = await Permission.location.request();
        } else {
          // User chose to cancel, show warning and ask again
          await _showRetryDialog('Location', 'Location access is necessary to show nearby items and stores. Without this permission, you cannot see location-based recommendations.');
        }
      }
    }
  }

  Future<bool> _showPermissionDialog(String permission, String message) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('$permission Permission Required'),
          content: Text('$message. Would you like to allow $permission access?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Allow'),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  Future<void> _showRetryDialog(String permission, String message) async {
    final retry = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('$permission Access Required'),
          content: Text('$message. Would you like to try again?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Try Again'),
            ),
          ],
        );
      },
    );
    
    if (retry == true) {
      // User wants to try again, recursively call the permission request
      await _requestPermissions();
    }
  }

  Future<void> _checkCameraPermission() async {
    // Check current permission status first
    var cameraStatus = await Permission.camera.status;
    
    // Only request if not already granted
    if (cameraStatus != PermissionStatus.granted) {
      cameraStatus = await Permission.camera.request();
    }
    
    // Navigate to submit item page regardless of permission status
    // The item submission page will handle permission checking
    if (mounted) {
      Navigator.pushNamed(context, '/submit-item');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_languageService.getLocalizedText('Local Price Lens')),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
            icon: const Icon(Icons.person),
            tooltip: _languageService.getLocalizedText('Profile'),
          ),
          IconButton(
            onPressed: _handleLogout,
            icon: const Icon(Icons.logout),
            tooltip: _languageService.getLocalizedText('Logout'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Location Bar
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                border: Border(
                  bottom: BorderSide(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
              ),
              child: InkWell(
                onTap: _showLocationMap,
                child: Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      color: Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _currentLocation,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Theme.of(context).colorScheme.primary,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
            
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: Colors.grey),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: _languageService.getLocalizedText('Search for items...'),
                            border: InputBorder.none,
                            hintStyle: const TextStyle(color: Colors.grey),
                          ),
                          onSubmitted: (value) {
                            // TODO: Implement search functionality
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('${_languageService.getLocalizedText('Searching for')}: $value')),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // Posts Section Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Text(
                    _languageService.getLocalizedText('Recent Posts Nearby'),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${_posts.length} ${_languageService.getLocalizedText('items')}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Posts Grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.0, // Perfect square
                ),
                itemCount: _posts.length,
                itemBuilder: (context, index) {
                  final post = _posts[index];
                  return _buildPostCard(post);
                },
              ),
            ),
            
            const SizedBox(height: 100), // Space for floating action button
            
            // Fixed Advertising Box at Bottom
            _buildAdvertisingBox(),
          ],
        ),
      ),
      // Floating Action Button - "See the Real Price"
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          // Check camera permission before navigating
          await _checkCameraPermission();
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.camera_alt),
        label: Text(
          _languageService.getLocalizedText('See the Real Price'),
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Future<void> _handleLogout() async {
    // Show logout confirmation
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_languageService.getLocalizedText('Logout')),
        content: Text(_languageService.getLocalizedText('Are you sure you want to logout?')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(_languageService.getLocalizedText('Cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(_languageService.getLocalizedText('Logout')),
          ),
        ],
      ),
    );
    
    if (shouldLogout == true && mounted) {
      // Import and use auth service to logout
      // For now, just navigate to login
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  Widget _buildPostCard(Map<String, dynamic> post) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Post Image (Square)
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                image: DecorationImage(
                  image: NetworkImage(post['photoUrl']),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          
          // Post Details
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  post['title'],
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: 4),
                
                // Price
                Text(
                  '${post['price'].toStringAsFixed(0)} ${post['currency']}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                
                const SizedBox(height: 4),
                
                // Store and location
                Text(
                  post['store'],
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                
                Text(
                  post['location'],
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: 4),
                
                // Distance and time
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      post['distance'],
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      _getTimeAgo(post['postedAt']),
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdvertisingBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        border: Border(
          top: BorderSide(
            color: Colors.blue.shade200,
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🚌 ${_languageService.getLocalizedText('Explore Nearby Cities')}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _languageService.getLocalizedText('Discover beautiful coastal destinations! Take the express bus from Busan to explore nearby cities. Journey times vary from 1-3 hours. Perfect for day trips to see famous landmarks, beautiful beaches, and local attractions.'),
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 12,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // TODO: Implement explore routes functionality
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(_languageService.getLocalizedText('Exploring routes...'))),
                    );
                  },
                  icon: const Icon(Icons.directions_bus, size: 16),
                  label: Text(
                    _languageService.getLocalizedText('Explore Routes'),
                    style: const TextStyle(fontSize: 12),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.blue.shade700,
                    side: BorderSide(color: Colors.blue.shade300),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Implement discover more functionality
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(_languageService.getLocalizedText('Discovering more...'))),
                    );
                  },
                  icon: const Icon(Icons.info_outline, size: 16),
                  label: Text(
                    _languageService.getLocalizedText('Discover More'),
                    style: const TextStyle(fontSize: 12),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getTimeAgo(DateTime postedAt) {
    final now = DateTime.now();
    final difference = now.difference(postedAt);
    
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

  void _showLocationMap() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildLocationMapSheet(),
    );
  }

  Widget _buildLocationMapSheet() {
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
                      _languageService.getLocalizedText('Set Search Radius'),
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _languageService.getLocalizedText('Adjust the area to search for nearby items and stores'),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Map placeholder
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.map,
                              size: 48,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _languageService.getLocalizedText('Map View'),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            Text(
                              _languageService.getLocalizedText('Interactive map with radius selection'),
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Radius slider
                    Row(
                      children: [
                        Text(
                          '${_languageService.getLocalizedText('Search Radius')}: ',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${_searchRadius.toStringAsFixed(1)} km',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    Slider(
                      value: _searchRadius,
                      min: 0.5,
                      max: 50.0,
                      divisions: 99,
                      activeColor: Theme.of(context).colorScheme.primary,
                      onChanged: (value) {
                        setModalState(() {
                          _searchRadius = value;
                        });
                      },
                    ),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _languageService.getLocalizedText('Few blocks'),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        Text(
                          _languageService.getLocalizedText('Whole city'),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Reset location button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // TODO: Implement reset location functionality
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(_languageService.getLocalizedText('Resetting to current location...'))),
                          );
                        },
                        icon: const Icon(Icons.my_location),
                        label: Text(_languageService.getLocalizedText('Reset to Current Location')),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: BorderSide(color: Theme.of(context).colorScheme.primary),
                          foregroundColor: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Apply button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          // TODO: Apply radius changes
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${_languageService.getLocalizedText('Search radius updated to')} ${_searchRadius.toStringAsFixed(1)} km'),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(_languageService.getLocalizedText('Apply Changes')),
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
}
