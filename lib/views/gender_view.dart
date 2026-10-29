import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class GenderView extends StatefulWidget {
  const GenderView({super.key});

  @override
  State<GenderView> createState() => _GenderViewState();
}

class _GenderViewState extends State<GenderView> {
  final TextEditingController _controller = TextEditingController();
  String? _gender;
  double? _probability;
  bool _isLoading = false;

  Future<void> _predictGender() async {
    final name = _controller.text.trim();
    if (name.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final cleanName = Uri.encodeComponent(name);

      final url = Uri.https('api.genderize.io', '/', {'name': cleanName});

      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'User-Agent': 'Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _gender = data['gender']; // Devuelve 'male', 'female' o null si no se reconoce
          _probability = (data['probability'] as num?)?.toDouble();
        });

        if (_gender == null && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No se pudo determinar el género para ese nombre.')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error en la API: Código ${response.statusCode}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error de conexión: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Color cardColor = Colors.grey.shade200;
    Color textColor = Colors.black;
    IconData icon = Icons.person_outline;

    if (_gender == 'male') {
      cardColor = Colors.blue.shade100;
      textColor = Colors.blue.shade900;
      icon = Icons.male;
    } else if (_gender == 'female') {
      cardColor = Colors.pink.shade100;
      textColor = Colors.pink.shade900;
      icon = Icons.female;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Predicción de Género'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Ingrese un nombre',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.search),
              ),
              onSubmitted: (_) => _predictGender(),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _predictGender,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Predecir Género'),
            ),
            const SizedBox(height: 30),
            if (_gender != null)
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                padding: const EdgeInsets.all(25.0),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Icon(icon, size: 80, color: textColor),
                    const SizedBox(height: 10),
                    Text(
                      'Género: ${_gender == 'male' ? 'Masculino' : 'Femenino'}',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    if (_probability != null) ...[
                      const SizedBox(height: 5),
                      Text(
                        'Probabilidad: ${(_probability! * 100).toStringAsFixed(1)}%',
                        style: TextStyle(fontSize: 16, color: textColor),
                      ),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}