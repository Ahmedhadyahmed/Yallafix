import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:your_app_name/payment_methods.dart';
import 'car_info_page.dart';
import 'setting.dart';
import 'msg_screens.dart';
import 'T_S.dart';
import 'firebase_auth_service.dart';
import 'Theme_Provider.dart';

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
        _displayName = userData?.name ?? firebaseUser?.displayName ?? 'Guest User';
        _email = userData?.email ?? firebaseUser?.email ?? '';
        _phoneNumber = firebaseUser?.phoneNumber ?? '';
        _photoUrl = firebaseUser?.photoURL;
        _userId = firebaseUser?.uid ?? '';
        _memberSince = firebaseUser?.metadata.creationTime;
        _loading = false;
      });
    } catch (e) {
      final firebaseUser = _authService.currentUser;
      setState(() {
        _displayName = firebaseUser?.displayName ?? 'Guest User';
        _email = firebaseUser?.email ?? '';
        _phoneNumber = firebaseUser?.phoneNumber ?? '';
        _photoUrl = firebaseUser?.photoURL;
        _userId = firebaseUser?.uid ?? '';
        _memberSince = firebaseUser?.metadata.creationTime;
        _loading = false;
      });
    }
  }

  Future<void> _handleLogout() async {
    final isDark = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;

    // Show confirmation dialog
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF32281E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Log Out',
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF181411),
          ),
        ),
        content: Text(
          'Are you sure you want to log out?',
          style: TextStyle(
            color: (isDark ? Colors.white : Colors.black).withOpacity(0.6),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: (isDark ? Colors.white : Colors.black).withOpacity(0.6),
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      await _authService.signOut();
      // Navigate to login screen or handle logout
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get theme state - UPDATED TO USE THEME COLORS
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF221910) : const Color(0xFFF8F7F5),
      body: SafeArea(
        child: Column(
          children: [
            // Header Section
            Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF32281E) : Colors.white,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 56, 24, 32),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome back,',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: (isDark ? Colors.white : Colors.black).withOpacity(0.6),
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          _loading
                              ? SizedBox(
                            height: 32,
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
                            _displayName ?? 'Guest User',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : const Color(0xFF181411),
                              letterSpacing: -0.5,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Profile Picture
                    Stack(
                      children: [
                        Container(
                          height: 64,
                          width: 64,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Color(0xFFF48C25), Color(0xFFFFCC80)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFF48C25).withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(3),
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isDark ? const Color(0xFF221910) : Colors.white,
                            ),
                            child: _photoUrl != null
                                ? ClipOval(
                              child: Image.network(
                                _photoUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(
                                    Icons.person_rounded,
                                    size: 36,
                                    color: (isDark ? Colors.white : Colors.black).withOpacity(0.6),
                                  );
                                },
                              ),
                            )
                                : Icon(
                              Icons.person_rounded,
                              size: 36,
                              color: (isDark ? Colors.white : Colors.black).withOpacity(0.6),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            height: 20,
                            width: 20,
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981),
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
              ),
            ),

            // Main Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Account Overview Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Account Overview',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : const Color(0xFF181411),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            // Edit profile action
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFFF48C25),
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(0, 0),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'Edit Profile',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Menu Grid
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 20,
                      crossAxisSpacing: 20,
                      childAspectRatio: 0.85,
                      children: [
                        _buildMenuCard(
                          icon: Icons.directions_car_rounded,
                          title: 'My Vehicles',
                          subtitle: 'Manage your garage',
                          color: const Color(0xFF3B82F6),
                          lightColor: const Color(0xFFEFF6FF),
                          darkColor: const Color(0xFF1E3A8A),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const CarInfoPage()),
                            );
                          },
                          isDark: isDark,
                        ),
                        _buildMenuCard(
                          icon: Icons.credit_card_rounded,
                          title: 'Payment',
                          subtitle: 'Cards & history',
                          color: const Color(0xFF8B5CF6),
                          lightColor: const Color(0xFFF5F3FF),
                          darkColor: const Color(0xFF5B21B6),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const PaymentMethodScreen()),
                            );
                          },
                          isDark: isDark,
                        ),
                        _buildMenuCard(
                          icon: Icons.settings_rounded,
                          title: 'Settings',
                          subtitle: 'App preferences',
                          color: const Color(0xFF64748B),
                          lightColor: const Color(0xFFF1F5F9),
                          darkColor: const Color(0xFF334155),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const SettingPage()),
                            );
                          },
                          isDark: isDark,
                        ),
                        _buildMenuCard(
                          icon: Icons.support_agent_rounded,
                          title: 'Support',
                          subtitle: '24/7 Assistance',
                          color: const Color(0xFFF48C25),
                          lightColor: const Color(0xFFFFF3E0),
                          darkColor: const Color(0xFF92400E),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const MessagesScreen()),
                            );
                          },
                          isDark: isDark,
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Log Out Button
                    Center(
                      child: TextButton.icon(
                        onPressed: _handleLogout,
                        icon: const Icon(
                          Icons.logout_rounded,
                          size: 20,
                          color: Color(0xFFEF4444),
                        ),
                        label: const Text(
                          'Log Out',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFEF4444),
                          ),
                        ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          backgroundColor: Colors.transparent,
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

  Widget _buildMenuCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required Color lightColor,
    required Color darkColor,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Material(
      color: isDark ? const Color(0xFF32281E) : Colors.white,
      borderRadius: BorderRadius.circular(32),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(32),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.05)
                  : const Color(0xFFF9FAFB),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
                blurRadius: 40,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Icon and Arrow Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    height: 56,
                    width: 56,
                    decoration: BoxDecoration(
                      color: isDark ? darkColor : lightColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      icon,
                      color: color,
                      size: 28,
                    ),
                  ),
                  Container(
                    height: 32,
                    width: 32,
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF221910)
                          : const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: (isDark ? Colors.white : Colors.black).withOpacity(0.4),
                      size: 14,
                    ),
                  ),
                ],
              ),

              // Title and Subtitle
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF181411),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: (isDark ? Colors.white : Colors.black).withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}