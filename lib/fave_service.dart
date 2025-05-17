import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:weather_app/fave_moudle.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:weather_app/config/env.dart';

class FavoritesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collection reference
  CollectionReference get _favoritesCollection =>
      _firestore.collection('favorites');

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Check if user is logged in
  bool get isUserLoggedIn => _auth.currentUser != null;

  // Get all favorites for current user
  Stream<List<FavoriteCity>> getFavorites() {
    if (!isUserLoggedIn) {
      return Stream.value([]);
    }

    return _favoritesCollection
        .where('userId', isEqualTo: currentUserId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return FavoriteCity.fromFirestore(
            doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // Add city to favorites
  Future<void> addFavorite(String cityName) async {
    if (!isUserLoggedIn) {
      throw Exception('User not logged in');
    }

    // Check if the city already exists in favorites
    QuerySnapshot existing = await _favoritesCollection
        .where('userId', isEqualTo: currentUserId)
        .where('cityName', isEqualTo: cityName)
        .get();

    if (existing.docs.isNotEmpty) {
      throw Exception('City already in favorites');
    }

    // Get initial weather data
    Map<String, dynamic>? weatherData = await _fetchWeatherData(cityName);

    // Add to favorites
    await _favoritesCollection.add({
      'cityName': cityName,
      'userId': currentUserId,
      'temperature': weatherData?['temperature'],
      'weatherStatus': weatherData?['weatherStatus'],
    });
  }

  // Remove city from favorites
  Future<void> removeFavorite(String favoriteId) async {
    if (!isUserLoggedIn) {
      throw Exception('User not logged in');
    }

    await _favoritesCollection.doc(favoriteId).delete();
  }

  // Update favorite weather data
  Future<void> updateFavoriteWeatherData(FavoriteCity favorite) async {
    if (!isUserLoggedIn) {
      throw Exception('User not logged in');
    }

    Map<String, dynamic>? weatherData =
        await _fetchWeatherData(favorite.cityName);

    if (weatherData != null) {
      await _favoritesCollection.doc(favorite.id).update({
        'temperature': weatherData['temperature'],
        'weatherStatus': weatherData['weatherStatus'],
      });
    }
  }

  // Fetch weather data for a city
  Future<Map<String, dynamic>?> _fetchWeatherData(String cityName) async {
    try {
      final response = await http.get(
        Uri.parse(
            'http://api.openweathermap.org/data/2.5/forecast?q=$cityName&APPID=${Env.openWeatherApiKey}'),
      );

      if (response.statusCode != 200) {
        return null;
      }

      final data = jsonDecode(response.body);

      if (data["cod"] != "200") {
        return null;
      }

      final currentWeatherData = data['list'][0];
      final currentTemp = currentWeatherData['main']['temp'];
      final currentSky = currentWeatherData['weather'][0]['main'];

      return {
        'temperature': '${(currentTemp - 273.15).toStringAsFixed(1)}°C',
        'weatherStatus': currentSky,
      };
    } catch (e) {
      debugPrint('Error fetching weather data: $e');
      return null;
    }
  }

  // Update all favorites weather data
  Future<void> updateAllFavoritesWeatherData() async {
    if (!isUserLoggedIn) {
      return;
    }

    QuerySnapshot favorites = await _favoritesCollection
        .where('userId', isEqualTo: currentUserId)
        .get();

    for (var doc in favorites.docs) {
      FavoriteCity favorite = FavoriteCity.fromFirestore(
          doc.data() as Map<String, dynamic>, doc.id);
      await updateFavoriteWeatherData(favorite);
    }
  }
}