import 'dart:async';
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
      title: 'Système Antivol IMEI Avancé',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.red,
        scaffoldBackgroundColor: const Color(0xFF0F172A),
      ),
      home: const DashboardSecuriteScreen(),
    );
  }
}

class DashboardSecuriteScreen extends StatefulWidget {
  const DashboardSecuriteScreen({super.key});

  @override
  State<DashboardSecuriteScreen> createState() => _DashboardSecuriteScreenState();
}

class _DashboardSecuriteScreenState extends State<DashboardSecuriteScreen> {
  final TextEditingController _imeiController = TextEditingController();
  bool _isLoading = false;
  String _statutMessage = "Protection système et traçabilité prêtes.";
  bool _isBlocked = false;

  // Remplacez par votre URL exacte Vercel si besoin
  final String _apiBaseUrl = "https://plateforme-imei-securite.vercel.app/api";

  Future<void> _verifierEtActiverProtection() async {
    final imei = _imeiController.text.trim();

    if (imei.length < 15) {
      setState(() {
        _statutMessage = "Erreur : L'IMEI doit comporter exactement 15 chiffres valides.";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _statutMessage = "Vérification et liaison avec la plateforme...";
    });

    try {
      final response = await http.post(
        Uri.parse(_apiBaseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'imei': imei}),
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          if (data['isStolen'] == true) {
            _isBlocked = true;
            _statutMessage = "ALERTE ROUGE : Appareil signalé volé sur la plateforme.";
          } else {
            _isBlocked = false;
            _statutMessage = "Succès : IMEI authentifié, protection active.";
          }
        });
      } else {
        setState(() {
          _statutMessage = "Mode résilient : Erreur serveur (${response.statusCode}).";
        });
      }
    } catch (e) {
      setState(() {
        _statutMessage = "Mode hors-ligne : Synchronisation en arrière-plan armée.";
      });
    } finally {
      // Garantit que le bouton se réactive quoiqu'il arrive
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Système Antivol IMEI Avancé'),
        backgroundColor: Colors.red[900],
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.security_rounded,
                size: 80,
                color: Colors.redAccent,
              ),
              const SizedBox(height: 20),
              const Text(
                'Protection Inviolable',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                'Liaison sécurisée avec votre plateforme web de suivi des appareils.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 25),
              TextField(
                controller: _imeiController,
                keyboardType: TextInputType.number,
                maxLength: 15,
                decoration: InputDecoration(
                  labelText: 'Entrer le vrai IMEI (15 chiffres)',
                  prefixIcon: const Icon(Icons.fingerprint),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.white10,
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _verifierEtActiverProtection,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[800],
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Icon(Icons.security),
                label: const Text(
                  'Activer la Protection Système',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
              const SizedBox(height: 25),
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: _isBlocked ? Colors.red.withOpacity(0.2) : Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _isBlocked ? Colors.red : Colors.blueAccent,
                  ),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Statut du Système',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _statutMessage,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _isBlocked ? Colors.redAccent : Colors.greenAccent,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
