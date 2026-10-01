import '../../../../core/utils/text_normalizer.dart';
import '../entities/center_filter.dart';
import '../entities/nearby_center.dart';

const _typeWords = {
  'hospital': 'hopital hopitaux chu',
  'clinic': 'clinique cliniques cma',
  'pharmacy': 'pharmacie pharmacies',
};

/// Filtre une liste déjà triée par distance : chaque mot saisi doit
/// apparaître dans le nom, le quartier ou le type du centre.
class FilterHealthCenters {
  const FilterHealthCenters();

  List<NearbyCenter> call(
    List<NearbyCenter> centers, {
    String query = '',
    CenterFilter filter = CenterFilter.all,
  }) {
    final words = normalizeForSearch(query)
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();

    return centers.where((n) {
      final c = n.center;
      if (!filter.accepts(c)) return false;
      if (words.isEmpty) return true;
      final haystack = normalizeForSearch(
        '${c.name} ${c.address ?? ''} ${_typeWords[c.type] ?? ''}',
      );
      return words.every(haystack.contains);
    }).toList();
  }
}
