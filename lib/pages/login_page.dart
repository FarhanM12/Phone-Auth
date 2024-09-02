import 'package:flutter/material.dart';
import 'package:phoneauth/controllers/auth_service.dart';
import 'package:phoneauth/pages/home_page.dart';
import 'package:phoneauth/pages/profile_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  TextEditingController _phoneController = TextEditingController();
  List<TextEditingController> _otpControllers = [];
  final formKey = GlobalKey<FormState>();
  final formKey1 = GlobalKey<FormState>();
  final int otpLength = 6;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    _otpControllers = List.generate(otpLength, (_) => TextEditingController());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.black,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Animated Icon or Logo with Dark Theme Colors
                ScaleTransition(
                  scale: _controller.drive(CurveTween(curve: Curves.easeInOut)),
                  child: Icon(
                    Icons.phone_android,
                    size: 100,
                    color: Colors.blueAccent,
                  ),
                ),
                SizedBox(height: 40),
                Text(
                  "Welcome Back 👋",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "Enter Your Phone Number to Continue",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade400,
                  ),
                ),
                SizedBox(height: 30),
                Form(
                  key: formKey,
                  child: TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.number,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.phone, color: Colors.blueAccent),
                      filled: true,
                      fillColor: Colors.grey.shade900,
                      labelText: "Enter Your Number",
                      labelStyle: TextStyle(color: Colors.grey.shade400),
                      prefixText: "+91 ",
                      prefixStyle: TextStyle(color: Colors.white),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(32),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (value) {
                      if (value!.length != 10) return "Invalid Phone Number";
                      return null;
                    },
                    onTap: () {
                      _controller.forward();
                    },
                    onChanged: (value) {
                      if (value.isEmpty) {
                        _controller.reverse();
                      }
                    },
                  ),
                ),
                SizedBox(height: 20),
                SizedBox(
                  height: 50,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        AuthService.sendOtp(
                          phone: _phoneController.text,
                          errorStep: () => ScaffoldMessenger.of(context)
                              .showSnackBar(
                            SnackBar(
                              content: Text(
                                "Error in Sending OTP",
                                style: TextStyle(color: Colors.white),
                              ),
                              backgroundColor: Colors.red,
                            ),
                          ),
                          nextStep: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                backgroundColor: Colors.grey.shade900,
                                title: Text(
                                  "OTP Verification",
                                  style: TextStyle(color: Colors.white),
                                ),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Enter 6 Digit OTP",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: List.generate(otpLength, (index) {
                                        return Container(
                                          width: 40,
                                          height: 50,
                                          child: TextFormField(
                                            controller: _otpControllers[index],
                                            keyboardType: TextInputType.number,
                                            style: TextStyle(color: Colors.white, fontSize: 18),
                                            textAlign: TextAlign.center,
                                            decoration: InputDecoration(
                                              filled: true,
                                              fillColor: Colors.grey.shade800,
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(12),
                                                borderSide: BorderSide.none,
                                              ),
                                            ),
                                            maxLength: 1,
                                            onChanged: (value) {
                                              if (value.length == 1 && index < otpLength - 1) {
                                                FocusScope.of(context).nextFocus();
                                              }
                                              if (value.isEmpty && index > 0) {
                                                FocusScope.of(context).previousFocus();
                                              }
                                            },
                                          ),
                                        );
                                      }),
                                    ),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      final otp = _otpControllers.map((controller) => controller.text).join();
                                      if (otp.length == otpLength) {
                                        AuthService.loginWithOtp(otp: otp).then((value) {
                                          if (value == "Success") {
                                            Navigator.pop(context);
                                            Navigator.pushAndRemoveUntil(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => Homepage(),
                                              ),
                                                  (Route<dynamic> route) => false,
                                            );
                                          } else {
                                            Navigator.pop(context);
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  value,
                                                  style: TextStyle(color: Colors.white),
                                                ),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                          }
                                        });
                                      }
                                    },
                                    child: Text(
                                      "Submit",
                                      style: TextStyle(color: Colors.blueAccent),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      }
                    },
                    child: Text("Send OTP"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
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

  @override
  void dispose() {
    _controller.dispose();
    _otpControllers.forEach((controller) => controller.dispose());
    super.dispose();
  }
}

