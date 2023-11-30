import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: WeatherScreen(),
    );
  }
}

class WeatherScreen extends StatefulWidget {
  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final String apiKey = '9d8f8fa7ab66232610c72102ef93e095'; // Replace with your OpenWeatherMap API key
  late String city;
  late String apiUrl;

  final TextEditingController _cityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    city = 'London'; // Default city
    apiUrl =
    'http://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey';
  }

  Future<Map<String, dynamic>> getWeather() async {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load weather data');
    }
  }

  void _updateWeather() {
    setState(() {
      city = _cityController.text;
      apiUrl =
      'http://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey';
    });
  }

  double kelvinToCelsius(double kelvin) {
    return kelvin - 273.15;
  }

  Color getBackgroundColor(String mainWeather) {
    switch (mainWeather.toLowerCase()) {
      case 'clear':
        return Colors.orangeAccent;
      case 'clouds':
        return Colors.blueGrey;
      case 'rain':
        return Colors.indigo;
      case 'snow':
        return Colors.lightBlueAccent;
      default:
        return Colors.blue;
    }
  }

  TextStyle getWeatherTextStyle() {
    return TextStyle(
      fontSize: 18,
      color: Colors.white,
    );
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Weather App'),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: double.infinity,
                // Set to double.infinity to occupy the available width
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _cityController,
                  decoration: InputDecoration(
                    labelText: 'Enter city',
                    border: OutlineInputBorder(),
                    // Add border for a more defined look
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                  ),
                  onSubmitted: (value) {
                    _updateWeather();
                  },
                ),
              ),
            ),
            ElevatedButton(
              onPressed: _updateWeather,
              child: Text('Get Weather'),
            ),
            Expanded(
              child: FutureBuilder(
                future: getWeather(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  } else {
                    final weatherData = snapshot.data as Map<String, dynamic>;
                    final mainWeather = weatherData['weather'][0]['main'];
                    final description = weatherData['weather'][0]['description'];
                    final temperatureKelvin = weatherData['main']['temp'];
                    final temperatureCelsius = kelvinToCelsius(
                        temperatureKelvin);
                    final windSpeed = weatherData['wind']['speed'];
                    final clouds = weatherData['clouds']['all'];
                    final cityName = weatherData['name'];

                    final cardBackgroundColor = getBackgroundColor(mainWeather);

                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Container(
                        width: 500,
                        child: Card(
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          color: cardBackgroundColor,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '$cityName',
                                style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                              SizedBox(height: 10),
                              Text(
                                '$mainWeather - $description',
                                style: TextStyle(
                                    fontSize: 18, color: Colors.white),
                              ),
                              SizedBox(height: 10),
                              Text(
                                'Temperature: ${temperatureCelsius
                                    .toStringAsFixed(1)}°C',
                                style: getWeatherTextStyle(),
                              ),
                              SizedBox(height: 10),
                              Text(
                                'Wind Speed: $windSpeed m/s',
                                style: getWeatherTextStyle(),
                              ),
                              SizedBox(height: 10),
                              Text(
                                'Clouds: $clouds%',
                                style: getWeatherTextStyle(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}