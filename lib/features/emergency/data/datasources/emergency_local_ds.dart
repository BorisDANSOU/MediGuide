import '../../domain/entities/emergency_hospital_entity.dart';
import '../../domain/entities/emergency_number_entity.dart';
import '../../domain/entities/emergency_pharmacy_entity.dart';
import '../../domain/entities/user_location_entity.dart';

/// Source de données locale statique pour la Côte d'Ivoire / Abidjan.
/// TODO (IMPORTANT): Remplacer cette source locale par une source Firestore partagée (EmergencyFirestoreDataSource).
///   - Lire collections partagées: 'emergency_numbers', 'emergency_hospitals', 'emergency_pharmacies'
///   - Fournir une implémentation qui respecte la mise en cache et le fallback offline
///   Voir: lib/features/emergency/data/datasources/ (à créer)
class EmergencyLocalDataSource {
  const EmergencyLocalDataSource();

  Future<List<EmergencyNumberEntity>> loadEmergencyNumbers(
    String countryCode,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 80));
    return _emergencyNumbers.where((e) => e.country == countryCode).toList();
  }

  Future<List<EmergencyHospitalEntity>> loadNearbyHospitals({
    required double lat,
    required double lng,
    required String countryCode,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 80));
    return _hospitals.where((h) => h.country == countryCode).toList();
  }

  Future<List<EmergencyPharmacyEntity>> loadNearbyPharmacies({
    required double lat,
    required double lng,
    required String countryCode,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 80));
    return _pharmacies.where((p) => p.country == countryCode).toList();
  }

  Future<UserLocationEntity> loadUserLocation({
    required String country,
    required String city,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 50));

    // Récupérer la première pharmacie du pays comme repère
    final pharmacy = _pharmacies.firstWhere(
      (p) => p.country == country,
      orElse: () => _pharmacies.first,
    );

    // Générer le quartier basé sur la ville du profil
    final neighborhood = '$city, Centre';

    return UserLocationEntity(
      neighborhood: neighborhood,
      landmark: 'Près de ${pharmacy.name}',
      lat: pharmacy.lat,
      lng: pharmacy.lng,
      accuracyM: 50, // Précision approximative pour la ville
    );
  }

  static const List<EmergencyNumberEntity> _emergencyNumbers = [
    EmergencyNumberEntity(
      id: '1',
      name: 'SAMU Médical',
      number: '185',
      country: 'CI',
      category: EmergencyCategory.medical,
      description: 'Coma, arrêt cardiaque, détresse respiratoire grave',
      isFree: true,
      worksOffline: true,
    ),
    EmergencyNumberEntity(
      id: '2',
      name: 'Sapeurs-Pompiers (GSPM)',
      number: '180',
      country: 'CI',
      category: EmergencyCategory.fire,
      description: 'Accidents de la route, incendies, noyades, blessés',
      isFree: true,
      worksOffline: true,
    ),
    EmergencyNumberEntity(
      id: '3',
      name: 'Police Secours',
      number: '170',
      secondaryNumber: '111',
      country: 'CI',
      category: EmergencyCategory.police,
      description: 'Agressions, vols, sécurité',
      isFree: true,
      worksOffline: true,
    ),
    // --- Togo (TG) ---
    EmergencyNumberEntity(
      id: 'tg1',
      name: 'SAMU Médical (Togo)',
      number: '161',
      country: 'TG',
      category: EmergencyCategory.medical,
      description: 'Urgences médicales, accidents graves',
      isFree: true,
      worksOffline: true,
    ),
    EmergencyNumberEntity(
      id: 'tg2',
      name: 'Sapeurs-Pompiers (Togo)',
      number: '118',
      country: 'TG',
      category: EmergencyCategory.fire,
      description: 'Incendies, accidents',
      isFree: true,
      worksOffline: true,
    ),
    EmergencyNumberEntity(
      id: 'tg3',
      name: 'Police Nationale (Togo)',
      number: '117',
      country: 'TG',
      category: EmergencyCategory.police,
      description: 'Sécurité, agressions',
      isFree: true,
      worksOffline: true,
    ),
    // --- Burkina Faso (BF) ---
    EmergencyNumberEntity(
      id: 'bf1',
      name: 'SAMU Médical (Burkina)',
      number: '112', // Numéro d'urgence standard
      country: 'BF',
      category: EmergencyCategory.medical,
      description: 'Urgences médicales graves',
      isFree: true,
      worksOffline: true,
    ),
    EmergencyNumberEntity(
      id: 'bf2',
      name: 'Sapeurs-Pompiers (Burkina)',
      number: '18',
      country: 'BF',
      category: EmergencyCategory.fire,
      description: 'Incendies, secours',
      isFree: true,
      worksOffline: true,
    ),
    EmergencyNumberEntity(
      id: 'bf3',
      name: 'Police Nationale (Burkina)',
      number: '17',
      country: 'BF',
      category: EmergencyCategory.police,
      description: 'Police secours, sécurité',
      isFree: true,
      worksOffline: true,
    ),
  ];

  static const List<EmergencyHospitalEntity> _hospitals = [
    // --- Côte d'Ivoire (CI) ---
    EmergencyHospitalEntity(
      id: 'h-ci-1',
      name: 'CHU de Cocody',
      phone: '+225 27 22 48 00',
      country: 'CI',
      lat: 5.3657,
      lng: -3.9696,
      distanceKm: 1.8,
      isOpen24h: true,
      services: ['Service Urgences Adultes', 'Pédiatrie & Grands Brûlés'],
    ),
    EmergencyHospitalEntity(
      id: 'h-ci-2',
      name: 'Urgences Médico-Chirurgicales PISAM',
      phone: '+225 27 22 40 06',
      country: 'CI',
      lat: 5.3500,
      lng: -4.0083,
      distanceKm: 2.4,
      isOpen24h: true,
      services: ['Plateau technique complet, scanner & soins intensifs'],
    ),
    // --- Burkina Faso (BF) ---
    EmergencyHospitalEntity(
      id: 'h-bf-1',
      name: 'CHU Yalgado Ouédraogo',
      phone: '+226 25 30 66 44',
      country: 'BF',
      lat: 12.3714,
      lng: -1.5197,
      distanceKm: 0.0,
      isOpen24h: true,
      services: ['Urgences médicales & chirurgicales', 'Réanimation'],
    ),
    EmergencyHospitalEntity(
      id: 'h-bf-2',
      name: 'CHUSS - CHU Sourô Sanou',
      phone: '+226 20 97 00 00',
      country: 'BF',
      lat: 11.1770,
      lng: -4.2980,
      distanceKm: 0.0,
      isOpen24h: true,
      services: ['Urgences & soins intensifs', 'Bloc opératoire 24h/24'],
    ),
    // --- Togo (TG) ---
    EmergencyHospitalEntity(
      id: 'h-tg-1',
      name: 'CHU Sylvanus Olympio',
      phone: '+228 22 21 25 01',
      country: 'TG',
      lat: 6.1284,
      lng: 1.2257,
      distanceKm: 0.0,
      isOpen24h: true,
      services: ['Urgences médicales & chirurgicales', 'Réanimation adultes'],
    ),
    EmergencyHospitalEntity(
      id: 'h-tg-2',
      name: 'CHU Campus',
      phone: '+228 22 21 60 87',
      country: 'TG',
      lat: 6.1375,
      lng: 1.2123,
      distanceKm: 0.0,
      isOpen24h: true,
      services: ['Urgences pédiatriques & maternité', 'Plateau technique complet'],
    ),
  ];

  static const List<EmergencyPharmacyEntity> _pharmacies = [
    // --- Côte d'Ivoire (CI) ---
    EmergencyPharmacyEntity(
      id: 'p-ci-1',
      name: 'Pharmacie Sainte Cécile des vallons',
      address: 'Cocody Deux-Plateaux, face ENA',
      phone: '+225 27 22 41 55',
      country: 'CI',
      lat: 5.3590,
      lng: -3.9810,
      distanceM: 650,
      closeTime: "Ouvert jusqu'à 08h00 demain",
      isOnDuty: true,
    ),
    EmergencyPharmacyEntity(
      id: 'p-ci-2',
      name: 'Pharmacie Santé de vie',
      address: 'Abidjan, Cocody',
      phone: '+225 27 22 45 00',
      country: 'CI',
      lat: 5.3600,
      lng: -3.9750,
      distanceM: 900,
      closeTime: 'Service de garde actif',
      isOnDuty: true,
    ),
    // --- Burkina Faso (BF) ---
    EmergencyPharmacyEntity(
      id: 'p-bf-1',
      name: 'Pharmacie Benaia',
      address: 'Ouagadougou, Secteur 15',
      phone: '+226 25 36 00 00',
      country: 'BF',
      lat: 12.3714,
      lng: -1.5197,
      distanceM: 500,
      closeTime: 'Service de garde actif',
      isOnDuty: true,
    ),
    EmergencyPharmacyEntity(
      id: 'p-bf-2',
      name: 'Pharmacie Somgandé',
      address: 'Ouagadougou, Somgandé',
      phone: '+226 25 37 00 00',
      country: 'BF',
      lat: 12.3800,
      lng: -1.5100,
      distanceM: 1200,
      closeTime: "Ouvert jusqu'à 07h00 demain",
      isOnDuty: true,
    ),
    // --- Togo (TG) ---
    EmergencyPharmacyEntity(
      id: 'p-tg-1',
      name: 'PHARMACIE DES ETOILES',
      address: 'Lomé, Carrefour Duncan',
      phone: '+228 22 21 60 00',
      country: 'TG',
      lat: 6.1375,
      lng: 1.2123,
      distanceM: 350,
      closeTime: 'Service de garde actif',
      isOnDuty: true,
    ),
    EmergencyPharmacyEntity(
      id: 'p-tg-2',
      name: 'Pharmacie Djidjolé',
      address: 'Lomé, Djidjolé',
      phone: '+228 22 26 00 00',
      country: 'TG',
      lat: 6.1450,
      lng: 1.2200,
      distanceM: 800,
      closeTime: "Ouvert jusqu'à 08h00 demain",
      isOnDuty: true,
    ),
  ];
}
