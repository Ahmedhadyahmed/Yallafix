import 'package:flutter/material.dart';

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
      price: 'From 250 EGP',
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
      price: 'From 375 EGP',
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
      price: 'From 150 EGP',
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
      price: 'From 125 EGP',
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
      price: 'From 200 EGP',
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
      price: 'From 175 EGP',
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
      price: 'From 400 EGP',
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
      price: 'From 300 EGP',
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
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                style: const TextStyle(
                  fontSize: 18,
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
                            fontSize: 20,
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
                                fontSize: 16,
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
                                  fontSize: 26,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                service.description,
                                style: TextStyle(
                                  fontSize: 18,
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
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Our professional ${service.title.toLowerCase()} service provides reliable and efficient assistance for your vehicle needs. Available 24/7 with experienced technicians.',
                      style: TextStyle(
                        fontSize: 18,
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
                            fontSize: 20,
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
              fontSize: 16,
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
}