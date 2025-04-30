import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:holaa_tv/description_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Video Splash App',
      debugShowCheckedModeBanner: false,
      // home: PhoneAuthScreen(),
      // home: SplashScreen(),
      home:  SubscriptionScreen(),
      // home: OtpVerificationScreen(),
    );
  }
}