import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/constants/supported_locations.dart';
import '../../../user_profile/domain/entities/user_profile_entity.dart';
import '../../../user_profile/presentation/controllers/user_profile_controller.dart';
import '../../domain/entities/health_center_entity.dart';
import '../controllers/health_centers_providers.dart';
import '../widgets/health_center_marker_style.dart';
import '../widgets/health_center_markers_layer.dart';
import '../widgets/map_legend.dart';

/// Carte OpenStreetMap : centrée sur la ville du pays choisi dans le Profil,
/// avec les centres de santé en marqueurs colorés par catégorie.
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

  /// Fiche rapide d'un centre, ouverte quand on touche son marqueur
  void _showCenterSheet(HealthCenterEntity center) {
    final style = HealthCenterMarkerStyle.forType(center.type);

    showModalBottomSheet<void>(
      context: context,
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(style.icon, color: style.color),
                  const SizedBox(width: 8),
                  Text(
                    style.label,
                    style: TextStyle(
                      color: style.color,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                center.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text('${center.city ?? ''}, ${center.country ?? ''}'),
              // Téléphone affiché seulement s'il existe
              if (center.phone != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.phone, size: 16),
                    const SizedBox(width: 6),
                    Text(center.phone!),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
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

    // Centres du pays actif : la carte se met à jour quand le pays change
    final centersAsync = ref.watch(
      healthCentersByCountryProvider(profile.country),
    );
    final centers = centersAsync.value ?? const <HealthCenterEntity>[];

    return Scaffold(
      appBar: AppBar(title: Text('Carte sanitaire • ${profile.city}')),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _centerFor(profile.country),
              initialZoom: _cityZoom,
              minZoom: 3,
              maxZoom: 18,
              // Appelée quand la carte est prête : on se recentre au cas où
              // le profil se serait chargé pendant l'affichage de la carte
              onMapReady: () {
                _mapReady = true;
                _recenter(profile.country);
              },
            ),
            children: [
              // Fond de carte OpenStreetMap
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                // Identifiant de l'app, demandé par OpenStreetMap
                userAgentPackageName: 'com.example.mediguid',
              ),

              // Marqueurs colorés des centres de santé
              HealthCenterMarkersLayer(
                centers: centers,
                onTap: _showCenterSheet,
              ),

              // Mention obligatoire de la licence OpenStreetMap
              const RichAttributionWidget(
                attributions: [
                  TextSourceAttribution('OpenStreetMap contributors'),
                ],
              ),
            ],
          ),

          // Barre de chargement pendant la récupération des centres
          if (centersAsync.isLoading)
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(),
            ),

          // Légende des couleurs
          const Positioned(left: 12, bottom: 12, child: MapLegend()),
        ],
      ),
    );
  }
}
