import 'health_center_entity.dart';

/// Filtres rapides (puces) de la recherche. Limités aux champs disponibles
/// dans `medical_centers` (SCHEMA.md) : pas encore de services ni de tarifs.
enum CenterFilter {
  all('Tous'),
  hospital('Hôpitaux'),
  clinic('Cliniques'),
  pharmacy('Pharmacies'),
  open24h('Ouvert 24h/24'),
  guard('De garde');

  const CenterFilter(this.label);

  final String label;

  bool accepts(HealthCenterEntity c) => switch (this) {
    CenterFilter.all => true,
    CenterFilter.hospital => c.type == 'hospital',
    CenterFilter.clinic => c.type == 'clinic',
    CenterFilter.pharmacy => c.type == 'pharmacy',
    CenterFilter.open24h => c.is24h,
    CenterFilter.guard => c.type == 'pharmacy' && c.isGuard,
  };
}
