import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/usecases/get_centers_around.dart';
import 'health_centers_providers.dart';

/// Centres d'une ville avec leur distance (accueil, recherche).
/// S'appuie sur le même repository que la carte.
final getCentersAroundProvider = Provider<GetCentersAround>((ref) {
  return GetCentersAround(ref.watch(healthCenterRepositoryProvider));
});
