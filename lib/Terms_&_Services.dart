import 'package:flutter/material.dart';

class TermsAndServicesPage extends StatefulWidget {
  const TermsAndServicesPage({super.key});

  @override
  State<TermsAndServicesPage> createState() => _TermsAndServicesPageState();
}

class _TermsAndServicesPageState extends State<TermsAndServicesPage> {
  bool _isChecked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Terms & Services",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFFF2CC), // light yellow background
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    """Welcome to YallaFIX

By using this application, you agree to the following terms:

1. Usage: This app is designed to help users manage car services, bookings, and related information. Misuse of the app for unauthorized purposes is prohibited.  

2. Data Collection: The app may collect data such as car details, booking information, and user profile to enhance services.  

3. Liability: We are not responsible for accidents, delays, or third-party issues.  

4. Updates: Terms may change with updates. Continued use means you accept the new terms.  

5. Privacy: We respect your privacy and will not share your information without consent.  

Thank you for choosing our service!
                    """,
                    style: TextStyle(fontSize: 14, color: Colors.black87, height: 1.5),
                  ),
                ),
              ),
              Row(
                children: [
                  Checkbox(
                    value: _isChecked,
                    activeColor: Colors.orange,
                    onChanged: (value) {
                      setState(() {
                        _isChecked = value ?? false;
                      });
                    },
                  ),
                  const Expanded(
                    child: Text(
                      "I have read and agree to the Terms & Services",
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isChecked ? () {} : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "ACCEPT",
                    style: TextStyle(fontSize: 15, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.black54,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.build), label: "Services"),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: "Activity"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Account"),
        ],
      ),
    );
  }
}