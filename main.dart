import 'dart:developer';

import 'package:chat_app/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_notification_channel/flutter_notification_channel.dart';
import 'package:flutter_notification_channel/notification_importance.dart';
import 'firebase_options.dart';

late Size mq;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  _initailization();
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
        appBarTheme: const AppBarTheme(
          iconTheme: IconThemeData(
            color: Colors.black,
          ),
          elevation: 1,
          centerTitle: true,
          titleTextStyle: TextStyle(
              color: Colors.black, fontWeight: FontWeight.normal, fontSize: 19),
          backgroundColor: Colors.white,
        ),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}

_initailization() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  var result = await FlutterNotificationChannel.registerNotificationChannel(
    description: 'For showing notification',
    id: 'chats',
    importance: NotificationImportance.IMPORTANCE_HIGH,
    name: 'Chats',
  );
  log(result);
}
