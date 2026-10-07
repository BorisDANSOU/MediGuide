import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/supported_locations.dart';
import '../../../../core/services/launch_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../health_centers/data/datasources/health_center_remote_ds.dart';
import '../../../health_centers/presentation/pages/map_page.dart';
import 'package:mediguid/features/user_profile/domain/entities/user_profile_entity.dart';
import '../../../user_profile/presentation/controllers/user_profile_controller.dart';
import '../../data/datasources/emergency_local_ds.dart';
import '../../data/repositories/emergency_repo_impl.dart';
import '../../domain/entities/emergency_hospital_entity.dart';
import '../../domain/entities/emergency_facilities_snapshot.dart';
import '../../domain/entities/emergency_number_entity.dart';
import '../../domain/entities/emergency_pharmacy_entity.dart';
import '../../domain/repositories/emergency_repository.dart';
import '../controllers/emergency_provider.dart';

class EmergencyModalPage extends ConsumerStatefulWidget {
  const EmergencyModalPage({super.key, this.repository, this.launchUri});

  final EmergencyRepository? repository;
  final Future<bool> Function(Uri uri)? launchUri;

  @override
  ConsumerState<EmergencyModalPage> createState() => _EmergencyModalPageState();
}

class _EmergencyModalPageState extends ConsumerState<EmergencyModalPage> {
  late final EmergencyProvider _provider;
  final LaunchService _launchService = const LaunchService();
  String? _lastLoadedLocation;

  Future<void> _callPhone(String number) async {
    final launchUri = widget.launchUri;
    if (launchUri == null) {
      await _launchService.callPhone(number);
      return;
    }

    final cleaned = number.replaceAll(RegExp(r'[^\d+\-\s]'), '').trim();
    await launchUri(Uri(scheme: 'tel', path: cleaned));
  }

  @override
  void initState() {
    super.initState();
    final repository =
        widget.repository ??
        EmergencyRepositoryImpl(
          const EmergencyLocalDataSource(),
          remoteDataSource: HealthCenterRemoteDataSource(),
        );
    _provider = EmergencyProvider(repository);
  }

  @override
  void dispose() {
    _provider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(userProfileControllerProvider);

    // Quand le profil est disponible, charge les données d'urgence
    profileAsync.whenData((profile) {
      final isoCode = SupportedLocations.isoCodeForCountry(profile.country);
      final locationKey = '$isoCode:${profile.city}';
      if (_lastLoadedLocation != locationKey) {
        _lastLoadedLocation = locationKey;
        _provider.loadEmergencyData(isoCode, profile.city);
      }
    });

    final profile = profileAsync.value ?? UserProfileEntity.initial;
    final countryCode = SupportedLocations.isoCodeForCountry(profile.country);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _provider,
          builder: (context, _) => SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(context, profile),
                const SizedBox(height: 14),
                _buildVitalNumbers(profile),
                const SizedBox(height: 8),
                _buildLocationMarker(),
                if (_provider.facilitiesSource ==
                    EmergencyFacilitiesSource.localFallback) ...[
                  const SizedBox(height: 12),
                  _buildNotice(
                    'Données locales hors ligne : les établissements peuvent '
                    'ne pas refléter les informations actuelles.',
                  ),
                ],
                const SizedBox(height: 20),
                
                // --- Section : Numéros Nationaux ---
                _buildSectionHeading('Services nationaux prioritaires'),
                const SizedBox(height: 10),
                if (_provider.isLoading)
                  const LinearProgressIndicator(minHeight: 3)
                else if (_provider.errorMessage != null)
                  _buildNotice(_provider.errorMessage!)
                else if (_provider.numbers.isEmpty)
                  _buildNotice('Aucun numéro disponible pour ce pays.')
                else
                  ..._provider.numbers.map(_buildEmergencyService),
                
                const SizedBox(height: 22),
                
                // --- Section : Urgences Hospitalières ---
                _buildSectionHeading('Urgences Hospitalières'),
                const SizedBox(height: 3),
                const Text(
                  'Établissements hospitaliers à proximité',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 9),
                if (_provider.facilitiesError != null)
                  _buildFacilitiesError(countryCode, profile.city)
                else
                if (_provider.isLoading)
                  const LinearProgressIndicator(minHeight: 3)
                else if (_provider.hospitals.isEmpty)
                  _buildNotice('Aucun hôpital trouvé à proximité.')
                else
                  ..._provider.hospitals.map(_buildFacilityCard),

                const SizedBox(height: 22),
                
                // --- Section : Pharmacies de Garde ---
                _buildSectionHeading('Pharmacies de Garde Immédiates'),
                const SizedBox(height: 3),
                const Text(
                  'Pharmacies signalées de garde',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 9),
                if (_provider.facilitiesError != null)
                  _buildFacilitiesError(countryCode, profile.city)
                else
                if (_provider.isLoading)
                  const LinearProgressIndicator(minHeight: 3)
                else if (_provider.pharmacies.isEmpty)
                  _buildNotice('Aucune pharmacie de garde trouvée.')
                else
                  ..._provider.pharmacies.map(_buildPharmacyCard),

                const SizedBox(height: 20),
                _buildAdviceCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, UserProfileEntity profile) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.brand,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.health_and_safety, color: Colors.white),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text.rich(
                TextSpan(
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  children: const [
                    TextSpan(text: 'MediGuide'),
                    TextSpan(
                      text: ' · Urgences',
                      style: TextStyle(color: AppColors.emergency),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    color: AppColors.brand,
                    size: 14,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    '${profile.city}, ${profile.country}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Profil',
          onPressed: () {
            context.go(AppRoutes.profile);
          },
          style: IconButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          icon: const Icon(Icons.person_outline),
        ),
      ],
    );
  }

  Widget _buildVitalNumbers(UserProfileEntity profile) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.emergency,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.12),
          offset: const Offset(0, 3),
          blurRadius: 6,
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.emergency_outlined, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Numéros d’Urgence Vitale',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Text(
          '${profile.country} • ${profile.city}',
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
        const SizedBox(height: 8),
        const Text(
          'Appelez immédiatement en cas d\'urgence critique. Les secours sont alertés automatiquement.',
          style: TextStyle(color: Colors.white, fontSize: 13),
        ),
      ],
    ),
  );

  Widget _buildLocationMarker() {
    final location = _provider.userLocation;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.infoSoft,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.my_location, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'VOTRE REPÈRE POUR LES SECOURS',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  location?.neighborhood ?? 'Recherche en cours...',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  location?.landmark ?? 'Veuillez patienter',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          if (location != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                'Précision ${location.accuracyM}m',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionHeading(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 1),
    child: Text(
      title,
      style: Theme.of(context).textTheme.titleMedium
          ?.copyWith(fontWeight: FontWeight.w700),
    ),
  );

  Widget _buildEmergencyService(EmergencyNumberEntity number) {
    final label = 'Appeler ${number.name}';
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 19,
                  backgroundColor: AppColors.emergencySoft,
                  child: Icon(
                    Icons.medical_services_outlined,
                    color: AppColors.emergencyDark,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        number.name,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        number.description,
                        style: Theme.of(context).textTheme.bodySmall
                            ?.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.emergencyDark,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    number.number,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            FilledButton.icon(
              onPressed: () => _callPhone(number.number),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.emergency,
                minimumSize: const Size.fromHeight(48),
              ),
              icon: const Icon(Icons.phone_outlined),
              label: Text(label),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFacilityCard(EmergencyHospitalEntity hospital) => Card(
    margin: const EdgeInsets.only(bottom: 8),
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CircleAvatar(
                backgroundColor: AppColors.infoSoft,
                child: Icon(
                  Icons.local_hospital_outlined,
                  color: AppColors.info,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hospital.name,
                      style: Theme.of(context).textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    if (hospital.services.isNotEmpty)
                      Text(
                        hospital.services.join(', '),
                        style: Theme.of(context).textTheme.bodyMedium
                            ?.copyWith(color: AppColors.textSecondary),
                      ),
                    if (hospital.isOpen24h)
                      const Text(
                        'Ouvert 24h/24',
                        style: TextStyle(color: AppColors.brand),
                      ),
                    const SizedBox(height: 4),
                    Text(
                      'À ${hospital.distanceKm.toStringAsFixed(1)} km',
                      style: const TextStyle(
                        color: AppColors.brand,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              if (hospital.phone != null) ...[
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _callPhone(hospital.phone!),
                    icon: const Icon(Icons.phone_outlined, size: 18),
                    label: const Text('Appeler'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(44),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: FilledButton.tonalIcon(
                  onPressed: () {
                    // Fermer la modale avant de naviguer
                    Navigator.of(context).pop();
                    context.go(
                      AppRoutes.map,
                      extra: MapDestination(
                        lat: hospital.lat,
                        lng: hospital.lng,
                        label: hospital.name,
                      ),
                    );
                  },
                  icon: const Icon(Icons.navigation_outlined, size: 18),
                  label: const Text('Itinéraire'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(44),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );

  Widget _buildPharmacyCard(EmergencyPharmacyEntity pharmacy) => Card(
    margin: const EdgeInsets.only(bottom: 8),
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  pharmacy.name,
                  style: Theme.of(context).textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              if (pharmacy.isOnDuty)
                const Icon(Icons.check_circle, color: Colors.green, size: 18),
            ],
          ),
          if (pharmacy.address != null)
            Text(
              pharmacy.address!,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          if (pharmacy.closeTime != null) ...[
            const SizedBox(height: 3),
            Text(
              pharmacy.closeTime!,
              style: const TextStyle(
                color: Colors.green,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'À ${pharmacy.distanceM} m',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          if (pharmacy.phone != null)
            Row(
              children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => _callPhone(pharmacy.phone!),
                  icon: const Icon(Icons.phone_outlined, size: 18),
                  label: const Text('Appeler'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: const Size.fromHeight(44),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                tooltip: 'Itinéraire',
                onPressed: () {
                  // Fermer la modale avant de naviguer
                  Navigator.of(context).pop();
                  context.go(
                    AppRoutes.map,
                    extra: MapDestination(
                      lat: pharmacy.lat,
                      lng: pharmacy.lng,
                      label: pharmacy.name,
                    ),
                  );
                },
                icon: const Icon(Icons.directions_outlined),
              ),
              ],
            ),
        ],
      ),
    ),
  );

  Widget _buildAdviceCard() => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.surfaceLow,
      borderRadius: BorderRadius.circular(16),
    ),
    child: const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.hearing_outlined, color: AppColors.primary),
        SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Conseil d’appel d’urgence',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 4),
              Text(
                'Parlez calmement, indiquez d’abord votre quartier et un repère visuel, puis décrivez l’état de la victime.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _buildNotice(String message) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: AppColors.surfaceLow,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(
      message,
      style: const TextStyle(color: AppColors.textSecondary),
    ),
  );

  Widget _buildFacilitiesError(String countryCode, String city) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      _buildNotice(_provider.facilitiesError!),
      TextButton.icon(
        onPressed: () => _provider.loadEmergencyData(countryCode, city),
        icon: const Icon(Icons.refresh),
        label: const Text('Réessayer'),
      ),
    ],
  );
}
