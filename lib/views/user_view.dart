import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class UserView extends StatefulWidget {
  const UserView({super.key});

  @override
  State<UserView> createState() => _UserViewState();
}

class _UserViewState extends State<UserView> {
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRandomUser();
  }

  Future<void> _fetchRandomUser() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse('https://randomuser.me/api/?results=1'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _userData = data['results'][0];
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al obtener usuario aleatorio')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = '';
    if (_userData != null && _userData!['dob']['date'] != null) {
      DateTime dob = DateTime.parse(_userData!['dob']['date']);
      formattedDate = DateFormat('dd/MM/yyyy').format(dob);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Usuario Aleatorio'),
      ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : _userData == null
            ? const Text('No se pudieron cargar los datos.')
            : Padding(
          padding: const EdgeInsets.all(20.0),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 55,
                    backgroundImage: NetworkImage(
                      _userData!['picture']['large'],
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    '${_userData!['name']['first']} ${_userData!['name']['last']}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ListTile(
                    leading: const Icon(Icons.cake, color: Colors.blueAccent),
                    title: const Text('Fecha de Nacimiento'),
                    subtitle: Text(formattedDate),
                  ),
                  ListTile(
                    leading: const Icon(Icons.hourglass_bottom, color: Colors.blueAccent),
                    title: const Text('Edad'),
                    subtitle: Text('${_userData!['dob']['age']} años'),
                  ),
                  const SizedBox(height: 15),
                  ElevatedButton.icon(
                    onPressed: _fetchRandomUser,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Cargar Otro Usuario'),
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