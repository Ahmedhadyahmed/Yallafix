import 'package:flutter/material.dart';

import 'Login.dart';
import 'Sign_up.dart';
import 'home_page.dart';
// Import your screen files here
// import 'login_screen.dart';
// import 'signup_screen.dart';
// import 'home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login App',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        fontFamily: 'Roboto',
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/home': (context) => const RoadHelperApp(),
      },
    );
  }
}