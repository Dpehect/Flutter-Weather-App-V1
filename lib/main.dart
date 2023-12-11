import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OpenWeatherMap Uygulaması',
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
  final String apiKey = 'f1d929c6b206953edeb06207547f085a';
  late Future<WeatherData?> weatherData;
  TextEditingController cityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    weatherData = fetchWeatherData('Adana');
  }

  Future<WeatherData?> fetchWeatherData(String cityName) async {
    try {
      final response = await http.get(
        Uri.parse(
            'http://api.openweathermap.org/data/2.5/weather?q=$cityName&appid=$apiKey&lang=tr'), // lang parametresi eklenerek Türkçe dil kullanımı sağlanır
      );

      if (response.statusCode == 200) {
        return WeatherData.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Hava durumu verileri getirilemedi');
      }
    } catch (e) {
      throw Exception('Hava durumu verileri getirilirken bir hata oluştu: $e');
    }
  }

  void updateWeather() {
    String cityName = cityController.text;
    if (cityName.isNotEmpty) {
      setState(() {
        weatherData = fetchWeatherData(cityName);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hava Durumu'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: cityController,
                decoration: InputDecoration(
                  labelText: 'Şehir Adı',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: updateWeather,
              child: Text('Ara'),
            ),
            SizedBox(height: 20),
            FutureBuilder<WeatherData?>(
              future: weatherData,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Hata: ${snapshot.error}');
                } else if (snapshot.data == null) {
                  return Text('Veri bulunamadı');
                }

                final data = snapshot.data!;

                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Şehir: ${data.city}',
                      style: TextStyle(fontSize: 20),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Sıcaklık: ${data.temperature}°C',
                      style: TextStyle(fontSize: 20),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Durum: ${translateWeatherStatus(data.description)}', // Hava durumu durumunu çevirmek için fonksiyonu çağırıyoruz
                      style: TextStyle(fontSize: 20),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Hava durumu durumlarını Türkçe'ye çeviren fonksiyon
  String translateWeatherStatus(String status) {
    switch (status.toLowerCase()) {
      case 'clear':
        return 'Açık';
      case 'clouds':
        return 'Bulutlu';
      case 'rain':
        return 'Yağmurlu';
      case 'thunderstorm':
        return 'Gök gürültülü fırtına';
      case 'snow':
        return 'Karlı';
      default:
        return status;
    }
  }
}

class WeatherData {
  final String city;
  final double temperature;
  final String description;

  WeatherData({
    required this.city,
    required this.temperature,
    required this.description,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      city: json['name'],
      temperature: json['main']['temp'].toDouble(),
      description: json['weather'][0]['main'],
    );
  }
}
