import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // To store the admin code

class AdminLoginPage extends StatefulWidget {
  @override
  _AdminLoginPageState createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final TextEditingController _codeController = TextEditingController();
  String _statusMessage = '';

  Future<void> _login() async {
    final enteredCode = _codeController.text;

    // Assuming the code '123456' is the admin code for simplicity.
    // In a real-world scenario, fetch this from a secure source or backend.
    const adminCode = '123456';

    if (enteredCode == adminCode) {
      // Store login state or navigate to another page
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      Navigator.pushReplacementNamed(context, '/homepage'); // Redirect to homepage
    } else {
      setState(() {
        _statusMessage = 'Invalid code. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Login'),
        backgroundColor: Colors.black87,
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _codeController,
              decoration: InputDecoration(
                labelText: 'Enter Admin Code',
                labelStyle: TextStyle(color: Colors.white),
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white24,
              ),
              style: TextStyle(color: Colors.white),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              child: Text('Login'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              _statusMessage,
              style: TextStyle(color: Colors.red, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
