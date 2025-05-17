// ignore: unused_import
import 'package:cloud_firestore/cloud_firestore.dart';

class FavoriteCity {
  final String id;
  final String cityName;
  final String userId;

 
  String? temperature;
  String? weatherStatus;

  FavoriteCity({
    required this.id,
    required this.cityName,
    required this.userId,
    this.temperature,
    this.weatherStatus,
  });

  // Create from Firestore document
  factory FavoriteCity.fromFirestore(Map<String, dynamic> data, String docId) {
    return FavoriteCity(
      id: docId,
      cityName: data['cityName'] ?? '',
      userId: data['userId'] ?? '',
      temperature: data['temperature'],
      weatherStatus: data['weatherStatus'],
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'cityName': cityName,
      'userId': userId,
      'temperature': temperature,
      'weatherStatus': weatherStatus,
    };
  }


}