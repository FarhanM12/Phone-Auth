import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:phoneauth/controllers/auth_service.dart';
import 'package:phoneauth/firebase_options.dart';
import 'package:phoneauth/pages/home_page.dart';
import 'package:phoneauth/pages/login_page.dart';
import 'package:phoneauth/pages/admin_login_page.dart'; // Import the new admin login page

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.yellowAccent),
        useMaterial3: true,
      ),
      // Define named routes
      routes: {
        '/': (context) => const CheckUserLoggedInOrNot(),
        '/login': (context) => const LoginPage(),
        '/admin_login': (context) => AdminLoginPage(), // Route to the new admin login page
        '/home': (context) => const Homepage(),
      },
      initialRoute: '/',
    );
  }
}

class CheckUserLoggedInOrNot extends StatefulWidget {
  const CheckUserLoggedInOrNot({super.key});

  @override
  State<CheckUserLoggedInOrNot> createState() => _CheckUserLoggedInOrNotState();
}

class _CheckUserLoggedInOrNotState extends State<CheckUserLoggedInOrNot> {
  @override
  void initState() {
    super.initState();

    // Check if the user is logged in
    _checkLoginStatus();
  }

  void _checkLoginStatus() async {
    bool isLoggedIn = await AuthService.isLoggedIn();

    if (isLoggedIn) {
      // Navigate to home if logged in
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      // Navigate to admin login if not logged in
      Navigator.pushReplacementNamed(context, '/admin_login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}


