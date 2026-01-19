import 'package:flutter/material.dart';
import 'Login.dart'; // Import your login screen
import 'service_login.dart'; // Import service provider login

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 60),

                  // App Logo or Icon (you can replace with your actual logo)
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF7A00).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.directions_car,
                      size: 60,
                      color: Color(0xFFFF7A00),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Welcome Title
                  const Text(
                    'Welcome!',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFFF7A00),
                      letterSpacing: -0.5,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Subtitle
                  const Text(
                    'Choose how you want to continue',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                      height: 1.4,
                      letterSpacing: 0.2,
                    ),
                  ),

                  const SizedBox(height: 60),

                  // User Card
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const FirebaseLoginScreen(),
                        ),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF7A00), Color(0xFFE6590A)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF7A00).withOpacity(0.4),
                            spreadRadius: 0,
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.person_outline,
                              size: 40,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'I\'m a User',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Looking for car services',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Colors.white,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Service Provider Card
                  GestureDetector(
                    onTap: () {
                      // Navigate to service provider login
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ServiceProviderLoginScreen(),
                        ),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFFFF7A00),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            spreadRadius: 0,
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF7A00).withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.build_circle_outlined,
                              size: 40,
                              color: Color(0xFFFF7A00),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'I\'m a Service Provider',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFFF7A00),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Offering car services',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Colors.black87,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Footer text
                  Padding(
                    padding: const EdgeInsets.only(bottom: 180),
                    child: Text(
                      'By continuing, you agree to our Terms & Privacy Policy',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Colors.black.withOpacity(0.5),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom decorative waves
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: CustomPaint(
              size: Size(MediaQuery.of(context).size.width, 150),
              painter: WelcomeBottomCurvePainter(),
            ),
          ),
        ],
      ),
    );
  }
}

class WelcomeBottomCurvePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // First layer - lightest orange (top wave)
    final paint1 = Paint()
      ..color = const Color(0xFFFFF2E6)
      ..style = PaintingStyle.fill;

    final path1 = Path();
    path1.moveTo(0, size.height * 0.6);
    path1.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.4,
      size.width * 0.5,
      size.height * 0.5,
    );
    path1.quadraticBezierTo(
      size.width * 0.75,
      size.height * 0.6,
      size.width,
      size.height * 0.4,
    );
    path1.lineTo(size.width, size.height);
    path1.lineTo(0, size.height);
    path1.close();

    // Second layer - medium orange (middle wave)
    final paint2 = Paint()
      ..color = const Color(0xFFFFE4CC)
      ..style = PaintingStyle.fill;

    final path2 = Path();
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

    // Third layer - darker orange (bottom wave)
    final paint3 = Paint()
      ..color = const Color(0xFFFFD4A6)
      ..style = PaintingStyle.fill;

    final path3 = Path();
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

    // Draw all layers
    canvas.drawPath(path1, paint1);
    canvas.drawPath(path2, paint2);
    canvas.drawPath(path3, paint3);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}