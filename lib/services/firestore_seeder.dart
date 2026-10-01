import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/medical_center.dart';
import 'osm_medical_service.dart';

class FirestoreSeeder {
  static const _collection = 'medical_centers';

  // Limite Firestore : 500 opérations par batch. On garde de la marge.
  static const _batchSize = 500;

  /// Écrit les centres par lots. Idempotent : l'ID du document est l'ID OSM
  /// et `merge: true` évite d'écraser les champs saisis à la main (isGuard...).
  /// Retourne le nombre de centres écrits.
  static Future<int> seed(List<MedicalCenter> centers) async {
    final firestore = FirebaseFirestore.instance;
    final col = firestore.collection(_collection);
    var written = 0;

    for (var i = 0; i < centers.length; i += _batchSize) {
      final chunk = centers.sublist(i, min(i + _batchSize, centers.length));
      final batch = firestore.batch();
      for (final c in chunk) {
        batch.set(col.doc(c.id), c.toSeedMap(), SetOptions(merge: true));
      }
      await batch.commit();
      written += chunk.length;
    }
    return written;
  }

  /// À appeler manuellement (bouton caché / debug), PAS au lancement de l'app
  /// pour tous les utilisateurs.
  ///
  /// - Ne fait rien hors mode debug.
  /// - Ne fait rien si la collection contient déjà des données (sauf `force`).
  /// - Nécessite d'être connecté avec le compte autorisé dans firestore.rules.
  static Future<int> seedFromOsm({
    bool force = false,
    void Function(String message)? onLog,
  }) async {
    if (!kDebugMode) return 0;

    final col = FirebaseFirestore.instance.collection(_collection);
    if (!force) {
      final existing = await col.limit(1).get();
      if (existing.docs.isNotEmpty) {
        onLog?.call('Base déjà peuplée, seeding ignoré (force: true pour relancer).');
        return 0;
      }
    }

    final centers = await OsmMedicalService.fetchAll(onLog: onLog);
    if (centers.isEmpty) {
      onLog?.call('Aucun centre récupéré, rien à écrire.');
      return 0;
    }

    final written = await seed(centers);
    onLog?.call('Seeding terminé : $written centres écrits.');
    return written;
  }
}