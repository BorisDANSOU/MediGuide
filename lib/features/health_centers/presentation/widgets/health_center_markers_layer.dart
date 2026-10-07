import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart';

import '../../domain/entities/health_center_entity.dart';
import 'health_center_marker_style.dart';

/// Couche de marqueurs à poser dans les "children" d'un FlutterMap.
class HealthCenterMarkersLayer extends StatelessWidget {
  const HealthCenterMarkersLayer({
    super.key,
    required this.centers,
    required this.onTap,
  });

  final List<HealthCenterEntity> centers;

  /// Appelée quand l'utilisateur touche un marqueur
  final ValueChanged<HealthCenterEntity> onTap;

  @override
  Widget build(BuildContext context) {
    final centersByMarker = <Marker, HealthCenterEntity>{};
    final markers = <Marker>[];
    for (final center in centers) {
      final marker = Marker(
        point: LatLng(center.latitude, center.longitude),
        width: 40,
        height: 40,
        child: _Pin(style: HealthCenterMarkerStyle.forType(center.type)),
      );
      centersByMarker[marker] = center;
      markers.add(marker);
    }

    return MarkerClusterLayerWidget(
      options: MarkerClusterLayerOptions(
        markers: markers,
        maxClusterRadius: 70,
        disableClusteringAtZoom: 17,
        onMarkerTap: (marker) {
          final center = centersByMarker[marker];
          if (center == null) {
            throw StateError('Tapped marker is not associated with a center.');
          }
          onTap(center);
        },
        builder: (context, clusteredMarkers) => Semantics(
          label: '${clusteredMarkers.length} centres de santé',
          child: Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              '${clusteredMarkers.length}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Le rond coloré avec son icône blanche et sa bordure blanche
class _Pin extends StatelessWidget {
  const _Pin({required this.style});

  final HealthCenterMarkerStyle style;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: style.color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Icon(style.icon, color: Colors.white, size: 20),
    );
  }
}
