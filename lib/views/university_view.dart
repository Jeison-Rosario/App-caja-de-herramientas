import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class UniversityView extends StatefulWidget {
  const UniversityView({super.key});

  @override
  State<UniversityView> createState() => _UniversityViewState();
}

class _UniversityViewState extends State<UniversityView> {
  final TextEditingController _controller = TextEditingController(text: 'Dominican Republic');
  List<dynamic> _universities = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchUniversities();
  }

  Future<void> _fetchUniversities() async {
    final country = _controller.text.trim();
    if (country.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final encodedCountry = Uri.encodeComponent(country);
      final response = await http.get(
        Uri.parse('https://adamix.net/proxy.php?country=$encodedCountry'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _universities = data is List ? data : [];
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al obtener universidades')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _openUrl(String urlString) async {
    if (!urlString.startsWith('http://') && !urlString.startsWith('https://')) {
      urlString = 'http://$urlString';
    }
    final Uri url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo abrir el enlace: $urlString')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Universidades'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Nombre del país (en inglés)',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _fetchUniversities,
                ),
              ),
              onSubmitted: (_) => _fetchUniversities(),
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (_universities.isEmpty)
              const Expanded(
                child: Center(child: Text('No se encontraron universidades.')),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: _universities.length,
                  itemBuilder: (context, index) {
                    final uni = _universities[index];
                    final name = uni['name'] ?? 'Sin nombre';
                    final domains = (uni['domains'] as List?)?.join(', ') ?? 'N/A';
                    final webPages = (uni['web_pages'] as List?) ?? [];
                    final mainWeb = webPages.isNotEmpty ? webPages.first : '';

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        leading: const Icon(Icons.school, color: Colors.blueAccent),
                        title: Text(
                          name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text('Dominio: $domains'),
                            if (mainWeb.isNotEmpty)
                              GestureDetector(
                                onTap: () => _openUrl(mainWeb),
                                child: Text(
                                  mainWeb,
                                  style: const TextStyle(
                                    color: Colors.blue,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        trailing: mainWeb.isNotEmpty
                            ? IconButton(
                          icon: const Icon(Icons.open_in_new, color: Colors.blue),
                          onPressed: () => _openUrl(mainWeb),
                        )
                            : null,
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}