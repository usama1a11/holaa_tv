import 'package:flutter/material.dart';
import 'package:holaa_tv/splash_screen.dart';
import 'package:holaa_tv/web_view_screen.dart';
import 'package:video_player/video_player.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Video Splash App',
      debugShowCheckedModeBanner: false,
      home:  SplashScreen(),
    );
  }
}