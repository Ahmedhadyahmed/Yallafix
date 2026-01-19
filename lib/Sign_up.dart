import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Sign Up screen widget for creating new user accounts with Firebase Authentication
/// Includes comprehensive form validation and user feedback
class FirebaseSignUpScreen extends StatefulWidget {
  const FirebaseSignUpScreen({super.key});

  @override
  State<FirebaseSignUpScreen> createState() => _FirebaseSignUpScreenState();
}

class _FirebaseSignUpScreenState extends State<FirebaseSignUpScreen> {
  // ==================== STATE VARIABLES ====================
  // Toggle variables for password visibility (show/hide password text)
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  // Loading state for sign-up button
  bool _isLoading = false;

  // ==================== TEXT CONTROLLERS ====================
  // Controllers to manage text input for all form fields
  final TextEditingController nameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  // ==================== ERROR MESSAGE VARIABLES ====================
  // Store validation error messages for each field
  // null means no error, String means there's an error to display
  String? nameError;
  String? usernameError;
  String? emailError;
  String? passwordError;
  String? confirmPasswordError;

  // ==================== ALLOWED EMAIL DOMAINS ====================
  // Whitelist of email providers for security and quality control
  // Only emails from these domains will be accepted during sign-up
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

  /// Cleanup method - disposes all controllers when widget is removed
  /// Prevents memory leaks by releasing resources
  @override
  void dispose() {
    nameController.dispose();
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  // ==================== EMAIL VALIDATION ====================
  /// Validates email format and checks against allowed domain list
  /// Returns true if email is valid and from an allowed provider
  bool isValidEmail(String email) {
    // Regular expression to validate email format
    // Pattern: letters/numbers/special chars @ domain . extension
    final RegExp emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    // First check: Does it match email format?
    if (!emailRegex.hasMatch(email)) {
      return false;
    }

    // Second check: Is the domain in our allowed list?
    String domain = email.split('@').last.toLowerCase(); // Extract domain (e.g., "gmail.com")
    return allowedEmailDomains.contains(domain);
  }

  // ==================== ENHANCED PASSWORD VALIDATION ====================
  /// Validates password strength with multiple criteria
  /// Returns Map with 'isValid' boolean and 'errors' list
  Map<String, dynamic> validatePasswordStrength(String password) {
    List<String> errors = [];

    // Minimum length requirement
    if (password.length < 8) {
      errors.add('At least 8 characters');
    }

    // Maximum length check (prevent extremely long passwords)
    if (password.length > 64) {
      errors.add('Maximum 64 characters');
    }

    // Must contain at least one uppercase letter (A-Z)
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      errors.add('One uppercase letter');
    }

    // Must contain at least one lowercase letter (a-z)
    if (!RegExp(r'[a-z]').hasMatch(password)) {
      errors.add('One lowercase letter');
    }

    // Must contain at least one number (0-9)
    if (!RegExp(r'[0-9]').hasMatch(password)) {
      errors.add('One number');
    }

    // Must contain at least one special character
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
      errors.add('One special character (!@#\$%^&*)');
    }

    return {
      'isValid': errors.isEmpty,
      'errors': errors,
    };
  }

  /// Simple password validation (minimum length only)
  /// Used as fallback for basic validation
  bool isValidPassword(String password) {
    return password.length >= 6;
  }

  // ==================== FORM VALIDATION ====================
  /// Validates all form fields and updates error messages
  /// Returns true if all fields are valid, false otherwise
  bool validateForm() {
    bool isValid = true;

    // Reset all error messages before validation
    setState(() {
      nameError = null;
      usernameError = null;
      emailError = null;
      passwordError = null;
      confirmPasswordError = null;

      // ========== NAME VALIDATION ==========
      if (nameController.text.trim().isEmpty) {
        nameError = 'Name is required';
        isValid = false;
      } else if (nameController.text.trim().length < 2) {
        nameError = 'Name must be at least 2 characters';
        isValid = false;
      }

      // ========== USERNAME VALIDATION ==========
      if (usernameController.text.trim().isEmpty) {
        usernameError = 'Username is required';
        isValid = false;
      } else if (usernameController.text.trim().length < 3) {
        usernameError = 'Username must be at least 3 characters';
        isValid = false;
      } else if (usernameController.text.contains(' ')) {
        usernameError = 'Username cannot contain spaces';
        isValid = false;
      }

      // ========== EMAIL VALIDATION ==========
      if (emailController.text.trim().isEmpty) {
        emailError = 'Email is required';
        isValid = false;
      } else if (!isValidEmail(emailController.text.trim())) {
        // Check if it's a basic format issue or domain issue
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

      // ========== PASSWORD VALIDATION (ENHANCED) ==========
      if (passwordController.text.isEmpty) {
        passwordError = 'Password is required';
        isValid = false;
      } else {
        // Use enhanced password validation
        var passwordValidation = validatePasswordStrength(passwordController.text);

        if (!passwordValidation['isValid']) {
          // Combine all error messages into one string
          List<String> errors = passwordValidation['errors'];
          passwordError = 'Password must contain:\n• ${errors.join('\n• ')}';
          isValid = false;
        }
      }

      // ========== CONFIRM PASSWORD VALIDATION ==========
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

  // ==================== NAVIGATION ====================
  /// Navigate back to login screen
  void _navigateToLogin() {
    Navigator.of(context).pop();
  }

  // ==================== FIREBASE SIGN UP HANDLER ====================
  /// Handles user registration with Firebase Authentication
  /// Creates new user account and updates display name
  Future<void> handleSignUp() async {
    // Validate form before proceeding
    if (!validateForm()) {
      return; // Exit if validation fails
    }

    // Show loading state
    setState(() {
      _isLoading = true;
    });

    try {
      // Create new user account with Firebase Authentication
      // This communicates with Firebase backend to register the user
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // Update the user's display name in Firebase Auth profile
      // This allows us to greet them by name when they log in
      await userCredential.user?.updateDisplayName(nameController.text.trim());

      // Check if widget is still mounted before showing UI elements
      if (mounted) {
        // Show success notification
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account created successfully! You can now log in.'),
            backgroundColor: Color(0xFFFF7A00), // Orange theme color
            duration: Duration(seconds: 2),
          ),
        );

        // Wait 2 seconds for user to see the success message
        await Future.delayed(const Duration(seconds: 2));

        // Navigate back to login screen after successful registration
        if (mounted) {
          _navigateToLogin();
        }
      }
    } on FirebaseAuthException catch (e) {
      // Handle Firebase-specific authentication errors
      if (mounted) {
        String errorMessage;

        // Map Firebase error codes to user-friendly messages
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
          // Fallback for any other Firebase errors
            errorMessage = 'Sign up failed: ${e.message}';
        }

        // Display error dialog
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Sign Up Failed'),
              content: Text(errorMessage),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      // Catch any other unexpected errors (network issues, etc.)
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
      // Always hide loading indicator after sign-up attempt completes
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ==================== BUILD UI ====================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // Prevents keyboard from covering input fields
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Stack(
          children: [
            // ==================== MAIN SCROLLABLE CONTENT ====================
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

                        // ==================== TITLE ====================
                        const Text(
                          'Sign Up',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFFF7A00), // Orange brand color
                            letterSpacing: -0.5,
                          ),
                        ),

                        const SizedBox(height: 30),

                        // ==================== NAME FIELD ====================
                        const Text(
                          'Name:',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF374151), // Dark grey label
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFE5E7EB), // Light grey background
                            borderRadius: BorderRadius.circular(25),
                            // Show red border if there's an error
                            border: nameError != null
                                ? Border.all(color: Colors.red, width: 1)
                                : null,
                          ),
                          child: TextField(
                            controller: nameController,
                            decoration: const InputDecoration(
                              hintText: 'Enter your full name...',
                              hintStyle: TextStyle(
                                color: Color(0xFF9CA3AF), // Grey hint text
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                              border: InputBorder.none, // No default border
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 16,
                              ),
                            ),
                          ),
                        ),
                        // Display error message below field if validation fails
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

                        // ==================== USERNAME FIELD ====================
                        const Text(
                          'Username:',
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
                            border: usernameError != null
                                ? Border.all(color: Colors.red, width: 1)
                                : null,
                          ),
                          child: TextField(
                            controller: usernameController,
                            decoration: const InputDecoration(
                              hintText: 'Enter your username...',
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
                        if (usernameError != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 5, left: 20),
                            child: Text(
                              usernameError!,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 12,
                              ),
                            ),
                          ),

                        const SizedBox(height: 16),

                        // ==================== EMAIL FIELD ====================
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
                            keyboardType: TextInputType.emailAddress, // Email keyboard layout
                            decoration: const InputDecoration(
                              hintText: 'Enter your email (Gmail, Yahoo, etc.)...',
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

                        // ==================== PASSWORD FIELD ====================
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
                            obscureText: obscurePassword, // Hide password characters
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
                              // Toggle button to show/hide password
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
                        // Display password error message (can be multi-line)
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

                        // ==================== CONFIRM PASSWORD FIELD ====================
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
                              // Separate toggle for confirm password visibility
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

                        // ==================== CONFIRM BUTTON ====================
                        // Primary action button with gradient and shadow
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
                            // Disable button while loading
                            onPressed: _isLoading ? null : handleSignUp,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            // Show loading spinner or "Confirm" text
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
                              'Confirm',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // ==================== BACK TO LOGIN LINK ====================
                        // Clickable link to navigate back to login screen
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
                                // Rich text with styled "Login" word
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