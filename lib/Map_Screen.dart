import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:your_app_name/service.dart';

class AlexandriaMapScreen extends StatefulWidget {
  // Optional parameters for customization
  final String? title;
  final LatLng? initialLocation;
  final double? initialZoom;
  final bool showCurrentLocation;
  final List<Marker>? customMarkers;
  final ServiceItem? serviceItem; // Add this to receive service information

  const AlexandriaMapScreen({
    super.key,
    this.title,
    this.initialLocation,
    this.initialZoom,
    this.showCurrentLocation = true,
    this.customMarkers,
    this.serviceItem, // Add this parameter
  });

  @override
  State<AlexandriaMapScreen> createState() => _AlexandriaMapScreenState();
}

class _AlexandriaMapScreenState extends State<AlexandriaMapScreen> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final Location _location = Location();

  // Alexandria, Egypt coordinates
  static const LatLng _alexandriaCenter = LatLng(31.2001, 29.9187);

  LatLng? _currentLocation;
  bool _serviceEnabled = false;
  PermissionStatus? _permissionGranted;
  LocationData? _locationData;
  bool _isLoadingLocation = false;
  bool _isLocationTrackingActive = false;

  // Search functionality variables
  List<PlaceSearchResult> _searchResults = [];
  bool _isSearching = false;
  bool _showSearchResults = false;
  PlaceSearchResult? _selectedSearchResult;
  Marker? _searchMarker;

  // Pin selection variables
  LatLng? _selectedPinLocation;
  bool _isPinSelectionMode = false;
  String? _selectedLocationAddress;

  @override
  void initState() {
    super.initState();
    if (widget.showCurrentLocation) {
      _initializeLocation();
    }

    // Add listener to search controller
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    if (_searchController.text.isEmpty) {
      setState(() {
        _showSearchResults = false;
        _searchResults = [];
      });
    } else if (_searchController.text.length >= 3) {
      _searchPlaces(_searchController.text);
    }
  }

  Future<void> _searchPlaces(String query) async {
    if (query.isEmpty || query.length < 3) return;

    setState(() {
      _isSearching = true;
    });

    try {
      // Using Nominatim API for geocoding (free OpenStreetMap service)
      final String url = 'https://nominatim.openstreetmap.org/search?'
          'q=${Uri.encodeComponent(query)}&'
          'format=json&'
          'limit=5&'
          'addressdetails=1&'
          'bounded=1&'
          'accept-language=ar,en&'
          'viewbox=29.5,31.5,30.5,30.8'; // Bounding box around Alexandria area

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent': 'Alexandria Map App 1.0',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        setState(() {
          _searchResults = data.map((item) => PlaceSearchResult.fromJson(item)).toList();
          _showSearchResults = _searchResults.isNotEmpty;
        });
      } else {
        _showErrorSnackBar('Failed to search locations');
      }
    } catch (e) {
      print('Search error: $e');
      _showErrorSnackBar('Search failed. Please try again.');
    } finally {
      setState(() {
        _isSearching = false;
      });
    }
  }

  void _selectSearchResult(PlaceSearchResult result) {
    setState(() {
      _selectedSearchResult = result;
      _showSearchResults = false;
      _searchController.text = result.displayName;
    });

    _searchFocusNode.unfocus();

    // Show confirmation dialog for search result
    _showSearchResultConfirmationDialog(result);

    // Also navigate to and mark the search result on the map so those fields are actually used
    _navigateToSearchResult(result);
  }

  void _togglePinSelectionMode() {
    setState(() {
      _isPinSelectionMode = !_isPinSelectionMode;
      if (!_isPinSelectionMode) {
        _selectedPinLocation = null;
        _selectedLocationAddress = null;
      }
    });

    if (_isPinSelectionMode) {
      _showSuccessSnackBar('Tap anywhere on the map to select location');
    } else {
      _showSuccessSnackBar('Pin selection mode disabled');
    }
  }

  void _onMapTapped(TapPosition tapPosition, LatLng latLng) {
    if (_isPinSelectionMode) {
      setState(() {
        _selectedPinLocation = latLng;
      });
      _getAddressFromCoordinates(latLng);
    }
  }

  Future<void> _getAddressFromCoordinates(LatLng location) async {
    try {
      final String url = 'https://nominatim.openstreetmap.org/reverse?'
          'lat=${location.latitude}&'
          'lon=${location.longitude}&'
          'format=json&'
          'addressdetails=1&'
          'accept-language=ar,en';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent': 'Alexandria Map App 1.0',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _selectedLocationAddress = data['display_name'] ?? 'Unknown location';
        });
        _showPinLocationSelectedDialog();
      }
    } catch (e) {
      print('Reverse geocoding error: $e');
      setState(() {
        _selectedLocationAddress = 'Lat: ${location.latitude.toStringAsFixed(4)}, Lng: ${location.longitude.toStringAsFixed(4)}';
      });
      _showLocationSelectedDialog();
    }
  }

  // Updated method for pin location selection dialog
  void _showPinLocationSelectedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.place, color: Colors.red),
            SizedBox(width: 8),
            Text('Location Selected'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Selected location:'),
            const SizedBox(height: 8),
            Text(
              _selectedLocationAddress ?? 'Unknown location',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Text(
              'Coordinates: ${_selectedPinLocation!.latitude.toStringAsFixed(4)}, ${_selectedPinLocation!.longitude.toStringAsFixed(4)}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            if (widget.serviceItem != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(widget.serviceItem!.icon, color: widget.serviceItem!.color, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Service: ${widget.serviceItem!.title}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _selectedPinLocation = null;
                _selectedLocationAddress = null;
              });
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close this dialog first
              _confirmSelectedLocation(); // Then confirm and navigate back
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[800],
            ),
            child: const Text(
              'Confirm Location',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // New method for search result confirmation
  void _showSearchResultConfirmationDialog(PlaceSearchResult result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.search, color: Colors.blue),
            SizedBox(width: 8),
            Text('Location Found'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Found location:'),
            const SizedBox(height: 8),
            Text(
              result.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              result.address,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Coordinates: ${result.location.latitude.toStringAsFixed(4)}, ${result.location.longitude.toStringAsFixed(4)}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            if (widget.serviceItem != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(widget.serviceItem!.icon, color: widget.serviceItem!.color, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Service: ${widget.serviceItem!.title}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _clearSearchSelection();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog first
              _confirmSearchResult(result); // Then confirm and navigate back
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[800],
            ),
            child: const Text(
              'Confirm Location',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // New method for current location confirmation
  void _showCurrentLocationConfirmationDialog() {
    if (_currentLocation == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.my_location, color: Colors.blue),
            SizedBox(width: 8),
            Text('Current Location'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Use your current location:'),
            const SizedBox(height: 8),
            const Text(
              'Current Position',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Coordinates: ${_currentLocation!.latitude.toStringAsFixed(4)}, ${_currentLocation!.longitude.toStringAsFixed(4)}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            if (widget.serviceItem != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(widget.serviceItem!.icon, color: widget.serviceItem!.color, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Service: ${widget.serviceItem!.title}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog first
              _confirmCurrentLocation(); // Then confirm and navigate back
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[800],
            ),
            child: const Text(
              'Confirm Location',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // New method to confirm search result
  void _confirmSearchResult(PlaceSearchResult result) {
    // Show success message
    _showSuccessSnackBar('Location confirmed: ${result.name}');
    // Navigate back with search result data
    Navigator.pop(context, {
      'location': result.location,
      'address': result.displayName,
      'service': widget.serviceItem,
    });
  }

  // New method to confirm current location
  void _confirmCurrentLocation() {
    if (_currentLocation != null) {
      // Show success message
      _showSuccessSnackBar('Current location confirmed');
      // Navigate back with current location data
      Navigator.pop(context, {
        'location': _currentLocation,
        'address': 'Current Location',
        'service': widget.serviceItem,
      });
    }
  }
  void _showLocationSelectedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.place, color: Colors.red),
            SizedBox(width: 8),
            Text('Location Selected'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Selected location:'),
            const SizedBox(height: 8),
            Text(
              _selectedLocationAddress ?? 'Unknown location',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Text(
              'Coordinates: ${_selectedPinLocation!.latitude.toStringAsFixed(4)}, ${_selectedPinLocation!.longitude.toStringAsFixed(4)}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            if (widget.serviceItem != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(widget.serviceItem!.icon, color: widget.serviceItem!.color, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Service: ${widget.serviceItem!.title}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _selectedPinLocation = null;
                _selectedLocationAddress = null;
              });
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close this dialog first
              _confirmSelectedLocation(); // Then confirm and navigate back
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[800],
            ),
            child: const Text(
              'Confirm Location',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // Updated _confirmSelectedLocation method
  void _confirmSelectedLocation() {
    if (_selectedPinLocation != null) {
      // Show success message
      _showSuccessSnackBar('Location confirmed and marked on map');
      // Navigate back immediately with location data
      Navigator.pop(context, {
        'location': _selectedPinLocation,
        'address': _selectedLocationAddress,
        'service': widget.serviceItem,
      });
      // Reset selection state after navigation
      setState(() {
        _selectedPinLocation = null;
        _selectedLocationAddress = null;
        _isPinSelectionMode = false;
      });
    }
  }

  void _navigateToSearchResult(PlaceSearchResult result) {
    // Add search marker
    setState(() {
      _searchMarker = Marker(
        point: result.location,
        child: GestureDetector(
          onTap: () => _showMarkerInfo(result.name, result.displayName),
          child: const SizedBox(
            width: 40,
            height: 40,
            child: Icon(
              Icons.place,
              color: Colors.red,
              size: 40,
            ),
          ),
        ),
      );
    });

    // Move map to location
    _mapController.move(result.location, 16.0);
    _showSuccessSnackBar('Location found: ${result.name}');
  }

  void _clearSearchSelection() {
    setState(() {
      _selectedSearchResult = null;
      _searchMarker = null;
      _searchController.clear();
      _searchResults = [];
      _showSearchResults = false;
      _selectedPinLocation = null;
      _selectedLocationAddress = null;
    });
  }

  Future<void> _initializeLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      // Check if location service is enabled
      _serviceEnabled = await _location.serviceEnabled();
      if (!_serviceEnabled) {
        _serviceEnabled = await _location.requestService();
        if (!_serviceEnabled) {
          _showLocationServiceDialog();
          setState(() {
            _isLoadingLocation = false;
          });
          return;
        }
      }

      // Check for location permissions
      _permissionGranted = await _location.hasPermission();
      if (_permissionGranted == PermissionStatus.denied) {
        _permissionGranted = await _location.requestPermission();
        if (_permissionGranted != PermissionStatus.granted) {
          _showPermissionDialog();
          setState(() {
            _isLoadingLocation = false;
          });
          return;
        }
      }

      // Get current location
      await _getCurrentLocation();
    } catch (e) {
      print('Error initializing location: $e');
      _showErrorSnackBar('Failed to initialize location services');
    } finally {
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    if (!widget.showCurrentLocation) return;

    setState(() {
      _isLoadingLocation = true;
    });

    try {
      _locationData = await _location.getLocation();
      setState(() {
        _currentLocation = LatLng(
          _locationData!.latitude!,
          _locationData!.longitude!,
        );
      });

      _showSuccessSnackBar('Location updated successfully');

      // If user requested current location, show confirmation dialog
      if (_currentLocation != null) {
        _showCurrentLocationConfirmationDialog();
      }
    } catch (e) {
      print('Error getting location: $e');
      _showErrorSnackBar('Failed to get current location');
    } finally {
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  void _moveToCurrentLocation() {
    if (_currentLocation != null) {
      _mapController.move(_currentLocation!, 15.0);
      // Show confirmation dialog for current location
      _showCurrentLocationConfirmationDialog();
    } else {
      _getCurrentLocation();
    }
  }

  void _moveToAlexandria() {
    _mapController.move(_alexandriaCenter, 12.0);
  }

  void _toggleLocationTracking() {
    if (_isLocationTrackingActive) {
      _stopLocationTracking();
    } else {
      _startLocationTracking();
    }
  }

  void _startLocationTracking() {
    if (!widget.showCurrentLocation) return;

    setState(() {
      _isLocationTrackingActive = true;
    });

    _location.onLocationChanged.listen((LocationData currentLocation) {
      if (_isLocationTrackingActive) {
        setState(() {
          _currentLocation = LatLng(
            currentLocation.latitude!,
            currentLocation.longitude!,
          );
        });
      }
    });

    _showSuccessSnackBar('Live location tracking started');
  }

  void _stopLocationTracking() {
    setState(() {
      _isLocationTrackingActive = false;
    });
    _showSuccessSnackBar('Live location tracking stopped');
  }

  void _showLocationServiceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Location Service Required'),
        content: const Text('Please enable location services to use this feature.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Location Permission Required'),
        content: const Text('Please grant location permission to use this feature.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _initializeLocation();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  List<Marker> _buildMarkers() {
    List<Marker> markers = [];

    // Add current location marker
    if (widget.showCurrentLocation && _currentLocation != null) {
      markers.add(
        Marker(
          point: _currentLocation!,
          child: SizedBox(
            width: 50,
            height: 50,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.circle,
                  color: Colors.blue.withOpacity(0.3),
                  size: 50,
                ),
                const Icon(
                  Icons.my_location,
                  color: Colors.blue,
                  size: 30,
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Add pin selection marker (draggable pin)
    if (_selectedPinLocation != null) {
      markers.add(
        Marker(
          point: _selectedPinLocation!,
          child: GestureDetector(
            onTap: () => _showMarkerInfo(
                'Selected Location',
                _selectedLocationAddress ?? 'Custom selected location'
            ),
            child: SizedBox(
              width: 50,
              height: 50,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Shadow/base
                  Icon(
                    Icons.circle,
                    color: Colors.red.withOpacity(0.2),
                    size: 50,
                  ),
                  // Main pin
                  const Icon(
                    Icons.location_pin,
                    color: Colors.red,
                    size: 40,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // Add Alexandria landmark markers
    markers.addAll([
      // Citadel of Qaitbay
      Marker(
        point: const LatLng(31.2139, 29.8850),
        child: GestureDetector(
          onTap: () => _showMarkerInfo('Citadel of Qaitbay', 'Historic fortress'),
          child: const SizedBox(
            width: 40,
            height: 40,
            child: Icon(
              Icons.castle,
              color: Colors.brown,
              size: 40,
            ),
          ),
        ),
      ),

      // Library of Alexandria
      Marker(
        point: const LatLng(31.2084, 29.9097),
        child: GestureDetector(
          onTap: () => _showMarkerInfo('Library of Alexandria', 'Modern library and cultural center'),
          child: const SizedBox(
            width: 40,
            height: 40,
            child: Icon(
              Icons.local_library,
              color: Colors.purple,
              size: 40,
            ),
          ),
        ),
      ),

      // Alexandria Port
      Marker(
        point: const LatLng(31.2027, 29.8869),
        child: GestureDetector(
          onTap: () => _showMarkerInfo('Alexandria Port', 'Major Mediterranean port'),
          child: const SizedBox(
            width: 40,
            height: 40,
            child: Icon(
              Icons.directions_boat,
              color: Colors.blue,
              size: 40,
            ),
          ),
        ),
      ),

      // Montaza Palace
      Marker(
        point: const LatLng(31.2893, 30.0144),
        child: GestureDetector(
          onTap: () => _showMarkerInfo('Montaza Palace', 'Royal palace and gardens'),
          child: const SizedBox(
            width: 40,
            height: 40,
            child: Icon(
              Icons.account_balance,
              color: Colors.amber,
              size: 40,
            ),
          ),
        ),
      ),
    ]);

    // Add custom markers if provided
    if (widget.customMarkers != null) {
      markers.addAll(widget.customMarkers!);
    }

    // Add search marker if a search result was navigated to
    if (_searchMarker != null) {
      markers.add(_searchMarker!);
    }

    return markers;
  }

  void _showMarkerInfo(String title, String description) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(description),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              textDirection: TextDirection.ltr, // Allow both LTR and RTL
              decoration: InputDecoration(
                hintText: 'Search for places in Alexandria... / ابحث عن الأماكن في الإسكندرية...',
                prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: _clearSearchSelection,
                )
                    : _isSearching
                    ? Container(
                  width: 20,
                  height: 20,
                  padding: const EdgeInsets.all(12),
                  child: const CircularProgressIndicator(strokeWidth: 2),
                )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              ),
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  _searchPlaces(value);
                }
              },
            ),
          ),

          // Search results dropdown
          if (_showSearchResults && _searchResults.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              constraints: const BoxConstraints(maxHeight: 200),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final result = _searchResults[index];
                  return ListTile(
                    leading: const Icon(Icons.place, color: Colors.red),
                    title: Text(
                      result.name,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(
                      result.address,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () => _selectSearchResult(result),
                    dense: true,
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? 'Alexandria, Egypt'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          if (widget.showCurrentLocation)
            IconButton(
              icon: _isLoadingLocation
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
                  : const Icon(Icons.my_location),
              onPressed: _isLoadingLocation ? null : _getCurrentLocation,
              tooltip: 'Get Current Location',
            ),
          IconButton(
            icon: const Icon(Icons.location_city),
            onPressed: _moveToAlexandria,
            tooltip: 'Go to Alexandria',
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () {
          // Hide search results when tapping on map
          if (_showSearchResults) {
            setState(() {
              _showSearchResults = false;
            });
            _searchFocusNode.unfocus();
          }
        },
        child: Stack(
          children: [
            // Map
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: widget.initialLocation ?? _alexandriaCenter,
                initialZoom: widget.initialZoom ?? 12.0,
                minZoom: 3.0,
                maxZoom: 18.0,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all,
                ),
                onTap: _onMapTapped,
              ),
              children: [
                // Tile layer (OpenStreetMap)
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.alexandriamap.app',
                  maxZoom: 19,
                ),

                // Marker layer
                MarkerLayer(
                  markers: _buildMarkers(),
                ),

                // Accuracy circle for current location
                if (widget.showCurrentLocation &&
                    _currentLocation != null &&
                    _locationData?.accuracy != null)
                  CircleLayer(
                    circles: [
                      CircleMarker(
                        point: _currentLocation!,
                        radius: _locationData!.accuracy! / 2,
                        color: Colors.blue.withOpacity(0.1),
                        borderColor: Colors.blue.withOpacity(0.5),
                        borderStrokeWidth: 1.0,
                      ),
                    ],
                  ),
              ],
            ),

            // Search bar overlay
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _buildSearchBar(),
            ),

            // Small inline overlay to show selected search result (reads _selectedSearchResult)
            if (_selectedSearchResult != null)
              Positioned(
                top: 110,
                left: 16,
                right: 16,
                child: GestureDetector(
                  onTap: () => _showSearchResultConfirmationDialog(_selectedSearchResult!),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.place, color: Colors.red),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _selectedSearchResult!.name,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        TextButton(
                          onPressed: _clearSearchSelection,
                          child: const Text('Clear'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Pin selection mode overlay
            if (_isPinSelectionMode)
              Positioned(
                top: 100,
                left: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[800],
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.touch_app, color: Colors.white),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Tap anywhere on the map to select location',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: _togglePinSelectionMode,
                        child: const Text(
                          'Cancel',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Selected location info overlay
            if (_selectedPinLocation != null && _selectedLocationAddress != null)
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.place, color: Colors.red),
                          SizedBox(width: 8),
                          Text(
                            'Selected Location',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _selectedLocationAddress!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _selectedPinLocation = null;
                                  _selectedLocationAddress = null;
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[300],
                                foregroundColor: Colors.black,
                              ),
                              child: const Text('Clear'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _confirmSelectedLocation,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue[800],
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Confirm'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: widget.showCurrentLocation ? Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Pin selection button
          FloatingActionButton(
            heroTag: "pin_selection",
            onPressed: _togglePinSelectionMode,
            backgroundColor: _isPinSelectionMode ? Colors.red : Colors.purple,
            tooltip: _isPinSelectionMode ? 'Cancel Pin Selection' : 'Select Location with Pin',
            child: Icon(
              _isPinSelectionMode ? Icons.close : Icons.add_location,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),

          // Current location button
          FloatingActionButton(
            heroTag: "current_location",
            onPressed: _moveToCurrentLocation,
            backgroundColor: Colors.blue,
            tooltip: 'Go to Current Location',
            child: const Icon(Icons.my_location, color: Colors.white),
          ),
          const SizedBox(height: 10),

          // Location tracking toggle
          FloatingActionButton(
            heroTag: "location_tracking",
            onPressed: _toggleLocationTracking,
            backgroundColor: _isLocationTrackingActive ? Colors.red : Colors.green,
            tooltip: _isLocationTrackingActive ? 'Stop Tracking' : 'Start Tracking',
            child: Icon(
              _isLocationTrackingActive ? Icons.stop : Icons.track_changes,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),

          // Alexandria center button
          FloatingActionButton(
            heroTag: "alexandria_center",
            onPressed: _moveToAlexandria,
            backgroundColor: Colors.orange,
            tooltip: 'Go to Alexandria Center',
            child: const Icon(Icons.location_city, color: Colors.white),
          ),
        ],
      ) : Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Pin selection button
          FloatingActionButton(
            heroTag: "pin_selection",
            onPressed: _togglePinSelectionMode,
            backgroundColor: _isPinSelectionMode ? Colors.red : Colors.purple,
            tooltip: _isPinSelectionMode ? 'Cancel Pin Selection' : 'Select Location with Pin',
            child: Icon(
              _isPinSelectionMode ? Icons.close : Icons.add_location,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),

          // Alexandria center button
          FloatingActionButton(
            heroTag: "alexandria_center",
            onPressed: _moveToAlexandria,
            backgroundColor: Colors.orange,
            tooltip: 'Go to Alexandria Center',
            child: const Icon(Icons.location_city, color: Colors.white),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _stopLocationTracking();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }
}

// Model class for search results
class PlaceSearchResult {
  final String name;
  final String displayName;
  final String address;
  final LatLng location;
  final String? type;

  PlaceSearchResult({
    required this.name,
    required this.displayName,
    required this.address,
    required this.location,
    this.type,
  });

  factory PlaceSearchResult.fromJson(Map<String, dynamic> json) {
    return PlaceSearchResult(
      name: json['name'] ?? json['display_name']?.split(',')[0] ?? 'Unknown Location',
      displayName: json['display_name'] ?? 'Unknown Location',
      address: _extractAddress(json),
      location: LatLng(
        double.parse(json['lat']),
        double.parse(json['lon']),
      ),
      type: json['type'],
    );
  }

  static String _extractAddress(Map<String, dynamic> json) {
    if (json['address'] != null) {
      final address = json['address'];
      List<String> addressParts = [];

      if (address['road'] != null) addressParts.add(address['road']);
      if (address['neighbourhood'] != null) addressParts.add(address['neighbourhood']);
      if (address['suburb'] != null) addressParts.add(address['suburb']);
      if (address['city'] != null) addressParts.add(address['city']);

      return addressParts.join(', ');
    }

    // Fallback to display_name parts
    final displayParts = (json['display_name'] as String).split(',');
    return displayParts.length > 1
        ? displayParts.skip(1).take(2).join(',').trim()
        : '';
  }
}

// Helper class for navigation
class MapNavigation {
  static void navigateToMap(
      BuildContext context, {
        String? title,
        LatLng? initialLocation,
        double? initialZoom,
        bool showCurrentLocation = true,
        List<Marker>? customMarkers,
        ServiceItem? serviceItem, // Add this parameter
      }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AlexandriaMapScreen(
          title: title,
          initialLocation: initialLocation,
          initialZoom: initialZoom,
          showCurrentLocation: showCurrentLocation,
          customMarkers: customMarkers,
          serviceItem: serviceItem, // Pass the service item
        ),
      ),
    );
  }
}

