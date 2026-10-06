import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'launch_service.dart';

/// Provider global du [LaunchService].
///
/// Utilisation dans un widget :
/// ```dart
/// final launcher = ref.read(launchServiceProvider);
/// await launcher.callPhone('185');
/// await launcher.openDirections(lat: 5.3600, lng: -4.0083, label: 'CHU de Cocody');
/// ```
///
/// La dépendance est exposée comme [Provider] (singleton) car [LaunchService]
/// est stateless — il ne détient aucun état et ne nécessite pas de rebuild.
final launchServiceProvider = Provider<LaunchService>(
  (_) => const LaunchService(),
);
