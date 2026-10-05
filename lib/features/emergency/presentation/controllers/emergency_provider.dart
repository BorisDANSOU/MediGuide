import 'package:flutter/foundation.dart';

import '../../domain/entities/emergency_hospital_entity.dart';
import '../../domain/entities/emergency_number_entity.dart';
import '../../domain/entities/emergency_pharmacy_entity.dart';
import '../../domain/entities/user_location_entity.dart';
import '../../domain/repositories/emergency_repository.dart';

class EmergencyProvider extends ChangeNotifier {
  EmergencyProvider(this._repository);

  final EmergencyRepository _repository;

  // --- Données exposées à l'UI ---

  List<EmergencyNumberEntity> _numbers = const [];
  List<EmergencyNumberEntity> get numbers => _numbers;

  List<EmergencyHospitalEntity> _hospitals = const [];
  List<EmergencyHospitalEntity> get hospitals => _hospitals;

  List<EmergencyPharmacyEntity> _pharmacies = const [];
  List<EmergencyPharmacyEntity> get pharmacies => _pharmacies;

  UserLocationEntity? _userLocation;
  UserLocationEntity? get userLocation => _userLocation;

  // --- États de chargement et erreurs ---

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // --- Méthodes ---

  /// Charge toutes les données nécessaires pour la page Urgences :
  /// 1. La position GPS de l'utilisateur
  /// 2. Les numéros nationaux du pays
  /// 3. Les hôpitaux à proximité
  /// 4. Les pharmacies de garde à proximité
  Future<void> loadEmergencyData(String countryCode, String city) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Récupérer la position de l'utilisateur d'abord (pour filtrer le reste)
      _userLocation = await _repository.getUserLocation(
        country: countryCode,
        city: city,
      );

      // Pour l'instant, on mappe 'Côte d’Ivoire' ou on utilise 'CI' par défaut
      final code =
          (countryCode.toLowerCase().contains('ivoire') || countryCode == 'CI')
              ? 'CI'
              : countryCode;

      // 2. Charger les 3 listes en parallèle pour plus de performance
      final results = await Future.wait([
        _repository.getEmergencyNumbers(code),
        _repository.getNearbyHospitals(
          lat: _userLocation!.lat,
          lng: _userLocation!.lng,
          countryCode: code,
        ),
        _repository.getNearbyPharmacies(
          lat: _userLocation!.lat,
          lng: _userLocation!.lng,
          countryCode: code,
        ),
      ]);

      _numbers = results[0] as List<EmergencyNumberEntity>;
      _hospitals = results[1] as List<EmergencyHospitalEntity>;
      _pharmacies = results[2] as List<EmergencyPharmacyEntity>;

    } catch (e) {
      _errorMessage = 'Erreur lors du chargement des données : $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Maintien de l'ancienne signature au cas où elle est encore appelée dans init
  Future<void> loadForCountry(String countryCode) async {
    return loadEmergencyData(countryCode, 'Centre');
  }
}
