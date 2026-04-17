import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dt_mobile/models/response/weather_response.dart';

class WeatherCard extends StatefulWidget {
  const WeatherCard({super.key});

  @override
  State<WeatherCard> createState() => _WeatherCardState();
}

class _WeatherCardState extends State<WeatherCard> {
  WeatherData? weatherData;
  bool isLoading = true;
  String errorMessage = '';

  final String baseUrl = 'http://3.231.62.206:5000/api/v1';

  @override
  void initState() {
    super.initState();
    _loadWeatherData();
  }

  Future<void> _loadWeatherData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        print('Token not found');
        setState(() {
          isLoading = false;
          errorMessage = 'Token not found';
        });
        return;
      }

      print('Weather API Call Start...');

      // API call - Latitude aur longitude ke saath
      final response = await http.get(
        Uri.parse('$baseUrl/weather?latitude=33.6844&longitude=73.0479'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception('Connection timeout'),
      );

      if (response.statusCode == 200) {
        final weatherResponse = WeatherResponse.fromJson(jsonDecode(response.body));

        print('Weather API Success');
        print('Response: ${response.body}');

        if (weatherResponse.data != null) {
          setState(() {
            weatherData = weatherResponse.data;
            isLoading = false;
          });

          print(' Temperature: ${weatherData?.currentWeather?.temperature}°C');
          print(' Wind Speed: ${weatherData?.currentWeather?.windspeed} km/h');
          print(' Timezone: ${weatherData?.timezone}');
        } else {
          setState(() {
            isLoading = false;
            errorMessage = 'No weather data';
          });
        }
      } else {
        print(' Weather API Error: ${response.statusCode}');
        setState(() {
          isLoading = false;
          errorMessage = 'Error: ${response.statusCode}';
        });
      }
    } catch (e) {
      print(' Exception: ${e.toString()}');
      setState(() {
        isLoading = false;
        errorMessage = 'Error: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
          ? Center(child: Text('Error: $errorMessage'))
          : weatherData == null
          ? const Center(child: Text('No weather data'))
          : Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  weatherData!.timezone,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  '${weatherData!.currentWeather?.temperature.toStringAsFixed(1)}°C',
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Wind: ${weatherData!.currentWeather?.windspeed.toStringAsFixed(1)} km/h',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.green,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          _buildWeatherIcon(),
        ],
      ),
    );
  }

  Widget _buildWeatherIcon() {
    return SizedBox(
      width: 100,
      height: 100,
      child: Image.asset(
        'assets/images/cloud.png',
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(
            Icons.wb_cloudy,
            size: 60,
            color: Colors.grey,
          );
        },
      ),
    );
  }
}