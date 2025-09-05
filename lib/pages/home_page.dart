import 'package:flutter/material.dart';
import '../services/language_service.dart';
import '../ui/widgets/location_overlay.dart';
import 'nearby_items_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _languageService = LanguageService();
  double _searchRadius = 1000.0; // in meters
  bool _showLocationOverlay = false;


  void _onRadiusChanged(double radius) {
    setState(() {
      _searchRadius = radius;
    });
  }

  String _formatDistance(double distanceInMeters) {
    if (distanceInMeters < 1000) {
      return '${distanceInMeters.round()}m';
    } else {
      final km = distanceInMeters / 1000;
      return '${km.toStringAsFixed(1)}km';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_languageService.getLocalizedText('navigation.home')),
        backgroundColor: const Color(0xFF00838F),
        foregroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            setState(() {
              _showLocationOverlay = !_showLocationOverlay;
            });
          },
          icon: Icon(
            _showLocationOverlay ? Icons.location_on : Icons.location_on_outlined,
            color: _showLocationOverlay ? Colors.yellow : Colors.white,
          ),
        ),
      ),
      body: Stack(
        children: [
          // Main content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.home,
                  size: 100,
                  color: const Color(0xFF00838F),
                ),
                const SizedBox(height: 20),
                Text(
                  _languageService.getLocalizedText('app.welcome'),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Text(
                  _languageService.getLocalizedText('app.tagline'),
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00838F).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_languageService.getLocalizedText('Search Radius')}: ${_formatDistance(_searchRadius)}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF00838F),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Location overlay
          if (_showLocationOverlay)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: LocationOverlay(
                onRadiusChanged: _onRadiusChanged,
                onClose: () {
                  setState(() {
                    _showLocationOverlay = false;
                  });
                },
                initialRadius: _searchRadius,
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF00838F),
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: _languageService.getLocalizedText('Home'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.camera_alt),
            label: _languageService.getLocalizedText('Camera'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.location_on),
            label: _languageService.getLocalizedText('Nearby'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: _languageService.getLocalizedText('Profile'),
          ),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              // Already on home page
              break;
            case 1:
              Navigator.pushNamed(context, '/submit-item');
              break;
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NearbyItemsPage(searchRadius: _searchRadius),
                ),
              );
              break;
            case 3:
              Navigator.pushNamed(context, '/profile');
              break;
          }
        },
      ),
    );
  }
}
