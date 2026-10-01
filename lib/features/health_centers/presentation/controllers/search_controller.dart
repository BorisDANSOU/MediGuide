import 'package:flutter/foundation.dart';

import '../../domain/entities/center_filter.dart';
import '../../domain/entities/nearby_center.dart';
import '../../domain/repositories/health_center_catalog.dart';
import '../../domain/usecases/filter_health_centers.dart';

enum SearchStatus { loading, ready, error }

/// État de l'écran de recherche : texte saisi, puce active et résultats.
class CenterSearchController extends ChangeNotifier {
  CenterSearchController({
    required this.catalog,
    CenterFilter initialFilter = CenterFilter.all,
    this.filterCenters = const FilterHealthCenters(),
  }) : _filter = initialFilter;

  final HealthCenterCatalog catalog;
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
      _all = await catalog.centersAround(country: country, city: city);
      _status = SearchStatus.ready;
    } catch (_) {
      _status = SearchStatus.error;
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
