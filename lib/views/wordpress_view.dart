import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class WordpressView extends StatefulWidget {
  const WordpressView({super.key});

  @override
  State<WordpressView> createState() => _WordpressViewState();
}

class _WordpressViewState extends State<WordpressView> {
  final String _siteUrl = 'https://kinsta.com';
  List<dynamic> _posts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLatestPosts();
  }

  Future<void> _fetchLatestPosts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('$_siteUrl/wp-json/wp/v2/posts?per_page=3'),
      );

      if (response.statusCode == 200) {
        setState(() {
          _posts = json.decode(response.body);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al cargar noticias de WordPress')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _openNewsUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  // Limpia etiquetas HTML que retornan en los campos title/excerpt de WordPress
  String _removeHtmlTags(String htmlString) {
    RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);
    return htmlString.replaceAll(exp, '').replaceAll('&nbsp;', ' ').replaceAll('&#8211;', '-');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Noticias WordPress'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Logo del sitio WordPress
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.web, size: 40, color: Colors.blue),
                  const SizedBox(width: 10),
                  Text(
                    'Kinsta Blog (WordPress)',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade900,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (_posts.isEmpty)
              const Expanded(child: Center(child: Text('No se encontraron noticias.')))
            else
              Expanded(
                child: ListView.builder(
                  itemCount: _posts.length,
                  itemBuilder: (context, index) {
                    final post = _posts[index];
                    final rawTitle = post['title']['rendered'] ?? '';
                    final rawExcerpt = post['excerpt']['rendered'] ?? '';
                    final link = post['link'] ?? '';

                    final title = _removeHtmlTags(rawTitle);
                    final excerpt = _removeHtmlTags(rawExcerpt);

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              excerpt.length > 150
                                  ? '${excerpt.substring(0, 150)}...'
                                  : excerpt,
                              style: TextStyle(color: Colors.grey.shade700),
                            ),
                            const SizedBox(height: 12),
                            Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton.icon(
                                onPressed: () => _openNewsUrl(link),
                                icon: const Icon(Icons.open_in_browser, size: 18),
                                label: const Text('Visitar Noticia'),
                              ),
                            ),
                          ],
                        ),
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