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
import 'package:weather_app/fave_service.dart';

class WeatherScreen extends StatefulWidget {
  final String? initialCity;

  const WeatherScreen({this.initialCity, super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  late Future<Map<String, dynamic>> weather;
  final TextEditingController _searchController = TextEditingController();
  late String _currentCity;
  bool _isFavorite = false;
  final FavoritesService _favoritesService = FavoritesService();
  List<String> _favoriteCities = [];

  Future<Map<String, dynamic>> getCurrentWeather() async {
    try {
      final res = await http.get(
        Uri.parse(
            'http://api.openweathermap.org/data/2.5/forecast?q=$_currentCity&APPID=${Env.openWeatherApiKey}'),
      );

      final data = jsonDecode(res.body);

      if (data["cod"] != "200") {
        throw 'City not found. Please try another city.';
      }

      // Check if city is already a favorite
      _checkIfFavorite();

      return data;
    } catch (e) {
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

  // Check if current city is in favorites
  void _checkIfFavorite() async {
    if (!_favoritesService.isUserLoggedIn) {
      setState(() {
        _isFavorite = false;
      });
      return;
    }

    // Get all favorites to check if current city is in the list
    final favorites = await _favoritesService.getFavorites().first;
    final cityNames =
        favorites.map((fav) => fav.cityName.toLowerCase()).toList();

    setState(() {
      _favoriteCities = cityNames;
      _isFavorite = cityNames.contains(_currentCity.toLowerCase());
    });
  }

  // Toggle favorite status
  void _toggleFavorite() async {
    if (!_favoritesService.isUserLoggedIn) {
      _showLoginRequiredDialog();
      return;
    }

    try {
      if (_isFavorite) {
        // Find the favorite to remove
        final favorites = await _favoritesService.getFavorites().first;
        final favoriteToRemove = favorites.firstWhere(
            (fav) => fav.cityName.toLowerCase() == _currentCity.toLowerCase());

        await _favoritesService.removeFavorite(favoriteToRemove.id);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$_currentCity removed from favorites')));
      } else {
        await _favoritesService.addFavorite(_currentCity);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$_currentCity added to favorites')));
      }

      setState(() {
        _isFavorite = !_isFavorite;
      });
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  // Show login required dialog
  void _showLoginRequiredDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Login Required'),
        content: Text('You need to be logged in to add favorites'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _currentCity = widget.initialCity ?? 'Salalah';
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
      body: SingleChildScrollView(
        child: Column(
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
            SizedBox(
              child: FutureBuilder(
                future: weather,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator.adaptive());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        snapshot.error.toString(),
                        style: TextStyle(fontSize: 16, color: Colors.red),
                      ),
                    );
                  }

                  final data = snapshot.data!;
                  final currentweatherData = data['list'][0];
                  final currenttemp = currentweatherData['main']['temp'];
                  final currentSky = currentweatherData['weather'][0]['main'];
                  final currentpressure =
                      currentweatherData['main']['pressure'];
                  final current_wind_speed =
                      currentweatherData['wind']['speed'];
                  final current_humidity =
                      currentweatherData['main']['humidity'];

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
                                filter:
                                    ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            _currentCity,
                                            style: const TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          IconButton(
                                            icon: Icon(
                                              _isFavorite
                                                  ? Icons.favorite
                                                  : Icons.favorite_border,
                                              color: _isFavorite
                                                  ? Colors.red
                                                  : null,
                                            ),
                                            onPressed: _toggleFavorite,
                                            tooltip: _isFavorite
                                                ? 'Remove from favorites'
                                                : 'Add to favorites',
                                          ),
                                        ],
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
                                          ? Lottie.asset(
                                              'assets/animations/cloudy.json',
                                              width: 100,
                                              height: 100)
                                          : (currentSky == 'Rain')
                                              ? Lottie.asset(
                                                  'assets/animations/rain.json',
                                                  width: 100,
                                                  height: 100)
                                              : Lottie.asset(
                                                  'assets/animations/sunny.json',
                                                  width: 100,
                                                  height: 100),
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
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 24),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 120,
                          child: ListView.builder(
                              itemCount: 5,
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (context, index) {
                                final hourlyforacast = data['list'][index + 1];
                                final time =
                                    DateTime.parse(hourlyforacast['dt_txt']);
                                final hourlSky =
                                    hourlyforacast['weather'][0]['main'];
                                final hourlytemp =
                                    hourlyforacast['main']['temp'].toString();
                                return HourlyForacastItem(
                                    time: DateFormat.Hm().format(time),
                                    icon: (hourlSky == 'Clouds')
                                        ? Lottie.asset(
                                            'assets/animations/cloudy.json',
                                            width: 36,
                                            height: 36)
                                        : (hourlSky == 'Rain')
                                            ? Lottie.asset(
                                                'assets/animations/rain.json',
                                                width: 36,
                                                height: 36)
                                            : Lottie.asset(
                                                'assets/animations/sunny.json',
                                                width: 36,
                                                height: 36),
                                    temp:
                                        '${(double.parse(hourlytemp) - 273.15).toStringAsFixed(1)}°C');
                              }),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "Additional Information",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 24),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Additonal_info(
                              icon: Lottie.asset('assets/animations/humid.json',
                                  width: 80, height: 80),
                              label: "Humidity",
                              value: "$current_humidity%",
                            ),
                            Additonal_info(
                              icon: Lottie.asset(
                                  'assets/animations/windspeed.json',
                                  width: 80,
                                  height: 80),
                              label: "Wind Speed",
                              value: "${current_wind_speed}m/s",
                            ),
                            Additonal_info(
                              icon: Lottie.asset('assets/animations/pre.json',
                                  width: 80, height: 80),
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
      ),
    );
  }
}
