import 'package:flutter/material.dart';
import 'package:your_app_name/payment_methods.dart';
import 'car_info_page.dart';
import 'setting.dart';
import 'msg_screens.dart';
import 'T_S.dart';
import 'firebase_auth_service.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final FirebaseAuthService _authService = FirebaseAuthService();

  // User data variables
  String? _displayName;
  String? _email;
  String? _phoneNumber;
  String? _photoUrl;
  String? _userId;
  DateTime? _memberSince;
  int _totalServices = 0;
  int _totalHistory = 0;
  double _rating = 0.0;
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
        // Basic user info from UserModel and Firebase Auth
        _displayName = userData?.name ?? firebaseUser?.displayName ?? 'Guest User';
        _email = userData?.email ?? firebaseUser?.email ?? '';
        _phoneNumber = firebaseUser?.phoneNumber ?? '';
        _photoUrl = firebaseUser?.photoURL;
        _userId = firebaseUser?.uid ?? '';

        // Member since from Firebase Auth creation time
        _memberSince = firebaseUser?.metadata.creationTime;

        // Default stats (you can fetch these from a separate Firestore collection later)
        _totalServices = 12;
        _totalHistory = 8;
        _rating = 5.0;

        _loading = false;
      });
    } catch (e) {
      // Fallback to Firebase Auth user data only
      final firebaseUser = _authService.currentUser;
      setState(() {
        _displayName = firebaseUser?.displayName ?? 'Guest User';
        _email = firebaseUser?.email ?? '';
        _phoneNumber = firebaseUser?.phoneNumber ?? '';
        _photoUrl = firebaseUser?.photoURL;
        _userId = firebaseUser?.uid ?? '';
        _memberSince = firebaseUser?.metadata.creationTime;
        _totalServices = 0;
        _totalHistory = 0;
        _rating = 5.0;
        _loading = false;
      });
    }
  }

  String _formatMemberSince() {
    if (_memberSince == null) return 'N/A';
    final now = DateTime.now();
    final difference = now.difference(_memberSince!);

    if (difference.inDays < 30) {
      return 'Member for ${difference.inDays} days';
    } else if (difference.inDays < 365) {
      return 'Member for ${(difference.inDays / 30).floor()} months';
    } else {
      return 'Member for ${(difference.inDays / 365).floor()} years';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header with gradient background
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFFF9800), Color(0xFFFFB74D)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    // App Bar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'My Account',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.edit_outlined, color: Colors.white),
                              onPressed: () {
                                // Edit profile action
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Profile Section
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              // Profile Picture
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: _photoUrl == null
                                      ? LinearGradient(
                                    colors: [Color(0xFFFF9800), Color(0xFFFFB74D)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  )
                                      : null,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color(0xFFFF9800).withOpacity(0.3),
                                      blurRadius: 15,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: CircleAvatar(
                                  radius: 45,
                                  backgroundColor: Colors.transparent,
                                  backgroundImage: _photoUrl != null
                                      ? NetworkImage(_photoUrl!)
                                      : null,
                                  child: _photoUrl == null
                                      ? const Icon(
                                    Icons.person_rounded,
                                    size: 50,
                                    color: Colors.white,
                                  )
                                      : null,
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Display Name
                                    _loading
                                        ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                        : Text(
                                      _displayName ?? 'Guest User',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                        color: Color(0xFF2C3E50),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    // Rating Badge
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Color(0xFFFF9800).withOpacity(0.15),
                                            Color(0xFFFFB74D).withOpacity(0.15),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.star_rounded,
                                            size: 18,
                                            color: Color(0xFFFF9800),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            _rating.toStringAsFixed(1),
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFFFF9800),
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          const Text(
                                            "Rating",
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Color(0xFFFF9800),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // User Information Details
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8F9FA),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                if (_email != null && _email!.isNotEmpty)
                                  _buildInfoRow(
                                    Icons.email_rounded,
                                    'Email',
                                    _email!,
                                  ),
                                if (_phoneNumber != null && _phoneNumber!.isNotEmpty) ...[
                                  const SizedBox(height: 12),
                                  _buildInfoRow(
                                    Icons.phone_rounded,
                                    'Phone',
                                    _phoneNumber!,
                                  ),
                                ],
                                if (_userId != null && _userId!.isNotEmpty) ...[
                                  const SizedBox(height: 12),
                                  _buildInfoRow(
                                    Icons.badge_rounded,
                                    'User ID',
                                    _userId!.substring(0, 8) + '...',
                                  ),
                                ],
                                if (_memberSince != null) ...[
                                  const SizedBox(height: 12),
                                  _buildInfoRow(
                                    Icons.calendar_today_rounded,
                                    'Member Since',
                                    _formatMemberSince(),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Quick Stats Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.car_repair_rounded,
                        label: 'Services',
                        value: _totalServices.toString(),
                        colors: [Color(0xFFFF9800), Color(0xFFFFB74D)],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.history_rounded,
                        label: 'History',
                        value: _totalHistory.toString(),
                        colors: [Color(0xFFFFB74D), Color(0xFFFFCC80)],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Menu Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 4, bottom: 12),
                      child: Text(
                        'Account Options',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C3E50),
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),

                    _buildMenuButton(
                      icon: Icons.directions_car_rounded,
                      label: "Car Information",
                      gradientColors: [Color(0xFFFF9800), Color(0xFFFFB74D)],
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const CarInfoPage()),
                        );
                      },
                    ),

                    _buildMenuButton(
                      icon: Icons.payment_rounded,
                      label: "Payment Methods",
                      gradientColors: [Color(0xFFFF9800), Color(0xFFFFB74D)],
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => PaymentMethodScreen()),
                        );
                      },
                    ),

                    _buildMenuButton(
                      icon: Icons.settings_rounded,
                      label: "Settings",
                      gradientColors: [Color(0xFFFF9800), Color(0xFFFFB74D)],
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const SettingPage()),
                        );
                      },
                    ),

                    _buildMenuButton(
                      icon: Icons.message_rounded,
                      label: "Messages",
                      gradientColors: [Color(0xFFFF9800), Color(0xFFFFB74D)],
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const MessagesScreen()),
                        );
                      },
                    ),

                    _buildMenuButton(
                      icon: Icons.description_rounded,
                      label: "Terms & Services",
                      gradientColors: [Color(0xFFFF9800), Color(0xFFFFB74D)],
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const TermsAndServicesScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: const Color(0xFFFF9800),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF2C3E50),
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required List<Color> colors,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colors[0].withOpacity(0.15),
                  colors[1].withOpacity(0.15),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: colors[0], size: 28),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: colors[0],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButton({
    required IconData icon,
    required String label,
    required List<Color> gradientColors,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        gradientColors[0].withOpacity(0.15),
                        gradientColors[1].withOpacity(0.15),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: gradientColors[0],
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2C3E50),
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.grey[500],
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}