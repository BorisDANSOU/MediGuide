import '../entities/home_overview.dart';
import '../repositories/home_repository.dart';

class GetHomeOverview {
  const GetHomeOverview(this.repository);

  final HomeRepository repository;

  Future<HomeOverview> call({required String country, required String city}) {
    return repository.getOverview(country: country, city: city);
  }
}
