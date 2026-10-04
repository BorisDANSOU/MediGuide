import '../entities/home_overview.dart';

abstract class HomeRepository {
  Future<HomeOverview> getOverview({
    required String country,
    required String city,
  });
}
