import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:phoneauth/controllers/auth_service.dart';
import 'package:phoneauth/firebase_options.dart';
import 'package:phoneauth/pages/home_page.dart';
import 'package:phoneauth/pages/login_page.dart';

void main()async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp
    (
    options:DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.yellowAccent),
        useMaterial3: true,
      ),
      home: CheckUserLoggedInOrNot()
    );
  }

}
class CheckUserLoggedInOrNot extends StatefulWidget {
  const CheckUserLoggedInOrNot({super.key});

  @override
  State<CheckUserLoggedInOrNot> createState() => _CheckUserLoggedInOState();
}

class _CheckUserLoggedInOState extends State<CheckUserLoggedInOrNot> {
  @override
  void initState() {
    AuthService.isLoggedIn().then((value) {
        if(value)
          {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> Homepage()));
          }
        else
          {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> Loginpage()));
          }
    });
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}





