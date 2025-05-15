import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:weather_app/app_drawer.dart';
import 'package:weather_app/fave_city.dart';
import 'package:weather_app/fave_service.dart';
import 'package:weather_app/weather_screen.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final FavoritesService _favoritesService = FavoritesService();

  @override
  void initState() {
    super.initState();
    // Update weather data for all favorites when page loads
    _favoritesService.updateAllFavoritesWeatherData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Favorite Cities",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => _favoritesService.updateAllFavoritesWeatherData(),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: StreamBuilder<List<FavoriteCity>>(
        stream: _favoritesService.getFavorites(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error: ${snapshot.error}",
                style: TextStyle(color: Colors.red),
              ),
            );
          }

          final favorites = snapshot.data ?? [];

          if (favorites.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Lottie.asset(
                    'assets/animations/weather.json',
                    width: 200,
                    height: 200,
                  ),
                  const SizedBox(height: 15),
                  Text(
                    "No favorite cities yet",
                    style: TextStyle(fontSize: 20),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => WeatherScreen()),
                      );
                    },
                    child: Text("Add Your First City"),
                  ),
                ],
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(12.0),
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.85,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final favorite = favorites[index];
                return _buildFavoriteCard(favorite);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => WeatherScreen()),
          );
        },
        child: Icon(Icons.add),
        tooltip: 'Add new favorite city',
      ),
    );
  }

  Widget _buildFavoriteCard(FavoriteCity favorite) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: () => _navigateToCityWeather(favorite.cityName),
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      favorite.cityName,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _confirmDelete(favorite),
                    iconSize: 22,
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              _getWeatherAnimation(favorite.weatherStatus),
              const SizedBox(height: 12),
              Text(
                favorite.temperature ?? 'Loading...',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                favorite.weatherStatus ?? '',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getWeatherAnimation(String? status) {
    if (status == null) {
      return SizedBox(
        height: 60,
        width: 60,
        child: CircularProgressIndicator(),
      );
    }

    switch (status) {
      case 'Clouds':
        return Lottie.asset('assets/animations/cloudy.json',
            height: 60, width: 60);
      case 'Rain':
        return Lottie.asset('assets/animations/rain.json',
            height: 60, width: 60);
      case 'Clear':
        return Lottie.asset('assets/animations/sunny.json',
            height: 60, width: 60);
      default:
        return Lottie.asset('assets/animations/weather.json',
            height: 60, width: 60);
    }
  }

  void _navigateToCityWeather(String cityName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WeatherScreen(initialCity: cityName),
      ),
    );
  }

  void _confirmDelete(FavoriteCity favorite) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Remove Favorite'),
        content: Text(
            'Are you sure you want to remove ${favorite.cityName} from your favorites?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _favoritesService.removeFavorite(favorite.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content:
                        Text('${favorite.cityName} removed from favorites')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Remove'),
          ),
        ],
      ),
    );
  }
}