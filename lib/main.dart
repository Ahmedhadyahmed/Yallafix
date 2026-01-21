import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:your_app_name/service.dart';
import 'Account_screen.dart';
import 'Activity_Page.dart';
import 'Login.dart';
import 'activity_manager.dart';
import 'forget_password.dart';
import 'home_page.dart';
import 'welcome_page.dart';
import 'firebase_options.dart';
import 'splash_screen.dart';
import 'Theme_Provider.dart';

void main() async {
  // CRITICAL: Initialize Flutter bindings before async operations
  WidgetsFlutterBinding.ensureInitialized();

  print('🔧 Initializing app...');

  // Initialize Firebase first
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase initialized');
  } catch (e) {
    print('❌ Firebase initialization error: $e');
  }

  // Create ThemeProvider and initialize it
  final themeProvider = ThemeProvider();

  // Try to initialize theme, but don't block app startup if it fails
  try {
    await themeProvider.initialize().timeout(
      const Duration(seconds: 3),
      onTimeout: () {
        print('⚠️ Theme loading timeout, continuing with default theme');
      },
    );
  } catch (e) {
    print('⚠️ Theme initialization failed, using default: $e');
  }

  print('🚀 App starting with theme: ${themeProvider.isDarkMode ? "Dark" : "Light"}');

  // Initialize ActivityManager
  try {
    await ActivityManager().initialize();
    print('🚀 ActivityManager initialized with ${ActivityManager().activities.length} activities');
  } catch (e) {
    print('⚠️ ActivityManager initialization failed: $e');
  }

  // Wrap the app with ChangeNotifierProvider
  runApp(
    ChangeNotifierProvider.value(
      value: themeProvider,
      child: const RoadHelperApp(),
    ),
  );
}

class RoadHelperApp extends StatelessWidget {
  const RoadHelperApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        // Show a loading screen while theme is being loaded
        if (!themeProvider.isInitialized) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              backgroundColor: const Color(0xFF221910),
              body: Center(
                child: CircularProgressIndicator(
                  color: const Color(0xFFF48C25),
                ),
              ),
            ),
          );
        }

        return MaterialApp(
          title: 'YallaFix - Roadside Assistance',
          debugShowCheckedModeBanner: false,

          // Use themes from ThemeProvider
          theme: themeProvider.lightTheme,
          darkTheme: themeProvider.darkTheme,
          themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,

          // Start with SplashScreen instead of AuthWrapper
          home: const SplashScreen(),
          routes: {
            '/welcome': (context) => const WelcomeScreen(),
            '/home': (context) => const MainPage(),
            '/forgot-password': (context) => const ForgotPasswordScreen(),
            '/auth': (context) => const AuthWrapper(),
          },
          onGenerateRoute: (settings) {
            // Handle the /login route with arguments
            if (settings.name == '/login') {
              final userType = settings.arguments as String?;
              return MaterialPageRoute(
                builder: (context) => FirebaseLoginScreen(userType: userType),
              );
            }
            return null;
          },
        );
      },
    );
  }
}

// AuthWrapper to check authentication state
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show loading indicator while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: isDark ? const Color(0xFF221910) : const Color(0xFFF8F7F5),
            body: Center(
              child: CircularProgressIndicator(
                color: const Color(0xFFF48C25),
              ),
            ),
          );
        }

        // If user is logged in, go to home
        if (snapshot.hasData && snapshot.data != null) {
          return const MainPage();
        }

        // If user is not logged in, go to login screen
        return const FirebaseLoginScreen();
      },
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const ServicesPage(),
    const ActivityPage(),
    const AccountPage(),
  ];

  @override
  Widget build(BuildContext context) {
    // Get theme state for bottom navigation styling
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: _buildBottomNavigation(isDark),
    );
  }

  Widget _buildBottomNavigation(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF32281E) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home_rounded, 'Home', 0, isDark),
              _buildNavItem(Icons.grid_view_rounded, 'Services', 1, isDark),
              _buildNavItem(Icons.receipt_long_rounded, 'Activity', 2, isDark),
              _buildNavItem(Icons.person_rounded, 'Account', 3, isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index, bool isDark) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected
                ? const Color(0xFFF48C25)
                : (isDark ? Colors.white : Colors.black).withOpacity(0.4),
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected
                  ? const Color(0xFFF48C25)
                  : (isDark ? Colors.white : Colors.black).withOpacity(0.4),
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}