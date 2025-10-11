import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ServiceProviderSignUpScreen extends StatefulWidget {
  const ServiceProviderSignUpScreen({Key? key}) : super(key: key);

  @override
  State<ServiceProviderSignUpScreen> createState() => _ServiceProviderSignUpScreenState();
}

class _ServiceProviderSignUpScreenState extends State<ServiceProviderSignUpScreen> {
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  bool _isLoading = false;

  // Controllers for form fields
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  // Error messages
  String? nameError;
  String? phoneError;
  String? emailError;
  String? passwordError;
  String? confirmPasswordError;

  // List of allowed email domains
  final List<String> allowedEmailDomains = [
    'gmail.com',
    'yahoo.com',
    'yahoo.co.uk',
    'yahoo.ca',
    'yahoo.com.au',
    'outlook.com',
    'hotmail.com',
    'live.com',
    'msn.com',
    'icloud.com',
    'me.com',
    'mac.com',
    'aol.com',
    'protonmail.com',
    'mail.com',
    'zoho.com',
  ];

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  // Enhanced email validation function
  bool isValidEmail(String email) {
    final RegExp emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(email)) {
      return false;
    }

    String domain = email.split('@').last.toLowerCase();
    return allowedEmailDomains.contains(domain);
  }

  // Phone validation function
  bool isValidPhone(String phone) {
    // Remove any spaces, dashes, or parentheses
    String cleanPhone = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');

    // Check if it contains only digits and optionally starts with +
    final RegExp phoneRegex = RegExp(r'^\+?[0-9]{10,15}$');
    return phoneRegex.hasMatch(cleanPhone);
  }

  // Password validation function
  bool isValidPassword(String password) {
    return password.length >= 6;
  }

  // Form validation function
  bool validateForm() {
    bool isValid = true;
    setState(() {
      nameError = null;
      phoneError = null;
      emailError = null;
      passwordError = null;
      confirmPasswordError = null;

      if (nameController.text.trim().isEmpty) {
        nameError = 'Name is required';
        isValid = false;
      } else if (nameController.text.trim().length < 2) {
        nameError = 'Name must be at least 2 characters';
        isValid = false;
      }

      if (phoneController.text.trim().isEmpty) {
        phoneError = 'Phone number is required';
        isValid = false;
      } else if (!isValidPhone(phoneController.text.trim())) {
        phoneError = 'Please enter a valid phone number (10-15 digits)';
        isValid = false;
      }

      if (emailController.text.trim().isEmpty) {
        emailError = 'Email is required';
        isValid = false;
      } else if (!isValidEmail(emailController.text.trim())) {
        final RegExp basicEmailRegex = RegExp(
          r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
        );
        if (!basicEmailRegex.hasMatch(emailController.text.trim())) {
          emailError = 'Please enter a valid email address';
        } else {
          emailError = 'Please use Gmail, Yahoo, Outlook, or other popular email providers';
        }
        isValid = false;
      }

      if (passwordController.text.isEmpty) {
        passwordError = 'Password is required';
        isValid = false;
      } else if (!isValidPassword(passwordController.text)) {
        passwordError = 'Password must be at least 6 characters';
        isValid = false;
      }

      if (confirmPasswordController.text.isEmpty) {
        confirmPasswordError = 'Please confirm your password';
        isValid = false;
      } else if (passwordController.text != confirmPasswordController.text) {
        confirmPasswordError = 'Passwords do not match';
        isValid = false;
      }
    });

    return isValid;
  }

  // Navigate back to login screen
  void _navigateToLogin() {
    Navigator.of(context).pop();
  }

  // Firebase Auth signup for service providers
  Future<void> handleSignUp() async {
    if (!validateForm()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Direct Firebase Auth signup
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // Update display name
      await userCredential.user?.updateDisplayName(nameController.text.trim());

      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Service provider account created successfully! You can now log in.'),
            backgroundColor: Color(0xFFFF7A00),
            duration: Duration(seconds: 2),
          ),
        );

        // Wait exactly 2 seconds then navigate to login
        await Future.delayed(const Duration(seconds: 2));

        if (mounted) {
          _navigateToLogin();
        }
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        String errorMessage;

        switch (e.code) {
          case 'email-already-in-use':
            errorMessage = 'This email is already registered. Please use a different email or try logging in.';
            break;
          case 'weak-password':
            errorMessage = 'Password is too weak. Please choose a stronger password.';
            break;
          case 'invalid-email':
            errorMessage = 'Please enter a valid email address.';
            break;
          default:
            errorMessage = 'Sign up failed: ${e.message}';
        }

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Sign Up Failed'),
              content: Text(errorMessage),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Sign Up Failed'),
              content: Text('An unexpected error occurred: ${e.toString()}'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Stack(
          children: [
            // Main content
            LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 30),

                        // Title
                        const Text(
                          'Service Provider Sign Up',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFFF7A00),
                            letterSpacing: -0.5,
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Subtitle
                        const Text(
                          'Register your business account',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF6B7280),
                          ),
                        ),

                        const SizedBox(height: 30),

                        // Name field
                        const Text(
                          'Business/Provider Name:',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF374151),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFE5E7EB),
                            borderRadius: BorderRadius.circular(25),
                            border: nameError != null
                                ? Border.all(color: Colors.red, width: 1)
                                : null,
                          ),
                          child: TextField(
                            controller: nameController,
                            decoration: const InputDecoration(
                              hintText: 'Enter business or provider name...',
                              hintStyle: TextStyle(
                                color: Color(0xFF9CA3AF),
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 16,
                              ),
                            ),
                          ),
                        ),
                        if (nameError != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 5, left: 20),
                            child: Text(
                              nameError!,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 12,
                              ),
                            ),
                          ),

                        const SizedBox(height: 16),

                        // Phone field
                        const Text(
                          'Phone Number:',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF374151),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFE5E7EB),
                            borderRadius: BorderRadius.circular(25),
                            border: phoneError != null
                                ? Border.all(color: Colors.red, width: 1)
                                : null,
                          ),
                          child: TextField(
                            controller: phoneController,
                            keyboardType: TextInputType.phone,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'[0-9+\-\s\(\)]')),
                            ],
                            decoration: const InputDecoration(
                              hintText: 'Enter phone number...',
                              hintStyle: TextStyle(
                                color: Color(0xFF9CA3AF),
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 16,
                              ),
                              prefixIcon: Icon(
                                Icons.phone_outlined,
                                color: Color(0xFF6B7280),
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                        if (phoneError != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 5, left: 20),
                            child: Text(
                              phoneError!,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 12,
                              ),
                            ),
                          ),

                        const SizedBox(height: 16),

                        // Email field
                        const Text(
                          'Email:',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF374151),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFE5E7EB),
                            borderRadius: BorderRadius.circular(25),
                            border: emailError != null
                                ? Border.all(color: Colors.red, width: 1)
                                : null,
                          ),
                          child: TextField(
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              hintText: 'Enter business email...',
                              hintStyle: TextStyle(
                                color: Color(0xFF9CA3AF),
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 16,
                              ),
                              prefixIcon: Icon(
                                Icons.email_outlined,
                                color: Color(0xFF6B7280),
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                        if (emailError != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 5, left: 20),
                            child: Text(
                              emailError!,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 12,
                              ),
                            ),
                          ),

                        const SizedBox(height: 16),

                        // Password field
                        const Text(
                          'Password:',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF374151),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFE5E7EB),
                            borderRadius: BorderRadius.circular(25),
                            border: passwordError != null
                                ? Border.all(color: Colors.red, width: 1)
                                : null,
                          ),
                          child: TextField(
                            controller: passwordController,
                            obscureText: obscurePassword,
                            decoration: InputDecoration(
                              hintText: 'Enter your password...',
                              hintStyle: const TextStyle(
                                color: Color(0xFF9CA3AF),
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 16,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  obscurePassword ? Icons.visibility_off : Icons.visibility,
                                  color: const Color(0xFF6B7280),
                                  size: 20,
                                ),
                                onPressed: () {
                                  setState(() {
                                    obscurePassword = !obscurePassword;
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                        if (passwordError != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 5, left: 20),
                            child: Text(
                              passwordError!,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 12,
                              ),
                            ),
                          ),

                        const SizedBox(height: 16),

                        // Confirm Password field
                        const Text(
                          'Confirm Password:',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF374151),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFE5E7EB),
                            borderRadius: BorderRadius.circular(25),
                            border: confirmPasswordError != null
                                ? Border.all(color: Colors.red, width: 1)
                                : null,
                          ),
                          child: TextField(
                            controller: confirmPasswordController,
                            obscureText: obscureConfirmPassword,
                            decoration: InputDecoration(
                              hintText: 'Enter password again...',
                              hintStyle: const TextStyle(
                                color: Color(0xFF9CA3AF),
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 16,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                                  color: const Color(0xFF6B7280),
                                  size: 20,
                                ),
                                onPressed: () {
                                  setState(() {
                                    obscureConfirmPassword = !obscureConfirmPassword;
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                        if (confirmPasswordError != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 5, left: 20),
                            child: Text(
                              confirmPasswordError!,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 12,
                              ),
                            ),
                          ),

                        const SizedBox(height: 30),

                        // Confirm button
                        Container(
                          width: double.infinity,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFF7A00), Color(0xFFE6590A)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFF7A00).withOpacity(0.3),
                                spreadRadius: 0,
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : handleSignUp,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                                : const Text(
                              'Register as Provider',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Already have an account
                        Center(
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                _navigateToLogin();
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFFFF7A00).withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: RichText(
                                  text: const TextSpan(
                                    text: 'Already have an account? ',
                                    style: TextStyle(
                                      color: Color(0xFF374151),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: 'Login',
                                        style: TextStyle(
                                          color: Color(0xFFFF7A00),
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}