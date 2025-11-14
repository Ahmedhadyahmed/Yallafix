import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email address';
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  Future<void> _handleResetPassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        // Send password reset email using Firebase Auth
        await _auth.sendPasswordResetEmail(
          email: _emailController.text.trim(),
        );

        if (mounted) {
          setState(() {
            _isLoading = false;
            _emailSent = true;
          });

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Password reset link sent to your email'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );

          // Optional: Navigate back after a delay
          await Future.delayed(const Duration(seconds: 2));
          if (mounted) {
            Navigator.pop(context);
          }
        }
      } on FirebaseAuthException catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);

          String errorMessage;
          switch (e.code) {
            case 'user-not-found':
              errorMessage = 'No account found with this email address';
              break;
            case 'invalid-email':
              errorMessage = 'Invalid email address format';
              break;
            case 'too-many-requests':
              errorMessage = 'Too many attempts. Please try again later';
              break;
            default:
              errorMessage = 'An error occurred. Please try again';
          }

          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);

          // Show generic error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('An unexpected error occurred'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const btnColor = Color(0xFFBF7A19);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back button
                SizedBox(
                  height: 44,
                  width: 44,
                  child: Material(
                    color: const Color(0xFFF2F2F2),
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.arrow_back_ios_new, size: 20),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Header
                const Text(
                  'Forgot password',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),

                const Text(
                  'Please enter your email address to receive a password reset link',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF8C8C8C),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 32),

                // Email input label
                const Text(
                  'Email address',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 12),

                // Email input field
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: _validateEmail,
                  enabled: !_emailSent,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _handleResetPassword(),
                  decoration: InputDecoration(
                    hintText: 'example@email.com',
                    hintStyle: const TextStyle(
                      color: Color(0xFFBFBFBF),
                      fontSize: 16,
                    ),
                    prefixIcon: const Icon(
                      Icons.email_outlined,
                      color: Color(0xFF8C8C8C),
                      size: 22,
                    ),
                    suffixIcon: _emailSent
                        ? const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 22,
                    )
                        : null,
                    filled: true,
                    fillColor: _emailSent
                        ? const Color(0xFFF0F0F0)
                        : const Color(0xFFFAFAFA),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: Color(0xFFE6E6E6),
                        width: 1.2,
                      ),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: Color(0xFFE6E6E6),
                        width: 1.2,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: btnColor.withOpacity(0.5),
                        width: 1.8,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: Color(0xFFE53935),
                        width: 1.2,
                      ),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: Color(0xFFE53935),
                        width: 1.8,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Help text
                Row(
                  children: [
                    Icon(
                      _emailSent ? Icons.check_circle_outline : Icons.info_outline,
                      size: 16,
                      color: _emailSent ? Colors.green : const Color(0xFF8C8C8C),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _emailSent
                            ? 'Check your email for the reset link'
                            : 'We\'ll send a password reset link to this email',
                        style: TextStyle(
                          fontSize: 13,
                          color: _emailSent ? Colors.green : const Color(0xFF8C8C8C),
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(),

                // Submit button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _emailSent ? Colors.green : btnColor,
                      disabledBackgroundColor: btnColor.withOpacity(0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    onPressed: (_isLoading || _emailSent) ? null : _handleResetPassword,
                    child: _isLoading
                        ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                        : Text(
                      _emailSent ? 'Email Sent!' : 'Send Reset Link',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Back to login
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    child: RichText(
                      text: TextSpan(
                        text: 'Remember your password? ',
                        style: const TextStyle(
                          fontSize: 15,
                          color: Color(0xFF8C8C8C),
                        ),
                        children: [
                          TextSpan(
                            text: 'Sign in',
                            style: TextStyle(
                              color: btnColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}