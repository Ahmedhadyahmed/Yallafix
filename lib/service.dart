import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'Theme_Provider.dart';
import 'Map_Screen.dart';
import 'activity_manager.dart';
import 'package:your_app_name/service_confirmation_sheet.dart';

class ServicesPage extends StatefulWidget {
  const ServicesPage({super.key});

  @override
  State<ServicesPage> createState() => _ServicesPageState();
}

class _ServicesPageState extends State<ServicesPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedPaymentMethod = 'cash';

  // Constant data
  static final List<Map<String, dynamic>> roadsideServices = [
    {
      'id': '1',
      'title': 'Towing Service',
      'icon': 'local_shipping_rounded',
      'color': '#F48C25',
      'eta': '15-20 mins',
      'rating': 4.8,
      'price': 'From \$50',
      'isNew': false,
      'description': 'Flatbed towing to nearest shop',
      'category': 'Roadside Assistance'
    },
    {
      'id': '2',
      'title': 'Jump Start',
      'icon': 'battery_charging_full_rounded',
      'color': '#F44336',
      'eta': '10-15 mins',
      'rating': 4.7,
      'price': '\$30',
      'isNew': false,
      'description': 'Dead battery boost',
      'category': 'Roadside Assistance'
    },
    {
      'id': '3',
      'title': 'Flat Tire Change',
      'icon': 'tire_repair_rounded',
      'color': '#9E9E9E',
      'eta': '15-25 mins',
      'rating': 4.8,
      'price': '\$40',
      'isNew': false,
      'description': 'Spare tire installation',
      'category': 'Roadside Assistance'
    },
    {
      'id': '4',
      'title': 'Fuel Delivery',
      'icon': 'local_gas_station_rounded',
      'color': '#FFC107',
      'eta': '20-30 mins',
      'rating': 4.6,
      'price': '\$25',
      'isNew': false,
      'description': 'Up to 2 gallons delivered',
      'category': 'Roadside Assistance'
    },
  ];

  static final List<Map<String, dynamic>> maintenanceServices = [
    {
      'id': '5',
      'title': 'Oil Change',
      'icon': 'water_drop',
      'color': '#2196F3',
      'eta': '25-35 mins',
      'rating': 4.9,
      'price': '\$45 - \$80',
      'isNew': false,
      'description': 'Synthetic or conventional',
      'category': 'Maintenance'
    },
    {
      'id': '6',
      'title': 'Diagnostics',
      'icon': 'monitor_heart_outlined',
      'color': '#9C27B0',
      'eta': '30-45 mins',
      'rating': 4.9,
      'price': '\$50',
      'isNew': false,
      'description': 'Full computer scan',
      'category': 'Maintenance'
    },
    {
      'id': '7',
      'title': 'AC Repair',
      'icon': 'mode_fan_off_outlined',
      'color': '#00BCD4',
      'eta': '45-60 mins',
      'rating': 4.7,
      'price': 'From \$60',
      'isNew': false,
      'description': 'Gas refill & leak check',
      'category': 'Maintenance'
    },
  ];

  static final List<Map<String, dynamic>> detailingServices = [
    {
      'id': '8',
      'title': 'Basic Wash',
      'icon': 'local_car_wash',
      'color': '#4CAF50',
      'eta': '20-30 mins',
      'rating': 4.6,
      'price': '\$20',
      'isNew': false,
      'description': 'Exterior & vacuum',
      'category': 'Detailing'
    },
    {
      'id': '9',
      'title': 'Full Detailing',
      'icon': 'cleaning_services',
      'color': '#009688',
      'eta': '90-120 mins',
      'rating': 4.9,
      'price': '\$120',
      'isNew': false,
      'description': 'Deep clean & polish',
      'category': 'Detailing'
    },
  ];

  List<ServiceItem> allServices = [];
  bool isLoading = false;

  List<ServiceItem> get filteredServices {
    if (_searchQuery.isEmpty) {
      return allServices;
    }
    return allServices.where((service) =>
    service.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        service.description.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
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

  Future<void> _loadData() async {
    try {
      setState(() {
        isLoading = true;
      });

      await Future.delayed(const Duration(milliseconds: 300));

      final allServicesList = [
        ...roadsideServices,
        ...maintenanceServices,
        ...detailingServices,
      ];

      allServices = allServicesList.map((json) => ServiceItem.fromJson(json)).toList();

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _navigateToMapForService(ServiceItem service) async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => AlexandriaMapScreen(
          title: '${service.title} - Alexandria',
          showCurrentLocation: true,
          serviceItem: service,
        ),
      ),
    );

    if (result != null && result['location'] != null) {
      final selectedLocation = result['location'];
      final selectedAddress = result['address'];

      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        _showBookingConfirmationDialog(service, selectedLocation, selectedAddress);
      }
    }
  }

  void _showBookingConfirmationDialog(ServiceItem service, dynamic location, String? address) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ServiceConfirmationSheet(
        serviceName: service.title,
        price: service.price,
        eta: service.eta,
        onConfirm: (paymentMethod) {
          _processBooking(service, address, paymentMethod);
        },
      ),
    );
  }

  void _processBooking(ServiceItem service, String? location, String paymentMethod) {
    String paymentMethodText = _getPaymentMethodDisplayText(paymentMethod);

    final activityManager = ActivityManager();
    final newActivity = ActivityItemData(
      id: activityManager.generateId(),
      serviceName: service.title,
      date: _formatBookingDate(),
      status: ActivityStatus.upcoming,
      price: service.price,
      rating: null,
      description: service.description,
      serviceProvider: 'Quick Service Pro',
      comments: null,
      location: location,
      paymentMethod: paymentMethodText,
    );

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
            const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text('Booking Confirmed!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            const SizedBox(height: 4),
            Text(message, style: const TextStyle(fontSize: 14)),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 6),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get theme provider - KEY ADDITION!
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF221910) : const Color(0xFFF8F7F5),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(isDark),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      Text(
                        'Our Services',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: isDark ? Colors.white : const Color(0xFF181411),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildSearchBar(isDark),
                      const SizedBox(height: 24),
                      _buildServiceSection('Roadside Assistance', roadsideServices, const Color(0xFFF48C25), isDark),
                      const SizedBox(height: 24),
                      _buildServiceSection('Maintenance', maintenanceServices, const Color(0xFF2196F3), isDark),
                      const SizedBox(height: 24),
                      _buildServiceSection('Detailing', detailingServices, const Color(0xFF4CAF50), isDark),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF32281E) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              children: [
                Text(
                  'Current Location',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFF48C25),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Downtown Dubai',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF181411),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.expand_more,
                      size: 20,
                      color: isDark ? Colors.white : const Color(0xFF181411),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF221910)
                      : const Color(0xFFF8F7F5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.notifications_outlined,
                  size: 24,
                  color: isDark ? Colors.white : const Color(0xFF181411),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF48C25),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? const Color(0xFF32281E) : Colors.white,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF32281E) : Colors.white,
        borderRadius: BorderRadius.circular(25),
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
          Icon(
            Icons.search,
            color: (isDark ? Colors.white : Colors.black).withOpacity(0.4),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _searchController,
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF181411),
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Search for a service...',
                hintStyle: TextStyle(
                  color: (isDark ? Colors.white : Colors.black).withOpacity(0.4),
                  fontSize: 15,
                ),
              ),
            ),
          ),
          if (_searchQuery.isNotEmpty)
            GestureDetector(
              onTap: () => _searchController.clear(),
              child: Icon(
                Icons.clear,
                color: (isDark ? Colors.white : Colors.black).withOpacity(0.4),
                size: 20,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildServiceSection(String title, List<Map<String, dynamic>> services, Color dotColor, bool isDark) {
    final serviceItems = services.map((json) => ServiceItem.fromJson(json)).toList();
    final filtered = _searchQuery.isEmpty
        ? serviceItems
        : serviceItems.where((s) =>
    s.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        s.description.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

    if (filtered.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF181411),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ...filtered.map((service) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildServiceCard(service, isDark),
        )),
      ],
    );
  }

  Widget _buildServiceCard(ServiceItem service, bool isDark) {
    return GestureDetector(
      onTap: () => _navigateToMapForService(service),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF32281E) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.05)
                : Colors.grey[100]!,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: service.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(service.icon, color: service.color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF181411),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    service.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: (isDark ? Colors.white : Colors.black).withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  service.price,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF181411),
                  ),
                ),
              ],
            ),
          ],
        ),
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
      case 'water_drop':
        return Icons.water_drop;
      case 'monitor_heart_outlined':
        return Icons.monitor_heart_outlined;
      case 'mode_fan_off_outlined':
        return Icons.mode_fan_off_outlined;
      case 'local_car_wash':
        return Icons.local_car_wash;
      case 'cleaning_services':
        return Icons.cleaning_services;
      default:
        return Icons.help_outline_rounded;
    }
  }

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
}