import '../entities/emergency_hospital_entity.dart';
import '../entities/emergency_number_entity.dart';
import '../entities/emergency_pharmacy_entity.dart';
import '../entities/user_location_entity.dart';

/// Contrat abstrait du repository d'urgences.
abstract class EmergencyRepository {
  /// Retourne les numéros nationaux d'urgence pour le pays [countryCode]
  Future<List<EmergencyNumberEntity>> getEmergencyNumbers(String countryCode);

  /// Retourne les hôpitaux avec urgences à proximité.
  Future<List<EmergencyHospitalEntity>> getNearbyHospitals({
    required double lat,
    required double lng,
    required String countryCode,
  });

  /// Retourne les pharmacies de garde à proximité.
  Future<List<EmergencyPharmacyEntity>> getNearbyPharmacies({
    required double lat,
    required double lng,
    required String countryCode,
  });

  /// Retourne la localisation actuelle de l'utilisateur avec son repère visuel.
  Future<UserLocationEntity> getUserLocation({
    required String country,
    required String city,
  });
}
