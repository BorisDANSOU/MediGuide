import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../domain/entities/emergency_facilities_snapshot.dart';
import '../../domain/entities/emergency_hospital_entity.dart';
import '../../domain/entities/emergency_number_entity.dart';
import '../../domain/entities/emergency_pharmacy_entity.dart';
import '../../domain/entities/user_location_entity.dart';
import '../../domain/repositories/emergency_repository.dart';

class EmergencyProvider extends ChangeNotifier {
  EmergencyProvider(this._repository);

  final EmergencyRepository _repository;
  StreamSubscription<EmergencyFacilitiesSnapshot>? _facilitiesSubscription;
  int _loadGeneration = 0;

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

  String? _facilitiesError;
  String? get facilitiesError => _facilitiesError;

  EmergencyFacilitiesSource? _facilitiesSource;
  EmergencyFacilitiesSource? get facilitiesSource => _facilitiesSource;

  // --- Méthodes ---

  /// Charge toutes les données nécessaires pour la page Urgences :
  /// 1. La position GPS de l'utilisateur
  /// 2. Les numéros nationaux du pays
  /// 3. Les hôpitaux et pharmacies de garde (flux Firestore avec secours local)
  Future<void> loadEmergencyData(String countryCode, String city) async {
    final generation = ++_loadGeneration;
    final oldSubscription = _facilitiesSubscription;
    _facilitiesSubscription = null;
    if (oldSubscription != null) await oldSubscription.cancel();
    if (generation != _loadGeneration) return;

    _isLoading = true;
    _errorMessage = null;
    _facilitiesError = null;
    _facilitiesSource = null;
    notifyListeners();

    try {
      final locationAndNumbers = await Future.wait<Object>([
        _repository.getUserLocation(country: countryCode, city: city),
        _repository.getEmergencyNumbers(_normalizeCountryCode(countryCode)),
      ]);
      if (generation != _loadGeneration) return;

      _userLocation = locationAndNumbers[0] as UserLocationEntity;
      _numbers = locationAndNumbers[1] as List<EmergencyNumberEntity>;

      _facilitiesSubscription = _repository
          .watchFacilities(
            countryCode: _normalizeCountryCode(countryCode),
            city: city,
            lat: _userLocation!.lat,
            lng: _userLocation!.lng,
          )
          .listen(
            (snapshot) {
              if (generation != _loadGeneration) return;
              _hospitals = snapshot.hospitals;
              _pharmacies = snapshot.pharmacies;
              _facilitiesSource = snapshot.source;
              _isLoading = false;
              _errorMessage = null;
              _facilitiesError = null;
              notifyListeners();
            },
            onError: (Object error, StackTrace stackTrace) {
              if (generation != _loadGeneration) return;
              debugPrint('Erreur du flux des établissements d’urgence : $error');
              debugPrintStack(stackTrace: stackTrace);
              _isLoading = false;
              _facilitiesError = 'Impossible de charger les établissements.';
              notifyListeners();
            },
            onDone: () {
              if (generation != _loadGeneration || !_isLoading) return;
              _isLoading = false;
              notifyListeners();
            },
          );
      notifyListeners();
    } catch (error, stackTrace) {
      if (generation != _loadGeneration) return;
      debugPrint('Erreur de chargement des données d’urgence : $error');
      debugPrintStack(stackTrace: stackTrace);
      _errorMessage = 'Impossible de charger les données d’urgence.';
      _isLoading = false;
      notifyListeners();
    }
  }

  String _normalizeCountryCode(String countryCode) =>
      countryCode.toLowerCase().contains('ivoire') || countryCode == 'CI'
      ? 'CI'
      : countryCode;

  // Maintien de l'ancienne signature au cas où elle est encore appelée dans init
  Future<void> loadForCountry(String countryCode) async {
    return loadEmergencyData(countryCode, 'Centre');
  }

  @override
  void dispose() {
    _loadGeneration++;
    final subscription = _facilitiesSubscription;
    if (subscription != null) unawaited(subscription.cancel());
    super.dispose();
  }
}
