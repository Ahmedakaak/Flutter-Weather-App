import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static String get openWeatherApiKey => dotenv.env['OPENWEATHER_API_KEY'] ?? '';
  
  static Future<void> init() async {
    await dotenv.load(fileName: '.env');
  }
} 