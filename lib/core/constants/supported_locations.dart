/// Un lieu supporté par l'application : un pays et sa ville principale,
/// avec les coordonnées du centre (utilisées pour centrer la carte).
class SupportedLocation {
  const SupportedLocation({
    required this.country,
    required this.city,
    required this.latitude,
    required this.longitude,
  });

  final String country;
  final String city;
  final double latitude;
  final double longitude;
}

/// Liste des pays gérés par MediGuide (MVP : une ville par pays).
/// Les noms de pays sont écrits exactement comme dans Firestore
/// et dans le service Overpass, car ils servent de filtre aux requêtes.
class SupportedLocations {
  SupportedLocations._(); // Classe utilitaire

  static const List<SupportedLocation> all = [
    SupportedLocation(
      country: 'Togo',
      city: 'Lomé',
      latitude: 6.1375,
      longitude: 1.2123,
    ),
    SupportedLocation(
      country: 'Burkina Faso',
      city: 'Ouagadougou',
      latitude: 12.3714,
      longitude: -1.5197,
    ),
    SupportedLocation(
      country: "Côte d'Ivoire",
      city: 'Abidjan',
      latitude: 5.3600,
      longitude: -4.0083,
    ),
  ];

  /// Noms des pays, pour remplir une liste de choix
  static List<String> get countries => all.map((l) => l.country).toList();

  /// Retrouve le lieu d'un pays. Si le pays est inconnu, on prend le premier
  /// (Togo) plutôt que de planter.
  static SupportedLocation forCountry(String country) {
    return all.firstWhere((l) => l.country == country, orElse: () => all.first);
  }
}
