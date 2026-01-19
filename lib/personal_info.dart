// ============================================
// ACCOUNT PAGE - Updated with Firebase
// ============================================

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:your_app_name/payment_methods.dart';
import 'car_info_page.dart';
import 'setting.dart';
import 'msg_screens.dart';
import 'T_S.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _displayName;
  String? _email;
  String? _phoneNumber;
  String? _photoUrl;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _loading = true;
    });

    try {
      // Get current user from Firebase Auth
      User? currentUser = _auth.currentUser;

      if (currentUser == null) {
        setState(() {
          _displayName = 'Guest User';
          _email = '';
          _loading = false;
        });
        return;
      }

      // Try to get user data from Firestore first
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (userDoc.exists) {
        // Data exists in Firestore
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        setState(() {
          _displayName = userData['name'] ?? userData['displayName'] ?? currentUser.displayName ?? 'User';
          _email = userData['email'] ?? currentUser.email ?? '';
          _phoneNumber = userData['phone'] ?? userData['phoneNumber'] ?? currentUser.phoneNumber;
          _photoUrl = userData['photoUrl'] ?? currentUser.photoURL;
          _loading = false;
        });
      } else {
        // Fallback to Firebase Auth data if Firestore document doesn't exist
        setState(() {
          _displayName = currentUser.displayName ?? 'User';
          _email = currentUser.email ?? '';
          _phoneNumber = currentUser.phoneNumber;
          _photoUrl = currentUser.photoURL;
          _loading = false;
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
      // Fallback to Firebase Auth
      User? currentUser = _auth.currentUser;
      setState(() {
        _displayName = currentUser?.displayName ?? 'User';
        _email = currentUser?.email ?? '';
        _phoneNumber = currentUser?.phoneNumber;
        _photoUrl = currentUser?.photoURL;
        _loading = false;
      });
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
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFFF9800), Color(0xFFFFB74D)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
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
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const ProfileInfoScreen(),
                                  ),
                                ).then((_) => _loadUserData()); // Reload data when returning
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
                      child: Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFF9800), Color(0xFFFFB74D)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFFF9800).withOpacity(0.3),
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
                                // Show email and phone if available so fields are used
                                if (!_loading && (_email != null && _email!.isNotEmpty))
                                  Text(
                                    _email!,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                if (!_loading && (_phoneNumber != null && _phoneNumber!.isNotEmpty))
                                  Padding(
                                    padding: const EdgeInsets.only(top: 6),
                                    child: Text(
                                      _phoneNumber!,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ),
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
                        value: '12',
                        colors: [const Color(0xFFFF9800), const Color(0xFFFFB74D)],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.history_rounded,
                        label: 'History',
                        value: '8',
                        colors: [const Color(0xFFFFB74D), const Color(0xFFFFCC80)],
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
                      gradientColors: [const Color(0xFFFF9800), const Color(0xFFFFB74D)],
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
                      gradientColors: [const Color(0xFFFF9800), const Color(0xFFFFB74D)],
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const PaymentMethodScreen()),
                        );
                      },
                    ),

                    _buildMenuButton(
                      icon: Icons.settings_rounded,
                      label: "Settings",
                      gradientColors: [const Color(0xFFFF9800), const Color(0xFFFFB74D)],
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
                      gradientColors: [const Color(0xFFFF9800), const Color(0xFFFFB74D)],
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
                      gradientColors: [const Color(0xFFFF9800), const Color(0xFFFFB74D)],
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

// ============================================
// PROFILE INFO SCREEN - Updated with Firebase
// ============================================

class ProfileInfoScreen extends StatefulWidget {
  const ProfileInfoScreen({super.key});

  @override
  State<ProfileInfoScreen> createState() => _ProfileInfoScreenState();
}

class _ProfileInfoScreenState extends State<ProfileInfoScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _loading = true;
    });

    try {
      User? currentUser = _auth.currentUser;

      if (currentUser == null) {
        setState(() {
          _loading = false;
        });
        return;
      }

      // Try to get user data from Firestore
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        _nameController.text = userData['name'] ?? userData['displayName'] ?? '';
        _emailController.text = userData['email'] ?? currentUser.email ?? '';
        _phoneController.text = userData['phone'] ?? userData['phoneNumber'] ?? '';
      } else {
        // Fallback to Firebase Auth data
        _nameController.text = currentUser.displayName ?? '';
        _emailController.text = currentUser.email ?? '';
        _phoneController.text = currentUser.phoneNumber ?? '';
      }

      setState(() {
        _loading = false;
      });
    } catch (e) {
      print('Error loading user data: $e');
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      User? currentUser = _auth.currentUser;

      if (currentUser == null) {
        throw Exception('No user logged in');
      }

      // Update Firestore
      await _firestore.collection('users').doc(currentUser.uid).set({
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Update Firebase Auth display name
      await currentUser.updateDisplayName(_nameController.text.trim());

      // Update email if changed
      if (_emailController.text.trim() != currentUser.email) {
        await currentUser.updateEmail(_emailController.text.trim());
      }

      setState(() {
        _saving = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Profile updated successfully'),
            backgroundColor: Colors.green[400],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        Navigator.pop(context); // Go back to account page
      }
    } catch (e) {
      setState(() {
        _saving = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile: ${e.toString()}'),
            backgroundColor: Colors.red[400],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
            'Profile Information',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 18,
            )
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFFFF9800),
                Colors.orange[300]!,
              ],
            ),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
            child: ElevatedButton(
              onPressed: _saving ? null : _saveProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFFFF9800),
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: _saving
                  ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFFFF9800),
                ),
              )
                  : const Text(
                'Save',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFFF9800),
              Colors.orange[300]!,
              Colors.grey[50]!,
            ],
            stops: const [0.0, 0.3, 1.0],
          ),
        ),
        child: SafeArea(
          child: _loading
              ? const Center(child: CircularProgressIndicator(color: Colors.white))
              : SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _buildProfileAvatar(),
                  const SizedBox(height: 40),
                  _buildFormCard(),
                  const SizedBox(height: 24),
                  _buildChangePasswordButton(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileAvatar() {
    User? currentUser = _auth.currentUser;
    String? photoUrl = currentUser?.photoURL;

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 5,
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: photoUrl == null
                  ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.orange[100]!,
                  Colors.orange[50]!,
                ],
              )
                  : null,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4),
              image: photoUrl != null
                  ? DecorationImage(
                image: NetworkImage(photoUrl),
                fit: BoxFit.cover,
              )
                  : null,
            ),
            child: photoUrl == null
                ? const Icon(
              Icons.person,
              size: 60,
              color: Color(0xFFFF9800),
            )
                : null,
          ),
          Positioned(
            bottom: 5,
            right: 5,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [const Color(0xFFFF9800), Colors.orange[400]!],
                ),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.camera_alt, size: 20, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            spreadRadius: 0,
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildFormField(
            label: 'Full Name',
            controller: _nameController,
            icon: Icons.person_outline_rounded,
          ),
          const SizedBox(height: 20),
          _buildFormField(
            label: 'Email Address',
            controller: _emailController,
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 20),
          _buildFormField(
            label: 'Phone Number',
            controller: _phoneController,
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
          ),
        ],
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF9800).withOpacity(0.1),
                spreadRadius: 0,
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            style: TextStyle(
              color: Colors.grey[800],
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              prefixIcon: Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [const Color(0xFFFF9800), Colors.orange[300]!],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.orange[100]!, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFFFF9800), width: 2),
              ),
              filled: true,
              fillColor: Colors.orange[50]?.withOpacity(0.3),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter $label';
              }
              if (label == 'Email Address' && !value.contains('@')) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildChangePasswordButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF9800).withOpacity(0.2),
            spreadRadius: 0,
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: OutlinedButton(
        onPressed: () {
          // TODO: Implement change password functionality
          _showChangePasswordDialog();
        },
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 18),
          side: const BorderSide(color: Color(0xFFFF9800), width: 2),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock_outline_rounded,
              color: Color(0xFFFF9800),
              size: 20,
            ),
            SizedBox(width: 8),
            Text(
              'Change Password',
              style: TextStyle(
                color: Color(0xFFFF9800),
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showChangePasswordDialog() {
    final TextEditingController currentPasswordController = TextEditingController();
    final TextEditingController newPasswordController = TextEditingController();
    final TextEditingController confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Current Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'New Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirm New Password',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (newPasswordController.text != confirmPasswordController.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Passwords do not match')),
                );
                return;
              }

              try {
                User? user = _auth.currentUser;
                if (user != null && user.email != null) {
                  // Re-authenticate user
                  AuthCredential credential = EmailAuthProvider.credential(
                    email: user.email!,
                    password: currentPasswordController.text,
                  );
                  await user.reauthenticateWithCredential(credential);

                  // Update password
                  await user.updatePassword(newPasswordController.text);

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Password changed successfully'),
                      backgroundColor: Colors.green[400],
                    ),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: ${e.toString()}'),
                    backgroundColor: Colors.red[400],
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF9800),
            ),
            child: const Text('Change Password'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}
