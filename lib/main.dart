import 'package:flutter/material.dart';
import 'package:weather_app/weather_screen.dart';
import 'package:weather_app/config/env.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
      theme: ThemeData.dark(
        useMaterial3: true
      ),
      home: WeatherScreen(),
    );
  }
}