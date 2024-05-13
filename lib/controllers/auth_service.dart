import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class AuthService {
  static final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  static String verifyId = "";
  //to send an otp to user
  static Future sentOtp({
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
  //verify the otp code and login
static Future loginWithOtp({required String otp}) async {
    final cred= PhoneAuthProvider.credential(verificationId: verifyId,smsCode: otp );
    try{
      final user = await _firebaseAuth.signInWithCredential(cred);
      if(user.user!=null)
        {
          return "Success";
        }
      else
        {
          return "Invalid Otp";
        }
    }
    on FirebaseAuthException catch(e)
  {
    return e.message.toString();
  }
  catch (e)
  {
    return e.toString();
  }
}
//to logut the user
static Future logout() async
{
  await _firebaseAuth.signOut();
}

//check weather the use ris logged in or not
static Future <bool> isLoggedIn() async{
    var user= _firebaseAuth.currentUser;
    return user!=null;
}
}
