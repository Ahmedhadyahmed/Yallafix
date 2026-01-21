import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'Theme_Provider.dart';
import 'package:your_app_name/service_confirmation_sheet.dart';
import 'package:your_app_name/car_info_page.dart';
import 'package:your_app_name/firebase_auth_service.dart';
import 'Map_Screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuthService _authService = FirebaseAuthService();

  // User data variables
  String? _displayName;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final userData = await _authService.getCurrentUserData();
      final firebaseUser = _authService.currentUser;

      setState(() {
        _displayName = userData?.name ?? firebaseUser?.displayName ?? 'Guest';
        _loading = false;
      });
    } catch (e) {
      final firebaseUser = _authService.currentUser;
      setState(() {
        _displayName = firebaseUser?.displayName ?? 'Guest';
        _loading = false;
      });
    }
  }

  void _navigateToServiceConfirmation(String serviceName, String price, String eta) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ServiceConfirmationSheet(
        serviceName: serviceName,
        price: price,
        eta: eta,
      ),
    );
  }

  void _selectServiceAndNavigate(String serviceName, String price, String eta) async {
    final result = await MapNavigation.navigateToMap(
      context,
      title: '$serviceName Service Location',
      showCurrentLocation: true,
      initialZoom: 13.0,
    );

    if (mounted && result != null) {
      _navigateToServiceConfirmation(serviceName, price, eta);
    }
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
                      const SizedBox(height: 8),
                      _buildGreeting(isDark),
                      const SizedBox(height: 32),
                      _buildSearchBar(isDark),
                      const SizedBox(height: 32),
                      _buildCarCard(isDark),
                      const SizedBox(height: 32),
                      _buildEmergencySection(isDark),
                      const SizedBox(height: 32),
                      _buildMaintenanceSection(isDark),
                      const SizedBox(height: 24),
                      _buildProvidersCard(isDark),
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
            child: GestureDetector(
              onTap: () {
                MapNavigation.navigateToMap(
                  context,
                  title: 'Select Location',
                  showCurrentLocation: true,
                  initialZoom: 13.0,
                );
              },
              child: Column(
                children: [
                  Text(
                    'CURRENT LOCATION',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: (isDark ? Colors.white : Colors.black).withOpacity(0.4),
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Home - 123 Main St',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF181411),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.expand_more,
                        color: Color(0xFFF48C25),
                        size: 20,
                      ),
                    ],
                  ),
                ],
              ),
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

  Widget _buildGreeting(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _loading
            ? SizedBox(
          height: 34,
          child: Center(
            child: SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: const Color(0xFFF48C25),
              ),
            ),
          ),
        )
            : Text(
          'Hello, ${_displayName ?? 'Guest'}',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: isDark ? Colors.white : const Color(0xFF181411),
            height: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Ready to hit the road safely?',
          style: TextStyle(
            fontSize: 15,
            color: (isDark ? Colors.white : Colors.black).withOpacity(0.6),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return GestureDetector(
      onTap: () {
        MapNavigation.navigateToMap(
          context,
          title: 'Select Service Location',
          showCurrentLocation: true,
          initialZoom: 13.0,
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF32281E) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
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
              child: Text(
                'What service do you need?',
                style: TextStyle(
                  color: (isDark ? Colors.white : Colors.black).withOpacity(0.4),
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCarCard(bool isDark) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CarInfoPage()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF32281E) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.green[100]!),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'ACTIVE',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Toyota Camry',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF181411),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '2021 • Silver Sedan',
                    style: TextStyle(
                      fontSize: 13,
                      color: (isDark ? Colors.white : Colors.black).withOpacity(0.6),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'ABC-1234',
                    style: TextStyle(
                      fontSize: 11,
                      color: (isDark ? Colors.white : Colors.black).withOpacity(0.4),
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 20),
                  InkWell(
                    onTap: () {
                      // Switch car functionality
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF221910)
                            : const Color(0xFFF8F7F5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Switch Car',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: isDark ? Colors.white : const Color(0xFF181411),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.swap_horiz,
                            size: 20,
                            color: (isDark ? Colors.white : Colors.black).withOpacity(0.6),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 128,
              height: 160,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: isDark
                    ? const Color(0xFF221910)
                    : const Color(0xFFF8F7F5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuD2Rtq_Puw73JUkp2zuyuU_8Mer-HSWWE8kb4qHtH_09c3QJI2aiTXM6TPy_WkCoo0TbIZq3JZ2pvR9J_1hwaN9yzbJ6vC2uvNAGN21fL5keB9eCcY1ybK9-QXOMZY6eqpH_UtGNnLxIT4upM0jxbc0jVHEdd0LJNwAIbl4gIHuaytF4RZZRs1hbh0YkWJqyIOEzXamlmsnS9DnhkX6e3_i3qTGlU3fLASuVj9dl5N4l34ZYp5Y2dnwJVYDgP2y610fwUSfFQHL3-zx',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: isDark
                          ? const Color(0xFF221910)
                          : const Color(0xFFF8F7F5),
                      child: Icon(
                        Icons.directions_car,
                        size: 60,
                        color: (isDark ? Colors.white : Colors.black).withOpacity(0.3),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencySection(bool isDark) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.emergency, color: Colors.red[500], size: 24),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Emergency',
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF181411),
                        ),
                      ),
                      Text(
                        'Quick assistance',
                        style: TextStyle(
                          fontSize: 12,
                          color: (isDark ? Colors.white : Colors.black).withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  MapNavigation.navigateToMap(
                    context,
                    title: 'Emergency Service Location',
                    showCurrentLocation: true,
                    initialZoom: 13.0,
                  );
                },
                child: const Row(
                  children: [
                    Text(
                      'View Map',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFF48C25),
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward, color: Color(0xFFF48C25), size: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 190,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.zero,
            children: [
              _buildEmergencyCard('Towing', '15 min away', Icons.local_shipping_outlined, true, 'EGP 50-80', '15-20 mins', isDark),
              const SizedBox(width: 16),
              _buildEmergencyCard('Jump Start', 'From \$30', Icons.battery_alert_outlined, false, 'EGP 30', '10-15 mins', isDark),
              const SizedBox(width: 16),
              _buildEmergencyCard('Lockout', '24/7 Service', Icons.lock_open_outlined, false, 'EGP 40', '15-25 mins', isDark),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmergencyCard(String title, String subtitle, IconData icon, bool isPrimary, String price, String eta, bool isDark) {
    return GestureDetector(
      onTap: () => _selectServiceAndNavigate(title, price, eta),
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: isPrimary
              ? const LinearGradient(
            colors: [Color(0xFFF48C25), Color(0xFFD95200)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
              : null,
          color: isPrimary ? null : (isDark ? const Color(0xFF32281E) : Colors.white),
          borderRadius: BorderRadius.circular(28),
          border: isPrimary
              ? null
              : Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.05)
                : Colors.grey[100]!,
          ),
          boxShadow: [
            if (isPrimary)
              BoxShadow(
                color: const Color(0xFFF48C25).withOpacity(0.25),
                blurRadius: 12,
                offset: const Offset(0, 4),
              )
            else
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isPrimary ? Colors.white.withOpacity(0.2) : Colors.red[50],
                shape: BoxShape.circle,
                border: isPrimary ? Border.all(color: Colors.white.withOpacity(0.1)) : null,
              ),
              child: Icon(icon, color: isPrimary ? Colors.white : Colors.red[500], size: 26),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: isPrimary ? Colors.white : (isDark ? Colors.white : const Color(0xFF181411)),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (isPrimary) ...[
                      Icon(Icons.schedule, color: Colors.white.withOpacity(0.8), size: 14),
                      const SizedBox(width: 4),
                    ],
                    Flexible(
                      child: Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: isPrimary
                              ? Colors.white.withOpacity(0.95)
                              : (isDark ? Colors.white : Colors.black).withOpacity(0.6),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMaintenanceSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              Container(
                height: 24,
                width: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFF48C25),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Maintenance & Repair',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF181411),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.85,
          children: [
            _buildServiceCard('Oil Change', 'Starting at \$40', Icons.water_drop_outlined, Colors.blue, 'EGP 40-60', '30-45 mins', isDark),
            _buildServiceCard('Diagnostics', 'Full system scan', Icons.monitor_heart_outlined, Colors.purple, 'EGP 50-70', '20-30 mins', isDark),
            _buildServiceCard('AC Repair', 'Cooling check', Icons.mode_fan_off_outlined, Colors.cyan, 'EGP 80-120', '45-60 mins', isDark),
            _buildServiceCard('Mechanic', 'Doorstep repair', Icons.handyman_outlined, Colors.green, 'EGP 60-100', '30-50 mins', isDark),
          ],
        ),
      ],
    );
  }

  Widget _buildServiceCard(String title, String subtitle, IconData icon, Color color, String price, String eta, bool isDark) {
    return GestureDetector(
      onTap: () => _selectServiceAndNavigate(title, price, eta),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF32281E) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF181411),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: (isDark ? Colors.white : Colors.black).withOpacity(0.6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProvidersCard(bool isDark) {
    return GestureDetector(
      onTap: () {
        MapNavigation.navigateToMap(
          context,
          title: 'View Providers Near You',
          showCurrentLocation: true,
          initialZoom: 13.0,
        );
      },
      child: Container(
        height: 128,
        padding: const EdgeInsets.symmetric(horizontal: 32),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF32281E), const Color(0xFF221910)]
                : [const Color(0xFF1F2937), const Color(0xFF111827)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AVAILABLE NOW',
                  style: TextStyle(
                    color: const Color(0xFFF48C25),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  '3 Providers\nnear you',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF48C25).withOpacity(0.2),
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: const Color(0xFFF48C25).withOpacity(0.3)),
              ),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF48C25),
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFF48C25).withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.near_me, color: Colors.white, size: 24),
              ),
            ),
          ],
        ),
      ),
    );
  }
}