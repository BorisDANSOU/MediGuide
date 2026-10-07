import 'package:flutter/foundation.dart';

import '../../domain/entities/center_filter.dart';
import '../../domain/entities/nearby_center.dart';
import '../../domain/failures/health_center_access_failure.dart';
import '../../domain/usecases/filter_health_centers.dart';
import '../../domain/usecases/get_centers_around.dart';

enum SearchStatus { loading, ready, error, requiresAuthentication }

/// État de l'écran de recherche : texte saisi, puce active et résultats.
class CenterSearchController extends ChangeNotifier {
  CenterSearchController({
    required this.getCentersAround,
    CenterFilter initialFilter = CenterFilter.all,
    this.filterCenters = const FilterHealthCenters(),
  }) : _filter = initialFilter;

  final GetCentersAround getCentersAround;
  final FilterHealthCenters filterCenters;

  SearchStatus _status = SearchStatus.loading;
  List<NearbyCenter> _all = const [];
  String _query = '';
  CenterFilter _filter;

  SearchStatus get status => _status;
  String get query => _query;
  CenterFilter get filter => _filter;

  List<NearbyCenter> get results =>
      filterCenters(_all, query: _query, filter: _filter);

  Future<void> load({required String country, required String city}) async {
    _status = SearchStatus.loading;
    notifyListeners();
    try {
      _all = await getCentersAround(country: country, city: city);
      _status = SearchStatus.ready;
    } catch (error) {
      _status = error is HealthCenterAccessFailure
          ? SearchStatus.requiresAuthentication
          : SearchStatus.error;
    }
    notifyListeners();
  }

  void setQuery(String value) {
    if (value == _query) return;
    _query = value;
    notifyListeners();
  }

  void setFilter(CenterFilter value) {
    if (value == _filter) return;
    _filter = value;
    notifyListeners();
  }

  void reset() {
    _query = '';
    _filter = CenterFilter.all;
    notifyListeners();
  }
}
