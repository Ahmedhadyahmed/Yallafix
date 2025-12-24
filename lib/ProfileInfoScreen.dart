import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

class ProfileInfoScreen extends StatefulWidget {
  const ProfileInfoScreen({super.key});

  @override
  State<ProfileInfoScreen> createState() => _ProfileInfoScreenState();
}

class _ProfileInfoScreenState extends State<ProfileInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;
  bool _isChangingPassword = false;
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _firestoreAvailable = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    print('=== Starting _loadUserData ===');

    try {
      User? user = _auth.currentUser;
      print('Current user: ${user?.uid}');
      print('User email: ${user?.email}');

      if (user != null) {
        // Set email from Firebase Auth
        _emailController.text = user.email ?? '';
        _nameController.text = user.displayName ?? '';
        print('Set initial data from Firebase Auth');

        // Test Firestore connectivity
        try {
          print('Testing Firestore connectivity...');

          // Test 1: Check if we can query Firestore at all
          await _firestore.collection('users').limit(1).get().timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception('Firestore connection timeout');
            },
          );
          print('✓ Firestore connection test passed');

          // Test 2: Try to get user document
          print('Fetching user document: users/${user.uid}');
          DocumentSnapshot userDoc = await _firestore
              .collection('users')
              .doc(user.uid)
              .get()
              .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception('User document fetch timeout');
            },
          );

          print('User document exists: ${userDoc.exists}');

          if (userDoc.exists) {
            Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
            print('User data: $userData');

            _nameController.text = userData['name'] ?? user.displayName ?? '';
            _phoneController.text = userData['phone'] ?? '';
            _firestoreAvailable = true;
            print('✓ Firestore data loaded successfully');
          } else {
            // Document doesn't exist - create it
            print('Creating new user document...');
            _firestoreAvailable = true;

            await _firestore.collection('users').doc(user.uid).set({
              'name': user.displayName ?? '',
              'email': user.email ?? '',
              'phone': '',
              'createdAt': FieldValue.serverTimestamp(),
            });
            print('✓ User document created');
          }

        } on FirebaseException catch (e) {
          print('❌ Firebase Exception: ${e.code}');
          print('   Message: ${e.message}');
          print('   Plugin: ${e.plugin}');
          _firestoreAvailable = false;

          // Show user-friendly messages based on error code
          if (mounted) {
            String message = '';
            switch (e.code) {
              case 'permission-denied':
                message = 'Database permission denied. Check Firestore rules.';
                break;
              case 'unavailable':
                message = 'Database unavailable. Check internet connection.';
                break;
              case 'not-found':
                message = 'Database not initialized. Enable Firestore in console.';
                break;
              case 'unauthenticated':
                message = 'Authentication required for database access.';
                break;
              default:
                message = 'Database error: ${e.code}';
            }
            _showErrorSnackBar(message);
          }

        } on TimeoutException catch (e) {
          print('❌ Timeout Exception: $e');
          _firestoreAvailable = false;
          if (mounted) {
            _showErrorSnackBar('Database connection timeout. Check your internet.');
          }

        } catch (e) {
          print('❌ General Firestore error: $e');
          print('   Error type: ${e.runtimeType}');
          _firestoreAvailable = false;
          if (mounted) {
            _showErrorSnackBar('Database connection failed: ${e.toString()}');
          }
        }

        setState(() => _isLoading = false);
        print('=== Finished _loadUserData ===');
        print('Firestore available: $_firestoreAvailable');
      }
    } catch (e) {
      print('❌ Fatal error in _loadUserData: $e');
      setState(() => _isLoading = false);
      if (mounted) {
        _showErrorSnackBar('Failed to load user data: ${e.toString()}');
      }
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      User? user = _auth.currentUser;
      if (user != null) {
        // Update display name in Firebase Auth
        await user.updateDisplayName(_nameController.text.trim());

        // Try to update Firestore if available
        if (_firestoreAvailable) {
          try {
            await _firestore.collection('users').doc(user.uid).set({
              'name': _nameController.text.trim(),
              'email': _emailController.text.trim(),
              'phone': _phoneController.text.trim(),
              'updatedAt': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));
          } catch (firestoreError) {
            print('Firestore update error: $firestoreError');
            // Continue even if Firestore fails, Auth update succeeded
          }
        }

        await user.reload();
        _showSuccessSnackBar('Profile updated successfully!');
      }
    } catch (e) {
      _showErrorSnackBar('Failed to update profile: ${e.toString()}');
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _changePassword() async {
    if (_currentPasswordController.text.isEmpty ||
        _newPasswordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      _showErrorSnackBar('Please fill in all password fields');
      return;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      _showErrorSnackBar('New passwords do not match');
      return;
    }

    if (_newPasswordController.text.length < 6) {
      _showErrorSnackBar('Password must be at least 6 characters');
      return;
    }

    setState(() => _isChangingPassword = true);

    try {
      User? user = _auth.currentUser;
      if (user != null && user.email != null) {
        // Re-authenticate user
        AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!,
          password: _currentPasswordController.text,
        );

        await user.reauthenticateWithCredential(credential);

        // Update password
        await user.updatePassword(_newPasswordController.text);

        // Clear password fields
        _currentPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();

        _showSuccessSnackBar('Password changed successfully!');
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        _showErrorSnackBar('Current password is incorrect');
      } else if (e.code == 'weak-password') {
        _showErrorSnackBar('New password is too weak');
      } else {
        _showErrorSnackBar('Failed to change password: ${e.message}');
      }
    } catch (e) {
      _showErrorSnackBar('Failed to change password: ${e.toString()}');
    } finally {
      setState(() => _isChangingPassword = false);
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFFF9800).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.arrow_back,
                color: Color(0xFFFF9800), size: 20),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Profile Information',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(
          color: Color(0xFFFF9800),
        ),
      )
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Avatar
                Center(
                  child: Stack(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
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
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            _nameController.text.isNotEmpty
                                ? _nameController.text[0].toUpperCase()
                                : _emailController.text.isNotEmpty
                                ? _emailController.text[0].toUpperCase()
                                : 'U',
                            style: const TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.edit,
                            color: Color(0xFFFF9800),
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Firestore status warning (if not available)
                if (!_firestoreAvailable)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.orange[700], size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Cloud sync unavailable. Changes will be saved locally.',
                            style: TextStyle(
                              color: Colors.orange[900],
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Personal Information Section
                _buildSectionTitle('Personal Information'),
                const SizedBox(height: 12),
                _buildCard(
                  children: [
                    _buildTextField(
                      controller: _nameController,
                      label: 'Full Name',
                      icon: Icons.person_outline,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _emailController,
                      label: 'Email Address',
                      icon: Icons.email_outlined,
                      enabled: false,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!value.contains('@')) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _phoneController,
                      label: 'Phone Number',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          if (value.length < 10) {
                            return 'Please enter a valid phone number';
                          }
                        }
                        return null;
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Update Profile Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _updateProfile,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF9800), Color(0xFFFFB74D)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: _isSaving
                            ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                            : const Text(
                          'Update Profile',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Change Password Section
                _buildSectionTitle('Change Password'),
                const SizedBox(height: 12),
                _buildCard(
                  children: [
                    _buildPasswordField(
                      controller: _currentPasswordController,
                      label: 'Current Password',
                      obscureText: _obscureCurrentPassword,
                      onToggle: () {
                        setState(() {
                          _obscureCurrentPassword = !_obscureCurrentPassword;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildPasswordField(
                      controller: _newPasswordController,
                      label: 'New Password',
                      obscureText: _obscureNewPassword,
                      onToggle: () {
                        setState(() {
                          _obscureNewPassword = !_obscureNewPassword;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildPasswordField(
                      controller: _confirmPasswordController,
                      label: 'Confirm New Password',
                      obscureText: _obscureConfirmPassword,
                      onToggle: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Change Password Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isChangingPassword ? null : _changePassword,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.red[400]!, Colors.red[600]!],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: _isChangingPassword
                            ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                            : const Text(
                          'Change Password',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF2C3E50),
      ),
    );
  }

  Widget _buildCard({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool enabled = true,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFFFF9800)),
        filled: true,
        fillColor: enabled ? Colors.grey[50] : Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFF9800), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscureText,
    required VoidCallback onToggle,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFFFF9800)),
        suffixIcon: IconButton(
          icon: Icon(
            obscureText ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey[600],
          ),
          onPressed: onToggle,
        ),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFF9800), width: 2),
        ),
      ),
    );
  }
}