// Helper functions
double _toDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  return 0.0;
}

int _toInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is double) return value.toInt();
  return 0;
}

class WeatherResponse {
  final String message;
  final WeatherData? data;

  WeatherResponse({
    required this.message,
    this.data,
  });

  factory WeatherResponse.fromJson(Map<String, dynamic> json) {
    return WeatherResponse(
      message: json['message'] ?? '',
      data: json['data'] != null ? WeatherData.fromJson(json['data']) : null,
    );
  }
}

class WeatherData {
  final double latitude;
  final double longitude;
  final String timezone;
  final CurrentWeather? currentWeather;
  final Daily? daily;

  WeatherData({
    required this.latitude,
    required this.longitude,
    required this.timezone,
    this.currentWeather,
    this.daily,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      latitude: _toDouble(json['latitude']),
      longitude: _toDouble(json['longitude']),
      timezone: json['timezone'] ?? 'Unknown',
      currentWeather: json['current_weather'] != null
          ? CurrentWeather.fromJson(json['current_weather'])
          : null,
      daily: json['daily'] != null
          ? Daily.fromJson(json['daily'])
          : null,
    );
  }
}

class CurrentWeather {
  final double temperature;
  final double windspeed;
  final int weathercode;
  final int isDay;

  CurrentWeather({
    required this.temperature,
    required this.windspeed,
    required this.weathercode,
    required this.isDay,
  });

  factory CurrentWeather.fromJson(Map<String, dynamic> json) {
    return CurrentWeather(
      temperature: _toDouble(json['temperature']),
      windspeed: _toDouble(json['windspeed']),
      weathercode: _toInt(json['weathercode']),
      isDay: _toInt(json['is_day']),
    );
  }
}

class Daily {
  final List<double> maxTemp;
  final List<double> minTemp;
  final List<int> humidity;

  Daily({
    required this.maxTemp,
    required this.minTemp,
    required this.humidity,
  });

  factory Daily.fromJson(Map<String, dynamic> json) {
    return Daily(
      maxTemp: _toDoubleList(json['temperature_2m_max']),
      minTemp: _toDoubleList(json['temperature_2m_min']),
      humidity: _toIntList(json['relative_humidity_2m_max']),
    );
  }
}

// Helper for List<double>
List<double> _toDoubleList(dynamic value) {
  if (value == null) return [];
  if (value is List) {
    return value.map((e) => _toDouble(e)).toList();
  }
  return [];
}

// Helper for List<int>
List<int> _toIntList(dynamic value) {
  if (value == null) return [];
  if (value is List) {
    return value.map((e) => _toInt(e)).toList();
  }
  return [];
}