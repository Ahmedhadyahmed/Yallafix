import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  static const String _themeKey = 'isDarkMode';
  bool _isInitialized = false;
  SharedPreferences? _prefs;

  bool get isDarkMode => _isDarkMode;
  bool get isInitialized => _isInitialized;

  ThemeProvider();

  // PUBLIC: Initialize and load theme - call this in main() before runApp
  Future<void> initialize() async {
    await _initPrefs();
    await _loadThemeFromPrefs();
  }

  // Initialize SharedPreferences instance
  Future<void> _initPrefs() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      print('✅ SharedPreferences initialized');
    } catch (e) {
      print('❌ Error initializing SharedPreferences: $e');
      _prefs = null;
    }
  }

  // Load theme preference from storage
  Future<void> _loadThemeFromPrefs() async {
    try {
      if (_prefs != null) {
        _isDarkMode = _prefs!.getBool(_themeKey) ?? false;
        print('✅ Theme loaded from prefs: $_isDarkMode');
      } else {
        print('⚠️ SharedPreferences not available, using default theme');
        _isDarkMode = false;
      }
    } catch (e) {
      print('❌ Error loading theme: $e');
      _isDarkMode = false;
    } finally {
      _isInitialized = true;
      notifyListeners();
    }
  }

  // Save theme to storage
  Future<void> _saveTheme() async {
    try {
      if (_prefs == null) {
        _prefs = await SharedPreferences.getInstance();
      }
      await _prefs!.setBool(_themeKey, _isDarkMode);
      print('💾 Theme saved to prefs: $_isDarkMode');
    } catch (e) {
      print('❌ Error saving theme: $e');
    }
  }

  // Toggle theme and save to storage
  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    print('🔄 Theme toggled to: $_isDarkMode');
    notifyListeners();
    await _saveTheme();
  }

  // Set specific theme mode
  Future<void> setTheme(bool isDark) async {
    print('🎨 setTheme called with: $isDark');
    _isDarkMode = isDark;
    notifyListeners();
    await _saveTheme();
  }

  // Light theme matching SettingPage colors
  ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: const Color(0xFFF48C25), // Orange from SettingPage
      scaffoldBackgroundColor: const Color(0xFFF8F7F5), // Light background from SettingPage
      colorScheme: const ColorScheme.light(
        primary: Color(0xFFF48C25), // Orange
        secondary: Color(0xFF181411), // Dark text color
        surface: Colors.white, // Card background
        background: Color(0xFFF8F7F5), // Screen background
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFF8F7F5),
        foregroundColor: Color(0xFF181411),
        elevation: 0,
      ),
      cardTheme: CardTheme(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Color(0xFF181411)),
        bodyMedium: TextStyle(color: Color(0xFF181411)),
      ),
    );
  }

  // Dark theme matching SettingPage colors
  ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: const Color(0xFFF48C25), // Orange from SettingPage
      scaffoldBackgroundColor: const Color(0xFF221910), // Dark background from SettingPage
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFFF48C25), // Orange
        secondary: Color(0xFF32281E), // Card background color
        surface: Color(0xFF32281E), // Card background from SettingPage
        background: Color(0xFF221910), // Screen background from SettingPage
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF221910),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      cardTheme: CardTheme(
        color: const Color(0xFF32281E), // Matching card color from SettingPage
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Colors.white),
        bodyMedium: TextStyle(color: Colors.white),
      ),
    );
  }
}