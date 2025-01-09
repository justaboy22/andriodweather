import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WeatherApp extends StatefulWidget {
  @override
  _WeatherAppState createState() => _WeatherAppState();
}

class _WeatherAppState extends State<WeatherApp> {
  final TextEditingController _cityController = TextEditingController();
  String city = ""; // No default city
  String description = "";
  String icon = "assets/images/cloudy.png"; // Default icon path
  double temperature = 0.0;
  double windSpeed = 0.0;
  int humidity = 0;

  // Map condition to appropriate icon path
  String getWeatherIcon(String condition) {
    if (condition.contains("sunny") || condition.contains("clear")) {
      return "assets/images/sunny.png";
    } else if (condition.contains("cloud")) {
      return "assets/images/cloudy.png";
    } else if (condition.contains("rain")) {
      return "assets/images/rainy.png";
    } else if (condition.contains("snow")) {
      return "assets/images/snowy.png";
    } else if (condition.contains("storm") || condition.contains("thunder")) {
      return "assets/images/stormy.png";
    } else {
      return "assets/images/cloudy.png"; // Default icon
    }
  }

  // Fetch weather data from WeatherAPI
  Future<void> fetchWeather(String city) async {
    if (city.isEmpty) {
      showError("City name cannot be empty.");
      return;
    }

    const String apiKey = "34c06f05aa064a78a0d153850250801"; // Your WeatherAPI key
    final String apiUrl =
        "https://api.weatherapi.com/v1/current.json?key=$apiKey&q=$city&aqi=no";

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          description = data["current"]["condition"]["text"].toLowerCase();
          temperature = data["current"]["temp_c"];
          windSpeed = data["current"]["wind_kph"] / 3.6; // Convert kph to m/s
          humidity = data["current"]["humidity"];
          city = data["location"]["name"]; // Update city name to match API response
          icon = getWeatherIcon(description); // Update icon dynamically
        });
      } else {
        showError("City not found. Please enter a valid city name.");
      }
    } catch (e) {
      showError("Error fetching weather data. Check your internet connection.");
    }
  }

  // Show error as a snackbar
  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Weather App"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // City input box
            TextField(
              controller: _cityController,
              decoration: InputDecoration(
                labelText: "Enter City",
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    fetchWeather(_cityController.text.trim());
                  },
                ),
              ),
              onSubmitted: (value) {
                fetchWeather(value.trim());
              },
            ),
            const SizedBox(height: 20),
            // Weather Info
            if (description.isNotEmpty)
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // City Name
                    Text(
                      city,
                      style: const TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Weather Icon
                    Image.asset(
                      icon,
                      height: 100,
                    ),
                    const SizedBox(height: 10),
                    // Weather Description
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Temperature
                    Text(
                      "${temperature.toStringAsFixed(1)}° C",
                      style: const TextStyle(
                        fontSize: 80,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Additional Info
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _infoItem("Wind", "${windSpeed.toStringAsFixed(1)} m/s"),
                          _infoItem("Humidity", "$humidity%"),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _infoItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w400,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}