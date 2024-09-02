import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class AuthService {
  static final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  static String verifyId = "";
  static const String adminCode = "123456"; // Example admin code

  // Method to send OTP to the user
  static Future<void> sendOtp({
    required Function errorStep,
    required Function nextStep,
    required String phone,
  }) async {
    await _firebaseAuth
        .verifyPhoneNumber(
        timeout: Duration(seconds: 30),
        phoneNumber: "+91$phone",
        verificationCompleted: (phoneAuthCredential) async {
          return;
        },
        verificationFailed: (error) {
          return;
        },
        codeSent: (verificationId, forceResendingToken) async {
          verifyId = verificationId;
          nextStep();
        },
        codeAutoRetrievalTimeout: (verificationId) async {
          return;
        })
        .onError((error, stackTrace) {
      errorStep();
    });
  }

  // Method to verify the OTP code and log in
  static Future<String> loginWithOtp({required String otp}) async {
    final cred = PhoneAuthProvider.credential(verificationId: verifyId, smsCode: otp);
    try {
      final user = await _firebaseAuth.signInWithCredential(cred);
      if (user.user != null) {
        return "Success";
      } else {
        return "Invalid OTP";
      }
    } on FirebaseAuthException catch (e) {
      return e.message.toString();
    } catch (e) {
      return e.toString();
    }
  }

  // Method to log out the user
  static Future<void> logout() async {
    await _firebaseAuth.signOut();
  }

  // Method to check if the user is logged in or not
  static Future<bool> isLoggedIn() async {
    var user = _firebaseAuth.currentUser;
    return user != null;
  }

  // Method to handle admin code login
  static Future<String> loginWithAdminCode({required String code}) async {
    try {
      if (code == adminCode) {
        // Assuming you want to mark the user as logged in
        // You can use shared preferences or a more secure way to handle this
        return "Admin login successful";
      } else {
        return "Invalid admin code";
      }
    } catch (e) {
      return e.toString();
    }
  }
}
