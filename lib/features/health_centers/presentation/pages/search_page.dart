import 'package:flutter/material.dart';

import '../../../../core/utils/external_actions.dart';
import '../../../../core/widgets/responsive_cards.dart';
import '../../../../core/widgets/state_message.dart';
import '../../data/repositories/health_center_catalog_impl.dart';
import '../../domain/entities/center_filter.dart';
import '../../domain/entities/nearby_center.dart';
import '../controllers/search_controller.dart';
import '../widgets/center_cards.dart';
import 'health_center_detail_page.dart';

/// Écran 05 : recherche et liste des résultats (KABORE).
class SearchPage extends StatefulWidget {
  const SearchPage({
    super.key,
    required this.country,
    required this.city,
    this.initialFilter = CenterFilter.all,
    this.controller,
  });

  final String country;
  final String city;
  final CenterFilter initialFilter;

  /// Injectable pour les tests.
  final CenterSearchController? controller;

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late final CenterSearchController _controller =
      widget.controller ??
      CenterSearchController(
        catalog: const HealthCenterCatalogImpl(),
        initialFilter: widget.initialFilter,
      );
  final _field = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    if (widget.controller == null) _controller.dispose();
    _field.dispose();
    super.dispose();
  }

  Future<void> _load() =>
      _controller.load(country: widget.country, city: widget.city);

  void _clearAll() {
    _field.clear();
    _controller.reset();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: TextField(
          controller: _field,
          autofocus: widget.initialFilter == CenterFilter.all,
          textInputAction: TextInputAction.search,
          onChanged: _controller.setQuery,
          style: TextStyle(color: scheme.onPrimary),
          cursorColor: scheme.onPrimary,
          decoration: InputDecoration(
            hintText: 'Nom, quartier, type…',
            hintStyle: TextStyle(
              color: scheme.onPrimary.withValues(alpha: 0.7),
            ),
            border: InputBorder.none,
          ),
        ),
        actions: [
          ListenableBuilder(
            listenable: _controller,
            builder: (context, _) => _controller.query.isEmpty
                ? const SizedBox.shrink()
                : IconButton(
                    tooltip: 'Effacer',
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      _field.clear();
                      _controller.setQuery('');
                    },
                  ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _controller,
          builder: (context, _) => Column(
            children: [
              _FilterChips(
                selected: _controller.filter,
                onSelected: _controller.setFilter,
              ),
              const Divider(height: 1),
              Expanded(child: _buildResults(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResults(BuildContext context) {
    switch (_controller.status) {
      case SearchStatus.loading:
        return const Center(child: CircularProgressIndicator());
      case SearchStatus.error:
        return StateMessage(
          icon: Icons.cloud_off,
          message: 'Impossible de charger les centres de santé.',
          actionLabel: 'Réessayer',
          onAction: _load,
        );
      case SearchStatus.ready:
        final results = _controller.results;
        return LayoutBuilder(
          builder: (context, constraints) {
            final padding = constraints.maxWidth >= 600 ? 24.0 : 16.0;
            return ListView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.all(padding),
              children: [
                MaxWidth(
                  child: results.isEmpty
                      ? StateMessage(
                          icon: Icons.search_off,
                          message:
                              'Aucun centre trouvé à ${widget.city}. '
                              'Essayez un autre mot ou retirez le filtre.',
                          actionLabel: 'Tout effacer',
                          onAction: _clearAll,
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              '${results.length} résultat'
                              '${results.length > 1 ? 's' : ''} à '
                              '${widget.city} · du plus proche au plus loin',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(height: 12),
                            ResponsiveCards(
                              children: [
                                for (final item in results) _card(item),
                              ],
                            ),
                          ],
                        ),
                ),
              ],
            );
          },
        );
    }
  }

  Widget _card(NearbyCenter item) {
    final c = item.center;
    return NearbyCenterCard(
      item: item,
      onOpen: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) =>
              HealthCenterDetailPage(center: c, distanceKm: item.distanceKm),
        ),
      ),
      onCall: () => callPhoneNumber(context, c.phone!),
      onDirections: () => openDirections(
        context,
        latitude: c.latitude,
        longitude: c.longitude,
        label: c.name,
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  const _FilterChips({required this.selected, required this.onSelected});

  final CenterFilter selected;
  final ValueChanged<CenterFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    // Hauteur libre (pas de SizedBox fixe) : les puces grandissent avec le
    // texte quand l'utilisateur l'agrandit.
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          for (final f in CenterFilter.values)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(f.label),
                selected: f == selected,
                onSelected: (_) => onSelected(f),
              ),
            ),
        ],
      ),
    );
  }
}
