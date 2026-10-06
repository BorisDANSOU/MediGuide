import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/supported_locations.dart';
import '../../data/datasources/health_center_remote_ds.dart';
import '../../data/repositories/health_center_repo_impl.dart';
import '../../domain/entities/health_center_entity.dart';
import '../../domain/repositories/health_center_repository.dart';

/// Le repository utilisé par la carte.
final healthCenterRepositoryProvider = Provider<HealthCenterRepository>((ref) {
  return HealthCenterRepositoryImpl(
    remoteDataSource: HealthCenterRemoteDataSource(),
  );
});

final healthCentersByCountryProvider =
    FutureProvider.family<List<HealthCenterEntity>, String>((ref, country) {
      return ref
          .watch(healthCenterRepositoryProvider)
          .searchHealthCenters(
            country: country,
            city: SupportedLocations.forCountry(country).city,
          );
    });
