import 'package:flutter/material.dart';
import 'package:phoneauth/controllers/auth_service.dart';
import 'package:phoneauth/pages/login_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.teal, // Teal color for the app bar
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.teal.shade700, // Teal color for the avatar
              child: Icon(
                Icons.person,
                size: 50,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 20),
            Text(
              "Welcome, User!",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 10),
            Text(
              "user@example.com", // Replace with user's email or other info
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade300,
              ),
            ),
            SizedBox(height: 30),
            ListTile(
              leading: Icon(Icons.settings, color: Colors.white),
              title: Text(
                'Settings',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                // Navigate to Settings Page
              },
            ),
            Divider(color: Colors.grey.shade700),
            ListTile(
              leading: Icon(Icons.info_outline, color: Colors.white),
              title: Text(
                'About',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                // Navigate to About Page
              },
            ),
            Divider(color: Colors.grey.shade700),
            Spacer(),
            OutlinedButton(
              onPressed: () {
                AuthService.logout();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
              child: Text("Logout"),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.teal.shade700,
                side: BorderSide(color: Colors.teal.shade700),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.grey.shade900, // Match with the dark theme
    );
  }
}
