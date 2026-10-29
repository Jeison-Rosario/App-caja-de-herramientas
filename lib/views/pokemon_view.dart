import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';

class PokemonView extends StatefulWidget {
  const PokemonView({super.key});

  @override
  State<PokemonView> createState() => _PokemonViewState();
}

class _PokemonViewState extends State<PokemonView> {
  final TextEditingController _controller = TextEditingController(text: 'pikachu');
  final AudioPlayer _audioPlayer = AudioPlayer();

  Map<String, dynamic>? _pokemonData;
  bool _isLoading = false;
  bool _isPlayingAudio = false;

  @override
  void initState() {
    super.initState();
    _fetchPokemon();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _fetchPokemon() async {
    final name = _controller.text.trim().toLowerCase();
    if (name.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse('https://pokeapi.co/api/v2/pokemon/$name'));
      if (response.statusCode == 200) {
        setState(() {
          _pokemonData = json.decode(response.body);
        });
      } else {
        setState(() {
          _pokemonData = null;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pokémon no encontrado.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al conectar con la PokéAPI')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _playCry() async {
    if (_pokemonData == null) return;

    final cryUrl = _pokemonData!['cries']?['latest'] ?? _pokemonData!['cries']?['legacy'];
    if (cryUrl != null && cryUrl.toString().isNotEmpty) {
      setState(() {
        _isPlayingAudio = true;
      });
      await _audioPlayer.stop();
      await _audioPlayer.play(UrlSource(cryUrl));
      setState(() {
        _isPlayingAudio = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Este Pokémon no tiene audio disponible.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscador Pokémon'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Nombre o ID del Pokémon',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _fetchPokemon,
                ),
              ),
              onSubmitted: (_) => _fetchPokemon(),
            ),
            const SizedBox(height: 20),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_pokemonData != null)
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Image.network(
                        _pokemonData!['sprites']['other']['official-artwork']['front_default'] ??
                            _pokemonData!['sprites']['front_default'],
                        height: 180,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _pokemonData!['name'].toString().toUpperCase(),
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Chip(
                        avatar: const Icon(Icons.star, color: Colors.amber),
                        label: Text('Experiencia Base: ${_pokemonData!['base_experience']}'),
                      ),
                      const SizedBox(height: 15),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Habilidades:',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Wrap(
                        spacing: 8.0,
                        children: (_pokemonData!['abilities'] as List).map((a) {
                          final abilityName = a['ability']['name'];
                          return Chip(label: Text(abilityName));
                        }).toList(),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: _isPlayingAudio ? null : _playCry,
                        icon: const Icon(Icons.volume_up),
                        label: const Text('Escuchar Sonido'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}