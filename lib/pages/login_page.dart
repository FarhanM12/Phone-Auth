import 'package:flutter/material.dart';
import 'package:phoneauth/controllers/auth_service.dart';
import 'package:phoneauth/pages/home_page.dart';

class Loginpage extends StatefulWidget {
  const Loginpage({Key? key}) : super(key: key);

  @override
  _LoginpageState createState() => _LoginpageState();
}

class _LoginpageState extends State<Loginpage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _otpController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final formKey1 = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Image.asset(
                "images/login.png",
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Welcome Back 👋",
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.w200),
                  ),
                  Text("Enter Your Phone number to continue"),
                  SizedBox(height: 20,),
                  Form(
                    key: formKey,
                    child: TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Enter Your Number",
                        prefixText: "+91",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(32),
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
                  SizedBox(height: 20,),
                  SizedBox(
                    height: 50,
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          AuthService.sentOtp(
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
                                  title: Text("OTP Verification "),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment
                                        .start,
                                    children: [
                                      Text("Enter 6 Digit OTP"),
                                      SizedBox(height: 12),
                                      Form(
                                        key: formKey1,
                                        child: TextFormField(
                                          keyboardType: TextInputType.number,
                                          controller: _otpController,
                                          decoration: InputDecoration(
                                            labelText: "Enter Your Number",
                                            border: OutlineInputBorder(
                                              borderRadius:
                                              BorderRadius.circular(32),
                                            ),
                                          ),
                                          validator: (value) {
                                            if (value!.length != 6)
                                              return "Invalid OTP";
                                            return null;
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        if (formKey1.currentState!
                                            .validate()) {
                                          AuthService.loginWithOtp(
                                            otp: _otpController.text,
                                          ).then((value) {
                                            if (value == "Success") {
                                              Navigator.pop(context);
                                              Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      Homepage(),
                                                ),
                                              );
                                            } else {
                                              Navigator.pop(context);
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    value,
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );
                                            }
                                          });
                                        }
                                      },
                                      child: Text("Submit"),
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
                        backgroundColor: Colors.yellow,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32),
                        ),
                        elevation: 0,
                        animationDuration: Duration(milliseconds: 300),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
