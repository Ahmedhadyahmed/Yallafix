import 'package:flutter/material.dart';

class SetNewPasswordPage extends StatefulWidget {
  const SetNewPasswordPage({super.key});

  @override
  State<SetNewPasswordPage> createState() => _SetNewPasswordPageState();
}

class _SetNewPasswordPageState extends State<SetNewPasswordPage> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  void _updatePassword() {
    String password = _passwordController.text;
    String confirmPassword = _confirmPasswordController.text;

    // Basic validation
    if (password.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill in all fields"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Passwords do not match"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Password must be at least 6 characters long"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Show success message and navigate to login
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Password Updated Successfully!"),
        backgroundColor: Colors.green,
      ),
    );

    // Navigate back to login screen after a short delay
    Future.delayed(const Duration(seconds: 1), () {
      // Pop all screens and go back to login
      Navigator.of(context).popUntil((route) => route.isFirst);
    });
  }

  @override
  Widget build(BuildContext context) {
    const btnColor = Color(0xFFBF7A19);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back button
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),

              const SizedBox(height: 20),

              const Text(
                "Set a new password",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text(
                "Create a new password. Ensure it differs from previous ones for security",
                style: TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 30),

              // Password field
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Password",
                  hintText: "Enter your new password",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 20),

              // Confirm password field
              TextField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Confirm Password",
                  hintText: "Re-enter password",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: btnColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: _updatePassword, // Updated: Now calls the validation and navigation function
                  child: const Text(
                    "Update Password",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}