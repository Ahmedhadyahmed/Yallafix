import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'Sign_up.dart';
import 'forget_password.dart';

/// Main login screen widget using Firebase Authentication
/// This screen allows users to sign in with email and password
class FirebaseLoginScreen extends StatefulWidget {
  const FirebaseLoginScreen({Key? key, String? userType}) : super(key: key);

  @override
  State<FirebaseLoginScreen> createState() => _FirebaseLoginScreenState();
}

class _FirebaseLoginScreenState extends State<FirebaseLoginScreen> {
  // Controllers to manage text input for email and password fields
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Form key for validation (currently not actively used, but available for future validation)
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // State variable to show/hide loading indicator during login process
  bool _isLoading = false;

  // State variable to toggle password visibility (show/hide password text)
  bool _obscurePassword = true;

  /// Cleanup method - disposes controllers when widget is removed from widget tree
  /// This prevents memory leaks by releasing resources
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Main login handler - processes Firebase authentication
  /// Validates inputs, calls Firebase Auth, handles success/error states
  Future<void> _handleLogin() async {
    // Validation: Check if email or password fields are empty
    if (_emailController.text.trim().isEmpty || _passwordController.text.trim().isEmpty) {
      _showErrorDialog('Please fill in all fields');
      return; // Exit early if validation fails
    }

    // Show loading indicator by updating state
    setState(() {
      _isLoading = true;
    });

    try {
      // Call Firebase Authentication to sign in with email and password
      // This communicates with Firebase backend to verify credentials
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Check if login was successful and widget is still mounted (not disposed)
      if (userCredential.user != null && mounted) {
        // Get user's display name (or default to 'User' if not set)
        String userName = userCredential.user?.displayName ?? 'User';

        // Show success message with SnackBar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Welcome back, $userName!'),
            backgroundColor: const Color(0xFFFF7A00), // Orange theme color
            duration: const Duration(seconds: 2),
          ),
        );

        // Navigate to home screen and remove login screen from navigation stack
        // User cannot go back to login screen after successful login
        Navigator.pushReplacementNamed(context, '/home');
      }
    } on FirebaseAuthException catch (e) {
      // Handle Firebase-specific authentication errors
      if (mounted) {
        String errorMessage;

        // Map Firebase error codes to user-friendly messages
        switch (e.code) {
          case 'user-not-found':
            errorMessage = 'No account found with this email. Please sign up first.';
            break;
          case 'wrong-password':
            errorMessage = 'Incorrect password. Please try again.';
            break;
          case 'invalid-email':
            errorMessage = 'Please enter a valid email address.';
            break;
          case 'user-disabled':
            errorMessage = 'This account has been disabled.';
            break;
          case 'too-many-requests':
            errorMessage = 'Too many failed attempts. Please try again later.';
            break;
          default:
          // Fallback for any other Firebase errors
            errorMessage = 'Login failed: ${e.message}';
        }

        // Display error dialog with appropriate message
        _showErrorDialog(errorMessage);
      }
    } catch (e) {
      // Catch any other unexpected errors (network issues, etc.)
      if (mounted) {
        _showErrorDialog('An unexpected error occurred: ${e.toString()}');
      }
    } finally {
      // Always hide loading indicator after login attempt completes
      // Check if widget is still mounted before updating state
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Shows an error dialog with a custom message
  /// Used to display login errors and validation messages to the user
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Login Failed'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  /// Navigates to the Forgot Password screen
  /// Allows users to reset their password if they've forgotten it
  void _handleForgotPassword() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ForgotPasswordScreen(),
      ),
    );
  }

  /// Builds the UI for the login screen
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // Prevents keyboard from pushing content off screen
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // Main content area with safe area padding (avoids notch/status bar)
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            const SizedBox(height: 40),

                            // ==================== TITLE ====================
                            // Main heading "Login here" in orange
                            const Text(
                              'Login here',
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFFF7A00), // Orange brand color
                                letterSpacing: -0.5,
                              ),
                            ),

                            const SizedBox(height: 24),

                            // ==================== SUBTITLE ====================
                            // Welcome message below the title
                            const Text(
                              'Welcome back you\'ve\nbeen missed!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                                height: 1.4,
                                letterSpacing: 0.2,
                              ),
                            ),

                            const SizedBox(height: 40),

                            // ==================== EMAIL INPUT ====================
                            // Email text field with custom styling
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F4FF), // Light blue/grey background
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Stack(
                                children: [
                                  // Orange accent line on the left edge (decorative)
                                  Positioned(
                                    left: 0,
                                    top: 0,
                                    bottom: 0,
                                    child: Container(
                                      width: 4,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFFF7A00), // Orange accent
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(10),
                                          bottomLeft: Radius.circular(10),
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Actual text input field for email
                                  TextField(
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress, // Shows email keyboard
                                    decoration: const InputDecoration(
                                      hintText: 'Email',
                                      hintStyle: TextStyle(
                                        color: Color(0xFF9CA3AF), // Grey placeholder text
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400,
                                      ),
                                      border: InputBorder.none, // Remove default border
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 18,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 20),

                            // ==================== PASSWORD INPUT ====================
                            // Password field with show/hide toggle button
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F4FF), // Matching background
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: TextField(
                                controller: _passwordController,
                                obscureText: _obscurePassword, // Hides password characters
                                decoration: InputDecoration(
                                  hintText: 'Password',
                                  hintStyle: const TextStyle(
                                    color: Color(0xFF9CA3AF),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 18,
                                  ),
                                  // Eye icon button to toggle password visibility
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                      color: const Color(0xFF9CA3AF),
                                    ),
                                    onPressed: () {
                                      // Toggle password visibility on tap
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            // ==================== FORGOT PASSWORD LINK ====================
                            // Clickable text button aligned to the right
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: _handleForgotPassword,
                                child: const Text(
                                  'Forgot your password?',
                                  style: TextStyle(
                                    color: Color(0xFFFF7A00), // Orange link color
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 30),

                            // ==================== SIGN IN BUTTON ====================
                            // Primary action button with gradient and shadow
                            Container(
                              width: double.infinity,
                              height: 56,
                              decoration: BoxDecoration(
                                // Orange gradient for visual appeal
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFFF7A00), Color(0xFFE6590A)],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                                borderRadius: BorderRadius.circular(10),
                                // Drop shadow for depth effect
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
                                // Disable button when loading, otherwise call login handler
                                onPressed: _isLoading ? null : _handleLogin,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent, // Use gradient instead
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                // Show loading spinner or "Sign in" text based on state
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
                                  'Sign in',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            // ==================== CREATE ACCOUNT BUTTON ====================
                            // Secondary action button with border (outlined style)
                            Container(
                              width: double.infinity,
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  // Navigate to sign up screen when tapped
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => const FirebaseSignUpScreen()),
                                    );
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 16,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      // Orange border to match theme
                                      border: Border.all(
                                        color: const Color(0xFFFF7A00),
                                        width: 2,
                                      ),
                                      // Light orange background tint
                                      color: const Color(0xFFFF7A00).withOpacity(0.1),
                                    ),
                                    child: const Text(
                                      'Create new account',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Color(0xFFFF7A00),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // Spacer pushes social login section to bottom
                            const Spacer(),

                            // ==================== SOCIAL LOGIN SECTION ====================
                            // "Or continue with" divider text
                            const Text(
                              'Or continue with',
                              style: TextStyle(
                                color: Color(0xFF4285F4), // Blue text
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),

                            const SizedBox(height: 20),

                            // ==================== SOCIAL MEDIA BUTTONS ====================
                            // Row of social login options (currently non-functional placeholders)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Google login button (placeholder)
                                Container(
                                  width: 60,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF5F5F5), // Light grey background
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.g_mobiledata, // Google 'G' icon
                                    size: 28,
                                    color: Colors.black54,
                                  ),
                                ),

                                const SizedBox(width: 15),

                                // Facebook login button (placeholder)
                                Container(
                                  width: 60,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF5F5F5),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.facebook, // Facebook 'f' icon
                                    size: 24,
                                    color: Colors.black54,
                                  ),
                                ),

                                const SizedBox(width: 15),

                                // Apple login button (placeholder)
                                Container(
                                  width: 60,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF5F5F5),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.apple, // Apple logo icon
                                    size: 24,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),

                            // Bottom spacing before decorative waves
                            const SizedBox(height: 160),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // ==================== DECORATIVE BOTTOM WAVES ====================
          // Positioned at the bottom of the screen (behind content)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: CustomPaint(
              size: Size(MediaQuery.of(context).size.width, 150),
              painter: BottomCurvePainter(), // Custom painter for wave design
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter class that draws decorative waves at the bottom of the screen
/// Creates a layered wave effect with three shades of orange
class BottomCurvePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // ==================== FIRST LAYER - LIGHTEST WAVE ====================
    // Top wave with lightest orange color
    final paint1 = Paint()
      ..color = const Color(0xFFFFF2E6) // Very light orange (#FFF2E6)
      ..style = PaintingStyle.fill; // Fill the shape

    final path1 = Path();
    // Start from left side at 60% height
    path1.moveTo(0, size.height * 0.6);
    // Create smooth curve using Bezier curve
    path1.quadraticBezierTo(
      size.width * 0.25,      // Control point X (25% across)
      size.height * 0.4,      // Control point Y (40% down)
      size.width * 0.5,       // End point X (50% across)
      size.height * 0.5,      // End point Y (50% down)
    );
    // Second curve to complete the wave
    path1.quadraticBezierTo(
      size.width * 0.75,      // Control point X (75% across)
      size.height * 0.6,      // Control point Y (60% down)
      size.width,             // End point X (right edge)
      size.height * 0.4,      // End point Y (40% down)
    );
    // Complete the shape by drawing to bottom corners
    path1.lineTo(size.width, size.height);  // Right bottom
    path1.lineTo(0, size.height);           // Left bottom
    path1.close(); // Close the path

    // ==================== SECOND LAYER - MEDIUM WAVE ====================
    // Middle wave with medium orange color
    final paint2 = Paint()
      ..color = const Color(0xFFFFE4CC) // Medium light orange (#FFE4CC)
      ..style = PaintingStyle.fill;

    final path2 = Path();
    // Start slightly lower than first wave
    path2.moveTo(0, size.height * 0.7);
    path2.quadraticBezierTo(
      size.width * 0.3,
      size.height * 0.5,
      size.width * 0.6,
      size.height * 0.6,
    );
    path2.quadraticBezierTo(
      size.width * 0.8,
      size.height * 0.7,
      size.width,
      size.height * 0.5,
    );
    path2.lineTo(size.width, size.height);
    path2.lineTo(0, size.height);
    path2.close();

    // ==================== THIRD LAYER - DARKEST WAVE ====================
    // Bottom wave with darkest orange color
    final paint3 = Paint()
      ..color = const Color(0xFFFFD4A6) // Medium orange (#FFD4A6)
      ..style = PaintingStyle.fill;

    final path3 = Path();
    // Start at 80% height (lowest starting point)
    path3.moveTo(0, size.height * 0.8);
    path3.quadraticBezierTo(
      size.width * 0.2,
      size.height * 0.6,
      size.width * 0.4,
      size.height * 0.7,
    );
    path3.quadraticBezierTo(
      size.width * 0.7,
      size.height * 0.8,
      size.width,
      size.height * 0.6,
    );
    path3.lineTo(size.width, size.height);
    path3.lineTo(0, size.height);
    path3.close();

    // Draw all three layers to canvas (order matters - drawn back to front)
    canvas.drawPath(path1, paint1); // Lightest wave (back)
    canvas.drawPath(path2, paint2); // Medium wave (middle)
    canvas.drawPath(path3, paint3); // Darkest wave (front)
  }

  /// Determines if the painter needs to repaint
  /// Returns false since our waves are static (no animation)
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}