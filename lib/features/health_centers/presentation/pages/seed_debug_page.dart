import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../data/datasources/firestore_seeder.dart';

/// Écran de développement : se connecte avec le compte de seeding puis
/// lance le seeding OSM -> Firestore. À retirer avant la démo.
class SeedDebugPage extends StatefulWidget {
  const SeedDebugPage({super.key});

  @override
  State<SeedDebugPage> createState() => _SeedDebugPageState();
}

class _SeedDebugPageState extends State<SeedDebugPage> {
  final _email = TextEditingController(text: 'seeder@mediguide.test');
  final _password = TextEditingController();
  final _logs = <String>[];
  bool _force = false;
  bool _running = false;

  void _log(String message) {
    debugPrint(message);
    if (mounted) setState(() => _logs.add(message));
  }

  Future<void> _run() async {
    setState(() {
      _running = true;
      _logs.clear();
    });
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _email.text.trim(),
        password: _password.text,
      );
      _log('Connecté en tant que ${_email.text.trim()}');
      _log('UID : ${FirebaseAuth.instance.currentUser?.uid}');

      final count = await FirestoreSeeder.seedFromOsm(
        force: _force,
        onLog: _log,
      );
      _log('Terminé : $count centres écrits.');
    } catch (e) {
      _log('ERREUR : $e');
    } finally {
      if (mounted) setState(() => _running = false);
    }
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) return const SizedBox.shrink();

    return Scaffold(
      appBar: AppBar(title: const Text('Seeding (debug)')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _email,
              decoration:
                  const InputDecoration(labelText: 'Email du compte seeder'),
            ),
            TextField(
              controller: _password,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Mot de passe'),
            ),
            CheckboxListTile(
              value: _force,
              onChanged:
                  _running ? null : (v) => setState(() => _force = v ?? false),
              title: const Text(
                  'Forcer (même si la base contient déjà des données)'),
              controlAffinity: ListTileControlAffinity.leading,
            ),
            ElevatedButton(
              onPressed: _running ? null : _run,
              child: Text(_running ? 'En cours...' : 'Lancer le seeding'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _logs.length,
                itemBuilder: (_, i) => Text(_logs[i]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
