import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/demo_health_center_repository.dart';
import '../../domain/entities/health_center_entity.dart';
import '../../domain/repositories/health_center_repository.dart';

/// Le repository utilisé par la carte.
final healthCenterRepositoryProvider = Provider<HealthCenterRepository>((ref) {
  return const DemoHealthCenterRepository();
});

final healthCentersByCountryProvider =
    FutureProvider.family<List<HealthCenterEntity>, String>((ref, country) {
      return ref
          .watch(healthCenterRepositoryProvider)
          .searchHealthCenters(country: country);
    });
