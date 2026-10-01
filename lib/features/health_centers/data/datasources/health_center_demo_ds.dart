import '../../domain/entities/health_center_entity.dart';

/// Centres de santé de démonstration (accueil, recherche, fiche), en attendant la collection
/// Firestore `medical_centers` (voir SCHEMA.md, travail de DJOBO).
///
/// Les coordonnées sont approximatives. Les seuls numéros renseignés sont
/// ceux validés par l'équipe ; les autres restent `null` (bouton « Appeler »
/// masqué), comme le prévoit le schéma.
class HealthCenterDemoDataSource {
  const HealthCenterDemoDataSource();

  Future<List<HealthCenterEntity>> loadCenters({
    required String country,
    required String city,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return _centers
        .where((c) => c.country == country && c.city == city)
        .toList();
  }

  static const _centers = <HealthCenterEntity>[
    // ------------------------------------------------------------ Lomé
    HealthCenterEntity(
      id: 'tg-chu-so',
      name: 'CHU Sylvanus Olympio',
      type: 'hospital',
      latitude: 6.1319,
      longitude: 1.2228,
      city: 'Lomé',
      country: 'Togo',
      phone: '+228 22 21 25 01',
      address: 'Boulevard du 13 Janvier',
      is24h: true,
    ),
    HealthCenterEntity(
      id: 'tg-chu-campus',
      name: 'CHU Campus',
      type: 'hospital',
      latitude: 6.1720,
      longitude: 1.2140,
      city: 'Lomé',
      country: 'Togo',
      address: 'Quartier Université',
      is24h: true,
    ),
    HealthCenterEntity(
      id: 'tg-clinique-paix',
      name: 'Clinique de la Paix',
      type: 'clinic',
      latitude: 6.1450,
      longitude: 1.2300,
      city: 'Lomé',
      country: 'Togo',
      address: 'Bè',
      openingHours: 'Mo-Sa 07:30-19:00',
    ),
    HealthCenterEntity(
      id: 'tg-ph-lagune',
      name: 'Pharmacie de la Lagune',
      type: 'pharmacy',
      latitude: 6.1400,
      longitude: 1.2150,
      city: 'Lomé',
      country: 'Togo',
      address: 'Boulevard circulaire',
      isGuard: true,
    ),
    HealthCenterEntity(
      id: 'tg-ph-avenir',
      name: "Pharmacie de l'Avenir",
      type: 'pharmacy',
      latitude: 6.1600,
      longitude: 1.2050,
      city: 'Lomé',
      country: 'Togo',
      address: 'Tokoin',
      isGuard: true,
    ),
    // ----------------------------------------------------- Ouagadougou
    HealthCenterEntity(
      id: 'bf-chu-yalgado',
      name: 'CHU Yalgado Ouédraogo',
      type: 'hospital',
      latitude: 12.3790,
      longitude: -1.5155,
      city: 'Ouagadougou',
      country: 'Burkina Faso',
      phone: '+226 25 31 16 55',
      address: 'Avenue Kwame Nkrumah',
      is24h: true,
    ),
    HealthCenterEntity(
      id: 'bf-chu-bogodogo',
      name: 'CHU de Bogodogo',
      type: 'hospital',
      latitude: 12.3400,
      longitude: -1.4700,
      city: 'Ouagadougou',
      country: 'Burkina Faso',
      address: 'Bogodogo',
      is24h: true,
    ),
    HealthCenterEntity(
      id: 'bf-cma-pissy',
      name: 'CMA de Pissy',
      type: 'clinic',
      latitude: 12.3360,
      longitude: -1.5640,
      city: 'Ouagadougou',
      country: 'Burkina Faso',
      address: 'Pissy',
      openingHours: 'Mo-Sa 07:00-17:00',
    ),
    HealthCenterEntity(
      id: 'bf-ph-wendkuuni',
      name: 'Pharmacie Wend-Kuuni',
      type: 'pharmacy',
      latitude: 12.3900,
      longitude: -1.5000,
      city: 'Ouagadougou',
      country: 'Burkina Faso',
      address: 'Tanghin',
      isGuard: true,
    ),
    HealthCenterEntity(
      id: 'bf-ph-progres',
      name: 'Pharmacie du Progrès',
      type: 'pharmacy',
      latitude: 12.3680,
      longitude: -1.5250,
      city: 'Ouagadougou',
      country: 'Burkina Faso',
      address: 'Centre-ville',
      isGuard: true,
    ),
    // --------------------------------------------------------- Abidjan
    HealthCenterEntity(
      id: 'ci-chu-cocody',
      name: 'CHU de Cocody',
      type: 'hospital',
      latitude: 5.3450,
      longitude: -3.9890,
      city: 'Abidjan',
      country: "Côte d'Ivoire",
      phone: '+225 27 22 44 91 00',
      address: 'Boulevard de l’Université, Cocody',
      is24h: true,
    ),
    HealthCenterEntity(
      id: 'ci-chu-treichville',
      name: 'CHU de Treichville',
      type: 'hospital',
      latitude: 5.2950,
      longitude: -4.0040,
      city: 'Abidjan',
      country: "Côte d'Ivoire",
      address: 'Treichville',
      is24h: true,
    ),
    HealthCenterEntity(
      id: 'ci-pisam',
      name: 'PISAM',
      type: 'clinic',
      latitude: 5.3560,
      longitude: -3.9960,
      city: 'Abidjan',
      country: "Côte d'Ivoire",
      address: 'Rue des Jardins, Cocody',
      is24h: true,
    ),
    HealthCenterEntity(
      id: 'ci-ph-etoiles',
      name: 'Pharmacie des Étoiles',
      type: 'pharmacy',
      latitude: 5.3500,
      longitude: -4.0000,
      city: 'Abidjan',
      country: "Côte d'Ivoire",
      address: 'Carrefour Duncan, Cocody',
      isGuard: true,
    ),
    HealthCenterEntity(
      id: 'ci-ph-plateau',
      name: 'Pharmacie du Plateau',
      type: 'pharmacy',
      latitude: 5.3230,
      longitude: -4.0200,
      city: 'Abidjan',
      country: "Côte d'Ivoire",
      address: 'Plateau',
      isGuard: true,
    ),
  ];
}
