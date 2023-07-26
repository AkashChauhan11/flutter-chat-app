import 'package:chat_app/apis/apis.dart';
import 'package:chat_app/screens/auth/login_screen.dart';
import 'package:chat_app/screens/home_screen.dart';
import 'package:flutter/material.dart';
import '../main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 3000), () {
      if (APis.auth.currentUser != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const HomeScreen(),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const LoginScreen(),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: mq.height * 0.4,
            width: mq.width * 0.7,
            left: mq.width * 0.15,
            child: Image.asset("assets/gif/splash.gif"),
          ),
        ],
      ),
    );
  }
}
