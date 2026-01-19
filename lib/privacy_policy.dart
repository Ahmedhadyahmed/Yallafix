import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Privacy Policy"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFFF3E0), // light orange background
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: const SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Effective: 23 April 2025\n",
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
                Text(
                  "Privacy Policy",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  "YallaFix ('we,' 'our,' or 'us') respects your privacy and is committed "
                      "to protecting the personal information you share with us when using "
                      "our mobile application and services. This Privacy Policy explains "
                      "how we collect, use, and safeguard your information.\n\n"
                      "1. Information We Collect\n"
                      "- Personal Information: Name, phone number, email, and payment details.\n"
                      "- Location Data: Real-time GPS location.\n"
                      "- Vehicle Information: Car make, model, license plate.\n"
                      "- Usage Data: Device type, app version.\n\n"
                      "2. How We Use Your Information\n"
                      "- To connect you with mechanics, tow trucks, and car part suppliers.\n"
                      "- Process payments and bookings.\n"
                      "- Provide service updates and arrival times.\n"
                      "- Improve our app and support.\n\n"
                      "3. Sharing of Information\n"
                      "- With mechanics, tow truck operators, and suppliers.\n"
                      "- With payment processors.\n"
                      "- If required by law.\n\n"
                      "4. Data Security\n"
                      "We take reasonable measures to protect your data.\n\n"
                      "5. Your Choices\n"
                      "- Update or delete your account anytime.\n"
                      "- Disable location sharing (may affect service).\n"
                      "- Unsubscribe from marketing notifications.\n\n"
                      "6. Children’s Privacy\n"
                      "YallaFix is not intended for children under 13.\n\n"
                      "7. Changes to this Policy\n"
                      "We may update this Privacy Policy occasionally.\n\n"
                      "8. Contact Us\n"
                      "📧 support@yallafix.com",
                  style: TextStyle(fontSize: 14, height: 1.5),
                ),
                SizedBox(height: 20), // bottom padding equal to top
              ],
            ),
          ),
        ),
      ),
    );
  }
}
