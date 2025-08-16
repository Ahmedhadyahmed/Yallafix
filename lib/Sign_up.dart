import 'package:flutter/material.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool rememberMe = false;
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

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
                    ),
                    child: const TextField(
                      decoration: InputDecoration(
                        hintText: 'Enter your full name...',
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
                    ),
                    child: const TextField(
                      decoration: InputDecoration(
                        hintText: 'Enter our username...',
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
                    ),
                    child: const TextField(
                      decoration: InputDecoration(
                        hintText: 'Enter your email...',
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
                    ),
                    child: TextField(
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
                    ),
                    child: TextField(
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

                  const SizedBox(height: 20),

                  // Remember me checkbox
                  Row(
                    children: [
                      SizedBox(
                        height: 20,
                        width: 20,
                        child: Checkbox(
                          value: rememberMe,
                          onChanged: (value) {
                            setState(() {
                              rememberMe = value ?? false;
                            });
                          },
                          activeColor: const Color(0xFFFF7A00),
                          checkColor: Colors.white,
                          side: const BorderSide(
                            color: Color(0xFF9CA3AF),
                            width: 1,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Remember me',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF374151),
                        ),
                      ),
                    ],
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
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
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
                        Navigator.pop(context); // Navigate back to login screen
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