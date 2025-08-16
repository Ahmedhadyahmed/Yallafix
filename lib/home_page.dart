import 'dart:math';
import 'dart:ui';
import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(const RoadHelperApp());
}

class RoadHelperApp extends StatelessWidget {
  const RoadHelperApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'YallaFix - Roadside Assistance',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF8C00),
          brightness: Brightness.light,
        ),
        fontFamily: 'SF Pro Display',
        useMaterial3: true,
      ),
      home: const MainPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const ServicesPage(),
    const ActivityPage(),
    const AccountPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home_rounded, 'Home', 0),
              _buildNavItem(Icons.grid_view_rounded, 'Services', 1),
              _buildNavItem(Icons.receipt_long_rounded, 'Activity', 2),
              _buildNavItem(Icons.person_rounded, 'Account', 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? const Color(0xFFFF8C00) : Colors.grey[400],
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? const Color(0xFFFF8C00) : Colors.grey[400],
              fontSize: 14, // Increased from 12
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late PageController _pageController;
  late Timer _timer;

  String? selectedService;
  int _currentPromoIndex = 0;

  final List<ServiceItem> services = [
    ServiceItem(
      id: 'tow',
      title: 'Tow',
      icon: Icons.local_shipping_rounded,
      color: const Color(0xFF2196F3),
      eta: '15-25 min',
      rating: 4.7,
      price: 'From 50 AED',
      isNew: false,
      description: 'Professional towing service for all vehicle types',
      category: 'Emergency',
    ),
    ServiceItem(
      id: 'mechanic',
      title: 'Mechanic',
      icon: Icons.build_rounded,
      color: const Color(0xFF4CAF50),
      eta: '20-35 min',
      rating: 4.8,
      price: 'From 75 AED',
      isNew: true,
      description: 'Expert mechanics come to your location',
      category: 'Maintenance',
    ),
    ServiceItem(
      id: 'parts',
      title: 'Parts',
      icon: Icons.settings_rounded,
      color: const Color(0xFFFF9800),
      eta: '25-45 min',
      rating: 4.6,
      price: 'From 30 AED',
      isNew: false,
      description: 'Quality auto parts delivered fast',
      category: 'Parts',
    ),
  ];

  final List<PromoItem> _promoItems = [
    PromoItem(
      title: '30% off your first\nservice call',
      subtitle: 'Get help now',
      colors: [Color(0xFFFF8C00), Color(0xFFFFB84D)],
    ),
    PromoItem(
      title: '24/7 Emergency\nAssistance Available',
      subtitle: 'Call now',
      colors: [Color(0xFFFF6B6B), Color(0xFFFF8E8E)],
    ),
    PromoItem(
      title: 'Free diagnostics\nwith any repair',
      subtitle: 'Book service',
      colors: [Color(0xFF4ECDC4), Color(0xFF7EDDD8)],
    ),
  ];

  final List<RecentLocation> recentLocations = [
    RecentLocation(
      title: 'Arab Academy for science and technology',
      subtitle: 'Branched from Gamal Abd Al Naser Street',
      icon: Icons.access_time_rounded,
    ),
    RecentLocation(
      title: 'Egyption German Porcelain Co.',
      subtitle: 'Al Agamy Al Qebeyah',
      icon: Icons.access_time_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _pageController = PageController();

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.forward();

    // Auto-scroll promo cards every 4 seconds
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_pageController.hasClients) {
        int nextPage = (_currentPromoIndex + 1) % _promoItems.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
    _timer.cancel();
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
          'Yalla Fix',
          style: TextStyle(
            color: Color(0xFFFF8C00),
            fontSize: 28,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              _buildSearchSection(),
              const SizedBox(height: 30),
              _buildRecentLocations(),
              const SizedBox(height: 40),
              _buildServicesSection(),
              const SizedBox(height: 30),
              _buildPromoSection(),
              const SizedBox(height: 100),
            ],
          ),
        ),
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
            const Expanded(
              child: Text(
                'Where do you need help?',
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 18, // Increased from 16
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFFF8C00).withOpacity(0.3)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.schedule_rounded,
                    size: 16,
                    color: Color(0xFFFF8C00),
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Now',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFFFF8C00),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentLocations() {
    return Column(
      children: recentLocations.map((location) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        location.icon,
                        color: Colors.black54,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            location.title,
                            style: const TextStyle(
                              fontSize: 18, // Increased from 16
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            location.subtitle,
                            style: TextStyle(
                              fontSize: 16, // Increased from 14
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: Colors.black26,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildServicesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Services',
                style: TextStyle(
                  fontSize: 24, // Increased from 22
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'See all',
                  style: TextStyle(
                    color: Color(0xFFFF8C00),
                    fontWeight: FontWeight.w600,
                    fontSize: 16, // Increased from default
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: services.length,
            itemBuilder: (context, index) {
              final service = services[index];
              return Container(
                width: 120,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                child: _buildServiceCard(service),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildServiceCard(ServiceItem service) {
    return Stack(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              setState(() {
                selectedService = service.id;
              });
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(16),
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
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
                  const SizedBox(height: 12),
                  Text(
                    service.title,
                    style: const TextStyle(
                      fontSize: 18, // Increased from 16
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (service.isNew)
          Positioned(
            top: 8,
            right: 8,
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
                  fontSize: 12, // Increased from 10
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPromoSection() {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          height: 160, // Original height
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPromoIndex = index;
              });
            },
            itemCount: _promoItems.length,
            itemBuilder: (context, index) {
              final promo = _promoItems[index];
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: promo.colors,
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -20,
                      bottom: -20,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 20,
                      top: -10,
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            promo.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24, // Original smaller size
                              fontWeight: FontWeight.w700,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  promo.subtitle,
                                  style: TextStyle(
                                    color: promo.colors[0],
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14, // Original smaller size
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  color: promo.colors[0],
                                  size: 16,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _promoItems.length,
                (index) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentPromoIndex == index ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: _currentPromoIndex == index
                    ? const Color(0xFFFF8C00)
                    : Colors.grey[300],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class ServicesPage extends StatefulWidget {
  const ServicesPage({super.key});

  @override
  State<ServicesPage> createState() => _ServicesPageState();
}

class _ServicesPageState extends State<ServicesPage> {
  String selectedCategory = 'All';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<String> categories = [
    'All',
    'Emergency',
    'Maintenance',
    'Parts',
    'Inspection'
  ];

  final List<ServiceItem> allServices = [
    ServiceItem(
      id: 'tow',
      title: 'Tow Service',
      icon: Icons.local_shipping_rounded,
      color: const Color(0xFF2196F3),
      eta: '15-25 min',
      rating: 4.7,
      price: 'From 250 EGP', // Changed from 50 AED
      isNew: false,
      description: 'Professional towing service for all vehicle types',
      category: 'Emergency',
    ),
    ServiceItem(
      id: 'mechanic',
      title: 'Mobile Mechanic',
      icon: Icons.build_rounded,
      color: const Color(0xFF4CAF50),
      eta: '20-35 min',
      rating: 4.8,
      price: 'From 375 EGP', // Changed from 75 AED
      isNew: true,
      description: 'Expert mechanics come to your location',
      category: 'Maintenance',
    ),
    ServiceItem(
      id: 'parts',
      title: 'Auto Parts',
      icon: Icons.settings_rounded,
      color: const Color(0xFFFF9800),
      eta: '25-45 min',
      rating: 4.6,
      price: 'From 150 EGP', // Changed from 30 AED
      isNew: false,
      description: 'Quality auto parts delivered fast',
      category: 'Parts',
    ),
    ServiceItem(
      id: 'battery',
      title: 'Battery Service',
      icon: Icons.battery_charging_full_rounded,
      color: const Color(0xFFE91E63),
      eta: '10-20 min',
      rating: 4.9,
      price: 'From 125 EGP', // Changed from 25 AED
      isNew: false,
      description: 'Jump start and battery replacement',
      category: 'Emergency',
    ),
    ServiceItem(
      id: 'tire',
      title: 'Tire Service',
      icon: Icons.tire_repair_rounded,
      color: const Color(0xFF9C27B0),
      eta: '15-30 min',
      rating: 4.5,
      price: 'From 200 EGP', // Changed from 40 AED
      isNew: false,
      description: 'Tire repair and replacement service',
      category: 'Maintenance',
    ),
    ServiceItem(
      id: 'fuel',
      title: 'Fuel Delivery',
      icon: Icons.local_gas_station_rounded,
      color: const Color(0xFF607D8B),
      eta: '15-25 min',
      rating: 4.8,
      price: 'From 175 EGP', // Changed from 35 AED
      isNew: true,
      description: 'Emergency fuel delivery service',
      category: 'Emergency',
    ),
    ServiceItem(
      id: 'inspection',
      title: 'Vehicle Inspection',
      icon: Icons.search_rounded,
      color: const Color(0xFF795548),
      eta: '30-45 min',
      rating: 4.7,
      price: 'From 400 EGP', // Changed from 80 AED
      isNew: false,
      description: 'Comprehensive vehicle inspection',
      category: 'Inspection',
    ),
    ServiceItem(
      id: 'lockout',
      title: 'Lockout Service',
      icon: Icons.key_rounded,
      color: const Color(0xFFFF5722),
      eta: '15-25 min',
      rating: 4.6,
      price: 'From 300 EGP', // Changed from 60 AED
      isNew: false,
      description: 'Professional car lockout assistance',
      category: 'Emergency',
    ),
  ];

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
            fontSize: 28,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Column(
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
                    fontSize: 18, // Increased from 16
                    fontWeight: FontWeight.w400,
                  ),
                ),
                style: const TextStyle(
                  fontSize: 18, // Increased from 16
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
                    fontSize: 16, // Increased from 14
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
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try a different search term',
            style: TextStyle(
              fontSize: 16,
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
                            fontSize: 20, // Increased from 18
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          service.description,
                          style: TextStyle(
                            fontSize: 16, // Increased from 14
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time_rounded,
                              size: 18, // Increased from 16
                              color: Colors.grey[500],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              service.eta,
                              style: TextStyle(
                                fontSize: 14, // Increased from 12
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Icon(
                              Icons.star_rounded,
                              size: 18, // Increased from 16
                              color: Colors.amber[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              service.rating.toString(),
                              style: TextStyle(
                                fontSize: 14, // Increased from 12
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              service.price,
                              style: const TextStyle(
                                fontSize: 16, // Increased from 14
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
                    size: 24, // Increased from 20
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
                  fontSize: 12, // Increased from 10
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
                            size: 36, // Increased from 32
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
                                  fontSize: 26, // Increased from 24
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                service.description,
                                style: TextStyle(
                                  fontSize: 18, // Increased from 16
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
                        fontSize: 22, // Increased from 20
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Our professional ${service.title.toLowerCase()} service provides reliable and efficient assistance for your vehicle needs. Available 24/7 with experienced technicians.',
                      style: TextStyle(
                        fontSize: 18, // Increased from 16
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
                          // Handle service booking
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF8C00),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Book Service',
                          style: TextStyle(
                            fontSize: 20, // Increased from 18
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
            size: 24, // Increased from 20
            color: const Color(0xFFFF8C00),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 14, // Increased from 12
              color: Colors.grey[500],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16, // Increased from 14
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header Section
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  // Profile Picture
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.person_rounded,
                      size: 40,
                      color: Colors.grey[400],
                    ),
                  ),
                  const SizedBox(width: 20),
                  // User Info
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ahmed Hassan',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.star_rounded,
                              color: Colors.black87,
                              size: 16,
                            ),
                            SizedBox(width: 4),
                            Text(
                              '5.0',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Menu Items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _buildMenuItem(
                    icon: Icons.directions_car_rounded,
                    title: 'Car Info',
                    subtitle: 'Manage your vehicle details',
                  ),
                  _buildMenuItem(
                    icon: Icons.settings_rounded,
                    title: 'Settings',
                  ),
                  _buildMenuItem(
                    icon: Icons.message_rounded,
                    title: 'Messages',
                  ),
                  _buildMenuItem(
                    icon: Icons.person_rounded,
                    title: 'Earn by helping others',
                  ),
                  _buildMenuItem(
                    icon: Icons.bookmark_rounded,
                    title: 'Saved locations',
                    hasNew: true,
                  ),
                  _buildMenuItem(
                    icon: Icons.business_rounded,
                    title: 'Set up your business profile',
                    subtitle: 'Automate work travel & service expenses',
                  ),
                  _buildMenuItem(
                    icon: Icons.route_rounded,
                    title: 'Service Routes',
                  ),
                  _buildMenuItem(
                    icon: Icons.account_circle_rounded,
                    title: 'Manage Yalla Fix account',
                  ),
                  _buildMenuItem(
                    icon: Icons.info_rounded,
                    title: 'Legal',
                  ),

                  const SizedBox(height: 20),

                  // Version
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                      'v4.556.10005',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 16, // Increased from 14
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    String? subtitle,
    bool hasNew = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 16),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: Colors.black87,
                  size: 28, // Increased from 24
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: const TextStyle(
                                fontSize: 18, // Increased from 16
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          if (hasNew)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2196F3),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'NEW',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12, // Increased from 10
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                        ],
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 16, // Increased from 14
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.grey[400],
                  size: 24, // Increased from 20
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ActivityPage extends StatelessWidget {
  const ActivityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Activity',
          style: TextStyle(
            color: Color(0xFFFF8C00),
            fontSize: 28,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: const Center(
        child: Text(
          'Activity Page',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
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
}

class PromoItem {
  final String title;
  final String subtitle;
  final List<Color> colors;

  PromoItem({
    required this.title,
    required this.subtitle,
    required this.colors,
  });
}

class RecentLocation {
  final String title;
  final String subtitle;
  final IconData icon;

  RecentLocation({
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}