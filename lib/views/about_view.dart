import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutView extends StatelessWidget {
  const AboutView({super.key});

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Acerca de Mí'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircleAvatar(
                    radius: 65,
                    backgroundImage: AssetImage('assets/images/foto.png'),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Jeison Samuel Rosario Peralta',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Matrícula: 2023-1046',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Desarrollador de Software',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.blueAccent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Divider(height: 30),
                  ListTile(
                    leading: const Icon(Icons.email, color: Colors.blueAccent),
                    title: const Text('Correo Contacto'),
                    subtitle: const Text('jsrosario97@email.com'),
                    onTap: () => _launchUrl('mailto:jsrosario97@email.com'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.phone, color: Colors.blueAccent),
                    title: const Text('Teléfono'),
                    subtitle: const Text('+1 809-901-3169'),
                    onTap: () => _launchUrl('tel:+18099013169'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.web, color: Colors.blueAccent),
                    title: const Text('Portafolio / GitHub'),
                    subtitle: const Text('https://jeison-rosario.github.io/proyectos/'),
                    onTap: () => _launchUrl('https://jeison-rosario.github.io/proyectos/'),
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    'Disponible para oportunidades de trabajo y proyectos de desarrollo móvil o web.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic, color: Colors.grey),
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