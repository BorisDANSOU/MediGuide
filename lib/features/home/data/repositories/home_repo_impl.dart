import '../../../health_centers/data/repositories/health_center_catalog_impl.dart';
import '../../../health_centers/domain/repositories/health_center_catalog.dart';
import '../../domain/entities/home_overview.dart';
import '../../domain/repositories/home_repository.dart';

class HomeRepositoryImpl implements HomeRepository {
  const HomeRepositoryImpl({this.catalog = const HealthCenterCatalogImpl()});

  final HealthCenterCatalog catalog;

  @override
  Future<HomeOverview> getOverview({
    required String country,
    required String city,
  }) async {
    final centers = await catalog.centersAround(country: country, city: city);

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
