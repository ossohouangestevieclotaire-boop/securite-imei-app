import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:convert';

void main() {
  runApp(const SecuriteImeiApp());
}

class SecuriteImeiApp extends StatelessWidget {
  const SecuriteImeiApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sécurité IMEI',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const EnregistrementScreen(),
    );
  }
}

class EnregistrementScreen extends StatefulWidget {
  const EnregistrementScreen({Key? key}) : super(key: key);

  @override
  _EnregistrementScreenState createState() => _EnregistrementScreenState();
}

class _EnregistrementScreenState extends State<EnregistrementScreen> {
  static const platform = MethodChannel('securite.imei/device_admin');
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _imeiController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  bool _isLoading = false;

  // Demander l'activation des droits d'administrateur Android
  Future<void> _activerAdminDevice() async {
    try {
      await platform.invokeMethod('activerAdmin');
      _afficherMessage('Demande d\'administration envoyée.');
    } on PlatformException catch (e) {
      _afficherMessage('Erreur admin: ${e.message}');
    }
  }

  // Validation stricte de l'IMEI (15 chiffres)
  String? _validateImei(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer un numéro IMEI.';
    }
    final regExp = RegExp(r'^\d{15}$');
    if (!regExp.hasMatch(value)) {
      return 'L\'IMEI doit comporter exactement 15 chiffres.';
    }
    return null;
  }

  // Envoi sécurisé vers l'API Vercel
  Future<void> _soumettreDonnees() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 1. Vérification d'Internet obligatoire
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.none) {
        _afficherMessage('Erreur : Connexion Internet requise.');
        setState(() { _isLoading = false; });
        return;
      }

      // 2. Requête vers la plateforme Vercel
      final response = await http.post(
        Uri.parse('https://plateforme-imei-securite.vercel.app/api/devices'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'imei': _imeiController.text,
          'username': _usernameController.text,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _afficherMessage('Succès : Enregistré sur la plateforme en ligne !');
        _imeiController.clear();
        _usernameController.clear();
      } else {
        _afficherMessage('Erreur du serveur : ${response.body}');
      }
    } catch (e) {
      _afficherMessage('Erreur de connexion avec Vercel : $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _afficherMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sécurité IMEI - Anti-Vol'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Enregistrement Sécurisé & Protection',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _activerAdminDevice,
                icon: const Icon(Icons.security),
                label: const Text('Activer la protection système (Admin)'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Nom d\'utilisateur',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un nom d\'utilisateur.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _imeiController,
                keyboardType: TextInputType.number,
                maxLength: 15,
                decoration: const InputDecoration(
                  labelText: 'Numéro IMEI (15 chiffres)',
                  border: OutlineInputBorder(),
                ),
                validator: _validateImei,
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _soumettreDonnees,
                      child: const Text('Enregistrer sur Vercel'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
