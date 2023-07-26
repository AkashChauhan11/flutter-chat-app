import 'dart:io';

import 'package:chat_app/apis/apis.dart';
import 'package:chat_app/helpers/dialogs.dart';
import 'package:chat_app/main.dart';
import 'package:chat_app/screens/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  _handlegooglebutton() {
    Dialogs.showProgressIndicator(context);
    signInWithGoogle().then((user) async {
      Navigator.pop(context);
      if (user != null) {
        if ((await APis.userexists())) {
          // ignore: use_build_context_synchronously
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const HomeScreen(),
            ),
          );
        } else {
          APis.createuser().then((value) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const HomeScreen(),
              ),
            );
          });
        }
      }
    });
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      await InternetAddress.lookup("google.com");
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      return await APis.auth.signInWithCredential(credential);
    } catch (e) {
      Dialogs.showsnackbar(context, "Something Went Wrong Try Again");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Welcome to  we Chat",
        ),
      ),
      body: Stack(children: [
        Positioned(
          top: mq.height * 0.15,
          left: mq.width * 0.15,
          width: mq.width * 0.7,
          child: Image.asset("assets/images/messenger.png"),
        ),
        Positioned(
          bottom: mq.height * 0.10,
          height: mq.height * 0.05,
          width: mq.width * 0.80,
          left: mq.width * 0.1,
          child: ElevatedButton.icon(
            onPressed: () {
              _handlegooglebutton();
            },
            icon: Image.asset("assets/images/search.png",
                height: mq.height * 0.04),
            label: const Text("Sign In with Google"),
          ),
        )
      ]),
    );
  }
}
