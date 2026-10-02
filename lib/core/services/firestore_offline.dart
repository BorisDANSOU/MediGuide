import 'package:cloud_firestore/cloud_firestore.dart';

/// Active le cache local de Firestore pour que les centres déjà consultés
/// restent lisibles sans réseau.
///
/// À appeler dans `main()`, juste après `Firebase.initializeApp(...)` et
/// AVANT toute lecture Firestore.
///
/// - Android / iOS : la persistance est activée par défaut, ce réglage
///   ne fait que l'expliciter.
/// - Web : elle est désactivée par défaut, c'est ce réglage qui l'active.
void configureFirestoreOffline() {
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );
}
