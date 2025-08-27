import 'package:flutter/material.dart';
import 'firebase_auth_service.dart';

class FirebaseSignUpScreen extends StatefulWidget {
  const FirebaseSignUpScreen({Key? key}) : super(key: key);

  @override
  State<FirebaseSignUpScreen> createState() => _FirebaseSignUpScreenState();
}

class _FirebaseSignUpScreenState extends State<FirebaseSignUpScreen> {
  bool rememberMe = false;
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  bool _isLoading = false;

  // Controllers for form fields
  final TextEditingController nameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  // Error messages
  String? nameError;
  String? usernameError;
  String? emailError;
  String? passwordError;
  String? confirmPasswordError;

  final FirebaseAuthService _authService = FirebaseAuthService();

  @override
  void dispose() {
    nameController.dispose();
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  // Email validation function
  bool isValidEmail(String email) {
    final RegExp emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  // Password validation function
  bool isValidPassword(String password) {
    // Password should be at least 6 characters (Firebase minimum)
    return password.length >= 6;
  }

  // Form validation function
  bool validateForm() {
    bool isValid = true;
    setState(() {
      // Clear previous errors
      nameError = null;
      usernameError = null;
      emailError = null;
      passwordError = null;
      confirmPasswordError = null;

      // Name validation
      if (nameController.text.trim().isEmpty) {
        nameError = 'Name is required';
        isValid = false;
      } else if (nameController.text.trim().length < 2) {
        nameError = 'Name must be at least 2 characters';
        isValid = false;
      }

      // Username validation
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

      // Email validation
      if (emailController.text.trim().isEmpty) {
        emailError = 'Email is required';
        isValid = false;
      } else if (!isValidEmail(emailController.text.trim())) {
        emailError = 'Please enter a valid email address';
        isValid = false;
      }

      // Password validation
      if (passwordController.text.isEmpty) {
        passwordError = 'Password is required';
        isValid = false;
      } else if (!isValidPassword(passwordController.text)) {
        passwordError = 'Password must be at least 6 characters';
        isValid = false;
      }

      // Confirm password validation
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

  // Handle form submission with Firebase
  Future<void> handleSignUp() async {
    if (!validateForm()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = await _authService.signUpWithEmailAndPassword(
        name: nameController.text.trim(),
        username: usernameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (user != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account created successfully! You can now log in.'),
            backgroundColor: Color(0xFFFF7A00),
            duration: Duration(seconds: 2),
          ),
        );

        // Add a delay before navigating back to login screen
        await Future.delayed(const Duration(milliseconds: 1500));

        if (mounted) {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = e.toString();

        // Clean up error messages
        if (errorMessage.contains('Exception: ')) {
          errorMessage = errorMessage.replaceFirst('Exception: ', '');
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
      body: SafeArea(
        child: Stack(
          children: [
            // Main content
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),

                  // Title
                  const Text(
                    'Sign Up',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFFF7A00),
                      letterSpacing: -0.5,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Name field
                  const Text(
                    'Name:',
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
                      decoration: InputDecoration(
                        hintText: 'Enter your full name...',
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

                  const SizedBox(height: 20),

                  // Username field
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
                      decoration: InputDecoration(
                        hintText: 'Enter your username...',
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

                  const SizedBox(height: 20),

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
                      decoration: InputDecoration(
                        hintText: 'Enter your email...',
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

                  const SizedBox(height: 20),

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

                  const SizedBox(height: 20),

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

                  const SizedBox(height: 40),

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
                        'Confirm',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Already have an account
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: RichText(
                        text: const TextSpan(
                          text: 'Already have an account ? ',
                          style: TextStyle(
                            color: Color(0xFF374151),
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                          children: [
                            TextSpan(
                              text: 'Login',
                              style: TextStyle(
                                color: Color(0xFFFF7A00),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 120),
                ],
              ),
            ),

            // Bottom decorative curve
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: CustomPaint(
                size: Size(MediaQuery.of(context).size.width, 120),
                painter: BottomCurvePainter(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BottomCurvePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // First layer - lightest orange
    final paint1 = Paint()
      ..color = const Color(0xFFFFF2E6)
      ..style = PaintingStyle.fill;

    final path1 = Path();
    path1.moveTo(0, size.height);
    path1.lineTo(0, size.height * 0.6);
    path1.quadraticBezierTo(
      size.width * 0.3,
      size.height * 0.2,
      size.width * 0.7,
      size.height * 0.5,
    );
    path1.quadraticBezierTo(
      size.width * 0.85,
      size.height * 0.6,
      size.width,
      size.height * 0.4,
    );
    path1.lineTo(size.width, size.height);
    path1.close();

    // Second layer - medium orange
    final paint2 = Paint()
      ..color = const Color(0xFFFFE4CC)
      ..style = PaintingStyle.fill;

    final path2 = Path();
    path2.moveTo(0, size.height);
    path2.lineTo(0, size.height * 0.75);
    path2.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.35,
      size.width * 0.6,
      size.height * 0.6,
    );
    path2.quadraticBezierTo(
      size.width * 0.8,
      size.height * 0.7,
      size.width,
      size.height * 0.55,
    );
    path2.lineTo(size.width, size.height);
    path2.close();

    // Third layer - darker orange
    final paint3 = Paint()
      ..color = const Color(0xFFFFD4A6)
      ..style = PaintingStyle.fill;

    final path3 = Path();
    path3.moveTo(0, size.height);
    path3.lineTo(0, size.height * 0.85);
    path3.quadraticBezierTo(
      size.width * 0.2,
      size.height * 0.5,
      size.width * 0.5,
      size.height * 0.75,
    );
    path3.quadraticBezierTo(
      size.width * 0.75,
      size.height * 0.85,
      size.width,
      size.height * 0.7,
    );
    path3.lineTo(size.width, size.height);
    path3.close();

    // Draw all layers
    canvas.drawPath(path1, paint1);
    canvas.drawPath(path2, paint2);
    canvas.drawPath(path3, paint3);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}