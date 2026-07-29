import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const SecuriteImeiApp());
}

class SecuriteImeiApp extends StatelessWidget {
  const SecuriteImeiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sécurité IMEI & GPS',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF020617),
        primaryColor: const Color(0xFF4F46E5),
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _imeiController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  bool _isLoading = false;
  String _statusMessage = '';

  // Votre URL Vercel
  final String apiUrl = 'https://plateforme-imei-securite.vercel.app/api';

  Future<void> _envoyerImeiEtGps() async {
    final imei = _imeiController.text.trim();
    final username = _usernameController.text.trim();

    if (imei.isEmpty || username.isEmpty) {
      setState(() {
        _statusMessage = 'Veuillez remplir tous les champs.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _statusMessage = 'Activation du capteur GPS et localisation...';
    });

    // Simulation d'un court délai pour simuler la recherche satellite GPS
    await Future.delayed(const Duration(seconds: 1));

    try {
      // Coordonnées GPS simulées (prêtes à être remplacées par le vrai GPS sur le téléphone final)
      double simulatedLatitude = 5.3600; 
      double simulatedLongitude = -4.0083;

      setState(() {
        _statusMessage = 'Transmission des données sécurisées au serveur...';
      });

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'imei': imei,
          'owner': username,
          'latitude': simulatedLatitude,
          'longitude': simulatedLongitude,
          'status': 'ACTIF_AVEC_GPS',
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        setState(() {
          _statusMessage = 'Appareil et position GPS associés avec succès !';
        });
      } else {
        setState(() {
          _statusMessage = 'Erreur lors de la synchronisation serveur.';
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Erreur réseau : Impossible de joindre le serveur.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sécurité Nationale • IMEI & GPS', style: TextStyle(fontSize: 15)),
        backgroundColor: const Color(0xFF0F172A),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.my_location_rounded, size: 60, color: Color(0xFF4F46E5)),
            const SizedBox(height: 20),
            const Text(
              'Enregistrement avec Géolocalisation',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Associez votre IMEI pour permettre le suivi de position.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Votre nom d\'utilisateur',
                filled: true,
                fillColor: const Color(0xFF0F172A),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _imeiController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Numéro IMEI (15 chiffres)',
                filled: true,
                fillColor: const Color(0xFF0F172A),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _envoyerImeiEtGps,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4F46E5),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Associer et envoyer le GPS', style: TextStyle(fontSize: 15, color: Colors.white)),
            ),
            const SizedBox(height: 20),
            if (_statusMessage.isNotEmpty)
              Text(
                _statusMessage,
                style: TextStyle(
                  color: _statusMessage.contains('succès') ? Colors.greenAccent : Colors.redAccent,
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }
}
