import '../entities/health_center_entity.dart';
import '../repositories/health_center_repository.dart';

class SearchHealthCenters {
  const SearchHealthCenters(this.repository);

  final HealthCenterRepository repository;

  Future<List<HealthCenterEntity>> call({
    String? country,
    String? city,
    String? type,
  }) {
    return repository.searchHealthCenters(
      country: country,
      city: city,
      type: type,
    );
  }
}
