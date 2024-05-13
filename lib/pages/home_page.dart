import 'package:flutter/material.dart';
import 'package:phoneauth/controllers/auth_service.dart';
import 'package:phoneauth/pages/login_page.dart';

class Homepage extends StatelessWidget {
  const Homepage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Homepage"),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Text("Great You are logged in Now"),
          SizedBox(height: 20,),
            OutlinedButton(onPressed: (){
              AuthService.logout();
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> Loginpage()));
            }, child: Text("Logout"))
          ],
        ),
      ),
    );
  }
}
