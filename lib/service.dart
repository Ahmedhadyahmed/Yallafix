import 'package:flutter/material.dart';
import 'dart:convert';

import 'Map_Screen.dart';
import 'activity_manager.dart'; // NEW IMPORT

class ServicesPage extends StatefulWidget {
  const ServicesPage({super.key});

  @override
  State<ServicesPage> createState() => _ServicesPageState();
}

class _ServicesPageState extends State<ServicesPage> {
  String selectedCategory = 'All';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Payment method state
  String _selectedPaymentMethod = 'cash'; // Default payment method

  // Constant data instead of API calls
  static const List<String> constantCategories = [
    'All',
    'Towing',
    'Maintenance',
    'Emergency',
    'Repair'
  ];

  static final List<Map<String, dynamic>> constantServices = [
    {
      'id': '1',
      'title': 'Tow Truck',
      'icon': 'local_shipping_rounded',
      'color': '#2196F3',
      'eta': '15-20 mins',
      'rating': 4.8,
      'price': 'EGP50-80',
      'isNew': false,
      'description': 'Professional towing service',
      'category': 'Towing'
    },
    {
      'id': '2',
      'title': 'Mechanic',
      'icon': 'build_rounded',
      'color': '#FF5722',
      'eta': '20-30 mins',
      'rating': 4.7,
      'price': 'EGP60-100',
      'isNew': true,
      'description': 'Expert mechanical repairs',
      'category': 'Repair'
    },
    {
      'id': '3',
      'title': 'Oil Change',
      'icon': 'settings_rounded',
      'color': '#4CAF50',
      'eta': '25-35 mins',
      'rating': 4.9,
      'price': 'EGP30-50',
      'isNew': false,
      'description': 'Quick oil change service',
      'category': 'Maintenance'
    },
    {
      'id': '4',
      'title': 'Battery Jump',
      'icon': 'battery_charging_full_rounded',
      'color': '#FFC107',
      'eta': '10-15 mins',
      'rating': 4.6,
      'price': 'EGP25-40',
      'isNew': false,
      'description': 'Emergency battery jump start',
      'category': 'Emergency'
    },
    {
      'id': '5',
      'title': 'Tire Change',
      'icon': 'tire_repair_rounded',
      'color': '#9C27B0',
      'eta': '15-25 mins',
      'rating': 4.8,
      'price': 'EGP35-60',
      'isNew': true,
      'description': 'Flat tire replacement',
      'category': 'Emergency'
    },
    {
      'id': '6',
      'title': 'Fuel Delivery',
      'icon': 'local_gas_station_rounded',
      'color': '#FF9800',
      'eta': '20-30 mins',
      'rating': 4.7,
      'price': 'EGP20-35',
      'isNew': false,
      'description': 'Emergency fuel delivery',
      'category': 'Emergency'
    },
    {
      'id': '7',
      'title': 'Diagnostic',
      'icon': 'search_rounded',
      'color': '#00BCD4',
      'eta': '30-45 mins',
      'rating': 4.9,
      'price': 'EGP40-70',
      'isNew': false,
      'description': 'Complete vehicle diagnostic',
      'category': 'Maintenance'
    },
    {
      'id': '8',
      'title': 'Lockout Service',
      'icon': 'key_rounded',
      'color': '#E91E63',
      'eta': '15-20 mins',
      'rating': 4.5,
      'price': 'EGP30-50',
      'isNew': true,
      'description': 'Car lockout assistance',
      'category': 'Emergency'
    },
  ];

  // State management for data
  List<String> categories = [];
  List<ServiceItem> allServices = [];
  bool isLoading = false;
  String? errorMessage;

  List<ServiceItem> get filteredServices {
    List<ServiceItem> filtered = allServices;

    // Apply category filter
    if (selectedCategory != 'All') {
      filtered = filtered.where((service) => service.category == selectedCategory).toList();
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((service) =>
      service.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          service.description.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    return filtered;
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
    _loadData();
  }

  // Load data from constants
  Future<void> _loadData() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      // Simulate a small delay to show loading state
      await Future.delayed(const Duration(milliseconds: 500));

      // Load constant data
      categories = List.from(constantCategories);
      allServices = constantServices.map((json) => ServiceItem.fromJson(json)).toList();

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load data: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  // Navigate to map screen for service booking
  void _navigateToMapForService(ServiceItem service) async {
    print('Navigating to map for service: ${service.title}'); // Debug log

    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => AlexandriaMapScreen(
          title: '${service.title} - Alexandria',
          showCurrentLocation: true,
          serviceItem: service, // Pass the service item to the map
        ),
      ),
    );

    print('Navigation result: $result'); // Debug log

    // Handle the returned data from map screen
    if (result != null && result['location'] != null) {
      final selectedLocation = result['location'];
      final selectedAddress = result['address'];

      print('Location selected: $selectedAddress'); // Debug log

      // Add a small delay to ensure the dialog shows properly after navigation
      await Future.delayed(const Duration(milliseconds: 500));

      // Show booking confirmation dialog with location details
      if (mounted) {
        print('Showing booking confirmation dialog'); // Debug log
        _showBookingConfirmationDialog(service, selectedLocation, selectedAddress);
      }
    } else {
      print('No location data received from map'); // Debug log
    }
  }

  // Show booking confirmation with location details and payment method selection
  void _showBookingConfirmationDialog(ServiceItem service, dynamic location, String? address) {
    // Reset payment method selection for new booking
    _selectedPaymentMethod = 'cash';

    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing by tapping outside
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.check_circle_outline,
                color: Colors.green,
                size: 28,
              ),
              SizedBox(width: 12),
              Text(
                'Confirm Service Booking',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Service info
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: service.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          service.icon,
                          color: service.color,
                          size: 24,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              service.title,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Price: ${service.price}',
                              style: TextStyle(
                                color: Color(0xFFFF8C00),
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              'ETA: ${service.eta}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),

                // Location info
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.place, color: Colors.red, size: 24),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Service Location:',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              address ?? 'Selected location on map',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[700],
                                height: 1.3,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),

                // Payment method selection
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.payment, color: Colors.orange[700], size: 24),
                          SizedBox(width: 8),
                          Text(
                            'Payment Method',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),

                      // Cash payment option
                      _buildPaymentOption(
                        value: 'cash',
                        title: 'Cash',
                        subtitle: 'Pay with cash on service completion',
                        icon: Icons.money,
                        color: Colors.green,
                        setDialogState: setDialogState,
                      ),
                      SizedBox(height: 8),

                      // Saved card option
                      _buildPaymentOption(
                        value: 'card',
                        title: 'Saved Card',
                        subtitle: 'Pay with saved card ending in ****1234',
                        icon: Icons.credit_card,
                        color: Colors.blue,
                        setDialogState: setDialogState,
                      ),
                      SizedBox(height: 8),

                      // Fawry option
                      _buildPaymentOption(
                        value: 'fawry',
                        title: 'Fawry',
                        subtitle: 'Pay using Fawry wallet',
                        icon: Icons.account_balance_wallet,
                        color: Colors.purple,
                        setDialogState: setDialogState,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),

                // Confirmation message
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.green[700], size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Please confirm your service booking and payment details.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.green[800],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _processBooking(service, address, _selectedPaymentMethod);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF8C00),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Confirm Booking',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget to build payment option tiles
  Widget _buildPaymentOption({
    required String value,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required StateSetter setDialogState,
  }) {
    return GestureDetector(
      onTap: () {
        setDialogState(() {
          _selectedPaymentMethod = value;
        });
      },
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _selectedPaymentMethod == value
              ? color.withOpacity(0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _selectedPaymentMethod == value
                ? color
                : Colors.grey[300]!,
            width: _selectedPaymentMethod == value ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                icon,
                color: color,
                size: 20,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Radio<String>(
              value: value,
              groupValue: _selectedPaymentMethod,
              onChanged: (String? newValue) {
                setDialogState(() {
                  _selectedPaymentMethod = newValue!;
                });
              },
              activeColor: color,
            ),
          ],
        ),
      ),
    );
  }

  // Process the final booking with payment method
  void _processBooking(ServiceItem service, String? location, String paymentMethod) {
    String paymentMethodText = _getPaymentMethodDisplayText(paymentMethod);

    // Create new activity from the booking
    final activityManager = ActivityManager();
    final newActivity = ActivityItemData(
      id: activityManager.generateId(),
      serviceName: service.title,
      date: _formatBookingDate(),
      status: ActivityStatus.upcoming,
      price: service.price,
      rating: null,
      description: service.description,
      serviceProvider: 'Quick Service Pro', // You can customize this
      comments: null,
      location: location,
      paymentMethod: paymentMethodText,
    );

    // Add to activity manager
    activityManager.addActivity(newActivity);

    String message = '${service.title} booked successfully!\nWe\'ll be there in ${service.eta}\nPayment: $paymentMethodText';
    if (location != null) {
      String shortLocation = location.length > 40 ? '${location.substring(0, 40)}...' : location;
      message += '\nLocation: $shortLocation';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text(
                  'Booking Confirmed!',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            SizedBox(height: 4),
            Text(
              message,
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 6),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        action: SnackBarAction(
          label: 'View Details',
          textColor: Colors.white,
          onPressed: () {
            _showBookingDetailsDialog(service, location, paymentMethod);
          },
        ),
      ),
    );
  }

  // Helper method to format the booking date
  String _formatBookingDate() {
    final now = DateTime.now();
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final timeStr = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    final period = now.hour >= 12 ? 'PM' : 'AM';
    return '${months[now.month - 1]} ${now.day}, ${now.year} - $timeStr $period';
  }

  String _getPaymentMethodDisplayText(String paymentMethod) {
    switch (paymentMethod) {
      case 'cash':
        return 'Cash on service';
      case 'card':
        return 'Saved card ****1234';
      case 'fawry':
        return 'Fawry wallet';
      default:
        return 'Unknown payment method';
    }
  }

  // Show detailed booking information with payment details
  void _showBookingDetailsDialog(ServiceItem service, String? location, String paymentMethod) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.receipt_long, color: Color(0xFFFF8C00)),
            SizedBox(width: 12),
            Text('Booking Details'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Service', service.title),
            _buildDetailRow('Price', service.price),
            _buildDetailRow('ETA', service.eta),
            _buildDetailRow('Rating', '${service.rating}'),
            _buildDetailRow('Payment', _getPaymentMethodDisplayText(paymentMethod)),
            if (location != null) _buildDetailRow('Location', location),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.green[700], size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'You will receive updates about your booking via notifications.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green[800],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8),
            // Payment specific information
            _buildPaymentInfoContainer(paymentMethod),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF8C00),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Got it',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentInfoContainer(String paymentMethod) {
    Color color;
    Color textColor;
    IconData icon;
    String message;

    switch (paymentMethod) {
      case 'cash':
        color = Colors.green;
        textColor = Colors.green[800]!;
        icon = Icons.money;
        message = 'Please have exact cash ready for the service provider.';
        break;
      case 'card':
        color = Colors.blue;
        textColor = Colors.blue[800]!;
        icon = Icons.credit_card;
        message = 'Payment will be charged to your saved card upon service completion.';
        break;
      case 'fawry':
        color = Colors.purple;
        textColor = Colors.purple[800]!;
        icon = Icons.account_balance_wallet;
        message = 'Payment will be processed through your Fawry wallet.';
        break;
      default:
        color = Colors.grey;
        textColor = Colors.grey[800]!;
        icon = Icons.payment;
        message = 'Payment details will be processed accordingly.';
    }

    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 12,
                color: textColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.black87,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Pull to refresh functionality
  Future<void> _handleRefresh() async {
    await _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 70,
        title: const Text(
          'Services',
          style: TextStyle(
            color: Color(0xFFFF8C00),
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFFFF8C00)),
            onPressed: _handleRefresh,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF8C00)),
            ),
            SizedBox(height: 16),
            Text(
              'Loading services...',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 60,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Oops! Something went wrong',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _handleRefresh,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF8C00),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Retry',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      color: const Color(0xFFFF8C00),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          _buildSearchSection(),
          const SizedBox(height: 20),
          _buildCategoryTabs(),
          const SizedBox(height: 20),
          Expanded(
            child: _buildServicesList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(50),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.search_rounded,
              color: Colors.black54,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Search for services...',
                  hintStyle: TextStyle(
                    color: Colors.black54,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
            if (_searchQuery.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.clear_rounded, size: 20),
                onPressed: () {
                  _searchController.clear();
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = selectedCategory == category;
          return GestureDetector(
            onTap: () {
              setState(() {
                selectedCategory = category;
              });
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFFF8C00) : Colors.transparent,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: isSelected ? const Color(0xFFFF8C00) : Colors.grey[300]!,
                ),
              ),
              child: Center(
                child: Text(
                  category,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black54,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildServicesList() {
    return filteredServices.isEmpty
        ? Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 60,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No services found',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try a different search term or category',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    )
        : ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: filteredServices.length,
      itemBuilder: (context, index) {
        final service = filteredServices[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: _buildServiceCard(service),
        );
      },
    );
  }

  Widget _buildServiceCard(ServiceItem service) {
    return Stack(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              _showServiceDetails(service);
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[200]!),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: service.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      service.icon,
                      color: service.color,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          service.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          service.description,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time_rounded,
                              size: 18,
                              color: Colors.grey[500],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              service.eta,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Icon(
                              Icons.star_rounded,
                              size: 18,
                              color: Colors.amber[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              service.rating.toString(),
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              service.price,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFFFF8C00),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.grey,
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (service.isNew)
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'New',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _showServiceDetails(ServiceItem service) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: service.color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            service.icon,
                            color: service.color,
                            size: 36,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                service.title,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                service.description,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        _buildInfoItem(
                          Icons.access_time_rounded,
                          'ETA',
                          service.eta,
                        ),
                        const SizedBox(width: 24),
                        _buildInfoItem(
                          Icons.star_rounded,
                          'Rating',
                          service.rating.toString(),
                        ),
                        const SizedBox(width: 24),
                        _buildInfoItem(
                          Icons.attach_money_rounded,
                          'Price',
                          service.price,
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'Service Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Our professional ${service.title.toLowerCase()} service provides reliable and efficient assistance for your vehicle needs. Available 24/7 with experienced technicians.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                        height: 1.5,
                      ),
                    ),
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          // Navigate to map instead of just showing snackbar
                          _navigateToMapForService(service);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF8C00),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Book Service - Choose Location',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 24,
            color: const Color(0xFFFF8C00),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class ServiceItem {
  final String id;
  final String title;
  final IconData icon;
  final Color color;
  final String eta;
  final double rating;
  final String price;
  final bool isNew;
  final String description;
  final String category;

  ServiceItem({
    required this.id,
    required this.title,
    required this.icon,
    required this.color,
    required this.eta,
    required this.rating,
    required this.price,
    required this.isNew,
    required this.description,
    required this.category,
  });

  // Factory constructor to create ServiceItem from JSON
  factory ServiceItem.fromJson(Map<String, dynamic> json) {
    return ServiceItem(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      icon: _getIconFromString(json['icon']),
      color: _getColorFromString(json['color']),
      eta: json['eta'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
      price: json['price'] ?? '',
      isNew: json['isNew'] ?? false,
      description: json['description'] ?? '',
      category: json['category'] ?? '',
    );
  }

  // Helper method to convert icon string to IconData
  static IconData _getIconFromString(String? iconString) {
    switch (iconString) {
      case 'local_shipping_rounded':
        return Icons.local_shipping_rounded;
      case 'build_rounded':
        return Icons.build_rounded;
      case 'settings_rounded':
        return Icons.settings_rounded;
      case 'battery_charging_full_rounded':
        return Icons.battery_charging_full_rounded;
      case 'tire_repair_rounded':
        return Icons.tire_repair_rounded;
      case 'local_gas_station_rounded':
        return Icons.local_gas_station_rounded;
      case 'search_rounded':
        return Icons.search_rounded;
      case 'key_rounded':
        return Icons.key_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  // Helper method to convert color string to Color
  static Color _getColorFromString(String? colorString) {
    if (colorString == null || !colorString.startsWith('#')) {
      return Colors.grey;
    }
    try {
      return Color(int.parse(colorString.substring(1), radix: 16) + 0xFF000000);
    } catch (e) {
      return Colors.grey;
    }
  }

  // Convert ServiceItem to JSON (for potential future use)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'icon': _getStringFromIcon(icon),
      'color': '#${color.value.toRadixString(16).substring(2)}',
      'eta': eta,
      'rating': rating,
      'price': price,
      'isNew': isNew,
      'description': description,
      'category': category,
    };
  }

  // Helper method to convert IconData back to string
  static String _getStringFromIcon(IconData icon) {
    if (icon == Icons.local_shipping_rounded) return 'local_shipping_rounded';
    if (icon == Icons.build_rounded) return 'build_rounded';
    if (icon == Icons.settings_rounded) return 'settings_rounded';
    if (icon == Icons.battery_charging_full_rounded) return 'battery_charging_full_rounded';
    if (icon == Icons.tire_repair_rounded) return 'tire_repair_rounded';
    if (icon == Icons.local_gas_station_rounded) return 'local_gas_station_rounded';
    if (icon == Icons.search_rounded) return 'search_rounded';
    if (icon == Icons.key_rounded) return 'key_rounded';
    return 'help_outline_rounded';
  }
}