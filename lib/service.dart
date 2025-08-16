import 'package:flutter/material.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({Key? key}) : super(key: key);

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  int selectedIndex = 1; // Services tab is selected

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Main content with SafeArea
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),

                  // Title
                  const Text(
                    'Services',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFFF7A00),
                      letterSpacing: -0.5,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Services Grid
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                    childAspectRatio: 1.1,
                    children: [
                      // Tow Truck Service
                      _buildServiceCard(
                        icon: Icons.local_shipping,
                        title: 'Tow Truck',
                        onTap: () {
                          // Navigate to tow truck service
                        },
                      ),

                      // Mechanic Service
                      _buildServiceCard(
                        icon: Icons.build,
                        title: 'Mechanic',
                        onTap: () {
                          // Navigate to mechanic service
                        },
                      ),

                      // Car Parts Service
                      _buildServiceCard(
                        icon: Icons.settings,
                        title: 'Car Parts',
                        onTap: () {
                          // Navigate to car parts service
                        },
                      ),

                      // Reservations Service
                      _buildServiceCard(
                        icon: Icons.access_time,
                        title: 'Reservations',
                        onTap: () {
                          // Navigate to reservations service
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 170), // Extra space for bottom navigation and waves
                ],
              ),
            ),
          ),

          // Bottom decorative waves (at actual bottom of physical screen)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: CustomPaint(
              size: Size(MediaQuery.of(context).size.width, 150),
              painter: BottomCurvePainter(),
            ),
          ),
        ],
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(Icons.home, 'Home', 0),
                _buildNavItem(Icons.miscellaneous_services, 'Services', 1),
                _buildNavItem(Icons.history, 'Activity', 2),
                _buildNavItem(Icons.account_circle, 'Account', 3),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildServiceCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: const Color(0xFFE5E7EB),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon container
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFFFF7A00),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 30,
              ),
            ),

            const SizedBox(height: 15),

            // Service title
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedIndex = index;
        });

        // Handle navigation based on index
        switch (index) {
          case 0:
          // Navigate to Home
            break;
          case 1:
          // Already on Services
            break;
          case 2:
          // Navigate to Activity
            break;
          case 3:
          // Navigate to Account
            break;
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? const Color(0xFFFF7A00) : const Color(0xFF9CA3AF),
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isSelected ? const Color(0xFFFF7A00) : const Color(0xFF9CA3AF),
            ),
          ),
        ],
      ),
    );
  }
}

class BottomCurvePainter extends CustomPainter {
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
      size.width * 0.8,
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