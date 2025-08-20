import 'dart:async';
import 'package:flutter/material.dart';

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
                  fontSize: 18,
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
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            location.subtitle,
                            style: TextStyle(
                              fontSize: 16,
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
                  fontSize: 24,
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
                    fontSize: 16,
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
                      fontSize: 18,
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
                  fontSize: 12,
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
          height: 160,
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
                              fontSize: 24,
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
                                    fontSize: 14,
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