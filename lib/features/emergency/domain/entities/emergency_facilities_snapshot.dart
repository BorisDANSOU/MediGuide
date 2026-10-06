import 'emergency_hospital_entity.dart';
import 'emergency_pharmacy_entity.dart';

enum EmergencyFacilitiesSource { firestore, localFallback }

class EmergencyFacilitiesSnapshot {
  const EmergencyFacilitiesSnapshot({
    required this.hospitals,
    required this.pharmacies,
    required this.source,
  });

  final List<EmergencyHospitalEntity> hospitals;
  final List<EmergencyPharmacyEntity> pharmacies;
  final EmergencyFacilitiesSource source;
}
