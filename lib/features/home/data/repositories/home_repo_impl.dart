import '../../../health_centers/domain/usecases/get_centers_around.dart';
import '../../domain/entities/home_overview.dart';
import '../../domain/repositories/home_repository.dart';

class HomeRepositoryImpl implements HomeRepository {
  const HomeRepositoryImpl(this.getCentersAround);

  final GetCentersAround getCentersAround;

  @override
  Future<HomeOverview> getOverview({
    required String country,
    required String city,
  }) async {
    final centers = await getCentersAround(country: country, city: city);

    return HomeOverview(
      country: country,
      city: city,
      guardPharmacies: centers
          .where((n) => n.center.type == 'pharmacy' && n.center.isGuard)
          .toList(),
      nearbyCenters: centers.where((n) => n.center.type != 'pharmacy').toList(),
    );
  }
}
