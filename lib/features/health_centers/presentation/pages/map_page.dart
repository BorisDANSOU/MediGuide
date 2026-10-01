import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/constants/supported_locations.dart';
import '../../../user_profile/domain/entities/user_profile_entity.dart';
import '../../../user_profile/presentation/controllers/user_profile_controller.dart';

/// Carte OpenStreetMap, centrée sur la ville du pays choisi dans le Profil.
class MapPage extends ConsumerStatefulWidget {
  const MapPage({super.key});

  @override
  ConsumerState<MapPage> createState() => _MapPageState();
}

class _MapPageState extends ConsumerState<MapPage> {
  // Zoom d'une ville entière
  static const double _cityZoom = 12;

  // Permet de déplacer la carte par le code (recentrage)
  final MapController _mapController = MapController();

  // On ne peut déplacer la carte qu'une fois qu'elle est affichée
  bool _mapReady = false;

  /// Coordonnées du centre pour un pays (liste de core/constants)
  LatLng _centerFor(String country) {
    final location = SupportedLocations.forCountry(country);
    return LatLng(location.latitude, location.longitude);
  }

  /// Déplace la carte vers le pays donné
  void _recenter(String country) {
    if (!_mapReady) return;
    _mapController.move(_centerFor(country), _cityZoom);
  }

  @override
  void dispose() {
    _mapController.dispose(); // libère les ressources de la carte
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Profil actuel. Tant qu'il se charge : profil par défaut (Togo)
    final profile =
        ref.watch(userProfileControllerProvider).value ??
        UserProfileEntity.initial;

    // Quand le pays change dans le Profil, on recentre la carte
    ref.listen(userProfileControllerProvider, (previous, next) {
      final newCountry = next.value?.country;
      if (newCountry != null && newCountry != previous?.value?.country) {
        _recenter(newCountry);
      }
    });

    return Scaffold(
      appBar: AppBar(title: Text('Carte sanitaire • ${profile.city}')),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: _centerFor(profile.country),
          initialZoom: _cityZoom,
          minZoom: 3,
          maxZoom: 18,
          // Appelée quand la carte est prête
          onMapReady: () {
            _mapReady = true;
            _recenter(profile.country);
          },
        ),
        children: [
          // Fond de carte OpenStreetMap
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.mediguid',
          ),

          // Mention obligatoire de la licence OpenStreetMap
          const RichAttributionWidget(
            attributions: [TextSourceAttribution('OpenStreetMap contributors')],
          ),
        ],
      ),
    );
  }
}
