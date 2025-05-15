import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:weather_app/weather_screen.dart';
import 'package:weather_app/config/env.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyDSiIghHRD25-QvcfPz8AhU4HYoEMuns64",
          appId: "1:300839987937:android:ba745f4bce033f3227e5a0",
          messagingSenderId: "300839987937",
          projectId: "weather-app-72acd"));
  await Env.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Weather App",
      theme: ThemeData.dark(useMaterial3: true),
      home: WeatherScreen(),
    );
  }
}
