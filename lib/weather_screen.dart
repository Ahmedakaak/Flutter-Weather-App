import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/Additional_info.dart';
import 'package:weather_app/Hourly_forcast_item.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:weather_app/app_drawer.dart';
import 'package:weather_app/config/env.dart';
import 'package:lottie/lottie.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  late Future<Map<String,dynamic>> weather;
  final TextEditingController _searchController = TextEditingController();
  String _currentCity = 'Salalah';
  
  Future<Map<String, dynamic>> getCurrentWeather() async {
    try {
      print('API Key from Env: ${Env.openWeatherApiKey}'); // Debug print
      print('API Key from dotenv: ${dotenv.env['OPENWEATHER_API_KEY']}'); // Debug print
      
      final res = await http.get(
        Uri.parse(
            'http://api.openweathermap.org/data/2.5/forecast?q=$_currentCity&APPID=${Env.openWeatherApiKey}'),
      );

      print('API Response Status: ${res.statusCode}'); // Debug print
      print('API Response Body: ${res.body}'); // Debug print

      final data = jsonDecode(res.body);

      if(data["cod"]!="200") {
        throw 'City not found. Please try another city.';
      }
      return data;
    }
    catch(e) {
      print('Error: $e'); // Debug print
      throw e.toString();
    }
  }

  void _searchCity() {
    if (_searchController.text.isNotEmpty) {
      setState(() {
        _currentCity = _searchController.text;
        weather = getCurrentWeather();
      });
      _searchController.clear();
    }
  }

  @override
  void initState() {
    super.initState();
    print('API Key: ${Env.openWeatherApiKey}'); // Debug print
    weather = getCurrentWeather();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text(
          "Weather App",
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                weather = getCurrentWeather();
              });
            },
            icon: const Icon(Icons.refresh),
          )
        ],
      ),
      
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Enter city name',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: _searchCity,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onSubmitted: (_) => _searchCity(),
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: weather,
              builder: (context,snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting){
                  return const Center(child: CircularProgressIndicator.adaptive());
                }
                
                if (snapshot.hasError){
                  return Center(
                    child: Text(
                      snapshot.error.toString(),
                      style: TextStyle(fontSize: 16, color: Colors.red),
                    ),
                  );
                }

                final data = snapshot.data!;
                final currentweatherData= data['list'][0];
                final currenttemp= currentweatherData['main']['temp'];
                final currentSky=currentweatherData['weather'][0]['main'];
                final currentpressure=currentweatherData['main']['pressure'];
                final current_wind_speed=currentweatherData['wind']['speed'];
                final current_humidity=currentweatherData['main']['humidity'];

                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //main card
                      SizedBox(
                        width: double.infinity,
                        child: Card(
                          elevation: 10,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child:  Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    Text(
                                      '$_currentCity',
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '${(currenttemp - 273.15).toStringAsFixed(1)}°C',
                                      style: const TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    (currentSky == 'Clouds')
                                      ? Lottie.asset('assets/animations/cloudy.json', width: 100, height: 100)
                                      : (currentSky == 'Rain')
                                        ? Lottie.asset('assets/animations/rain.json', width: 100, height: 100)
                                        : Lottie.asset('assets/animations/sunny.json', width: 100, height: 100),
                                    const SizedBox(height: 16),
                                    Text(
                                      currentSky,
                                      style: TextStyle(fontSize: 20),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Weather Forecast",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 120,
                        child: ListView.builder(
                          itemCount: 5,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context,index){
                            final hourlyforacast= data['list'][index +1];
                            final time=DateTime.parse(hourlyforacast['dt_txt']);
                            final hourlSky = hourlyforacast['weather'][0]['main'];
                            final hourlytemp=hourlyforacast['main']['temp'].toString();
                            return HourlyForacastItem(
                              time: DateFormat.Hm().format(time), 
                              icon: (hourlSky == 'Clouds')
                                ? Lottie.asset('assets/animations/cloudy.json', width: 36, height: 36)
                                : (hourlSky == 'Rain')
                                  ? Lottie.asset('assets/animations/rain.json', width: 36, height: 36)
                                  : Lottie.asset('assets/animations/sunny.json', width: 36, height: 36),
                              temp: '${(double.parse(hourlytemp) - 273.15).toStringAsFixed(1)}°C'
                            );
                          }),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Additional Information",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Additonal_info(
                            icon: Lottie.asset('assets/animations/humid.json', width: 36, height: 36),
                            label: "Humidity",
                            value: "$current_humidity%",
                          ),
                          Additonal_info(
                            icon: Lottie.asset('assets/animations/windspeed.json', width: 36, height: 36),
                            label: "Wind Speed",
                            value: "${current_wind_speed}m/s",
                          ),
                          Additonal_info(
                            icon: Lottie.asset('assets/animations/pre.json', width: 36, height: 36),
                            label: "Pressure",
                            value: "${currentpressure}hPa",
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
