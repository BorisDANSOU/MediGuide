import 'package:flutter/foundation.dart';

import '../../domain/entities/home_overview.dart';
import '../../../health_centers/domain/failures/health_center_access_failure.dart';
import '../../domain/usecases/get_home_overview.dart';

enum HomeStatus { loading, ready, error, requiresAuthentication }

class HomeController extends ChangeNotifier {
  HomeController(this._getOverview);

  final GetHomeOverview _getOverview;

  HomeStatus _status = HomeStatus.loading;
  HomeOverview? _overview;

  HomeStatus get status => _status;
  HomeOverview? get overview => _overview;

  Future<void> load({required String country, required String city}) async {
    _status = HomeStatus.loading;
    notifyListeners();
    try {
      _overview = await _getOverview(country: country, city: city);
      _status = HomeStatus.ready;
    } catch (error) {
      _status = error is HealthCenterAccessFailure
          ? HomeStatus.requiresAuthentication
          : HomeStatus.error;
    }
    notifyListeners();
  }
}
