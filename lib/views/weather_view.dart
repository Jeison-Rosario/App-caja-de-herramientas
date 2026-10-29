import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class WeatherView extends StatefulWidget {
  const WeatherView({super.key});

  @override
  State<WeatherView> createState() => _WeatherViewState();
}

class _WeatherViewState extends State<WeatherView> {
  double? _temp;
  double? _windSpeed;
  int? _weatherCode;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('es', null).then((_) {
      _fetchWeather();
    });
  }

  Future<void> _fetchWeather() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Coordenadas de Santo Domingo, Republica Dominicana
      final url = Uri.parse(
        'https://api.open-meteo.com/v1/forecast?latitude=18.4861&longitude=-69.9312&current_weather=true',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final currentWeather = data['current_weather'];
        setState(() {
          _temp = (currentWeather['temperature'] as num).toDouble();
          _windSpeed = (currentWeather['windspeed'] as num).toDouble();
          _weatherCode = currentWeather['weathercode'] as int;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al obtener el clima de RD')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _getWeatherDescription(int? code) {
    if (code == null) return 'Desconocido';
    if (code == 0) return 'Cielo despejado';
    if (code >= 1 && code <= 3) return 'Parcialmente nublado';
    if (code >= 45 && code <= 48) return 'Niebla';
    if (code >= 51 && code <= 67) return 'Lluvia ligera o moderada';
    if (code >= 80 && code <= 82) return 'Chubascos de lluvia';
    if (code >= 95) return 'Tormenta eléctrica';
    return 'Nublado con precipitaciones';
  }

  IconData _getWeatherIcon(int? code) {
    if (code == 0) return Icons.wb_sunny;
    if (code != null && code >= 1 && code <= 3) return Icons.wb_cloudy;
    if (code != null && code >= 51) return Icons.grain;
    return Icons.cloud;
  }

  @override
  Widget build(BuildContext context) {
    final todayStr = DateFormat('EEEE, d MMMM yyyy', 'es').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Clima en RD'),
      ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : _temp == null
            ? const Text('No se pudieron obtener los datos meteorológicos.')
            : Padding(
          padding: const EdgeInsets.all(20.0),
          child: Card(
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(28.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Santo Domingo, RD',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    todayStr,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                  const SizedBox(height: 25),
                  Icon(
                    _getWeatherIcon(_weatherCode),
                    size: 90,
                    color: Colors.orangeAccent,
                  ),
                  const SizedBox(height: 15),
                  Text(
                    '${_temp!.toStringAsFixed(1)} °C',
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _getWeatherDescription(_weatherCode),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Divider(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.air, color: Colors.blueGrey),
                      const SizedBox(width: 8),
                      Text('Viento: ${_windSpeed ?? 0} km/h'),
                    ],
                  ),
                  const SizedBox(height: 20),
                  IconButton(
                    icon: const Icon(Icons.refresh, size: 30),
                    onPressed: _fetchWeather,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}