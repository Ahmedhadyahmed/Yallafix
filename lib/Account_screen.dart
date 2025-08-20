import 'package:flutter/material.dart';
import 'car_info_page.dart';
import 'setting.dart'; // Add this import

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Profile Section
            Row(
              children: [
                const SizedBox(width: 20),
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.grey[300],
                  child: Icon(Icons.person, size: 50, color: Colors.grey[600]),
                ),
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "AHMED HASSAN",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, letterSpacing: 1.2),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: const [
                        Icon(Icons.star, size: 16, color: Colors.black),
                        SizedBox(width: 4),
                        Text("5.0", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 40),

            // Buttons
            _buildMenuButton(
              icon: Icons.directions_car,
              label: "CAR INFO",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CarInfoPage()),
                );
              },
            ),
            _buildMenuButton(
              icon: Icons.settings,
              label: "Settings",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingPage()),
                );
              },
            ),
            _buildMenuButton(icon: Icons.message, label: "messages", onTap: () {}),
            _buildMenuButton(icon: Icons.info, label: "legal", onTap: () {}),

            const Spacer(),
          ],
        ),
      ),
    );
  }

  // NOTE: now accepts onTap and uses it
  Widget _buildMenuButton({
    required IconData icon,
    required String label,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Material(
        color: const Color(0xFFFFE0B2),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Icon(icon, color: Colors.black, size: 24),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black),
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.black),
              ],
            ),
          ),
        ),
      ),
    );
  }
}