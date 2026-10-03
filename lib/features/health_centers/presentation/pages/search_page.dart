import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/utils/external_actions.dart';
import '../../../../core/widgets/responsive_cards.dart';
import '../../../../core/widgets/state_message.dart';
import '../../../user_profile/domain/entities/user_profile_entity.dart';
import '../../../user_profile/presentation/controllers/user_profile_controller.dart';
import '../../domain/entities/center_filter.dart';
import '../../domain/entities/nearby_center.dart';
import '../controllers/centers_around_provider.dart';
import '../controllers/search_controller.dart';
import '../widgets/hospital_card.dart';

/// Écran 05 : recherche et liste des résultats (KABORE).
/// Cherche dans la ville du profil (DANSOU).
class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key, this.initialFilter = CenterFilter.all});

  final CenterFilter initialFilter;

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  late final CenterSearchController _controller;
  final _field = TextEditingController();

  UserProfileEntity get _profile =>
      ref.read(userProfileControllerProvider).value ??
      UserProfileEntity.initial;

  @override
  void initState() {
    super.initState();
    _controller = CenterSearchController(
      getCentersAround: ref.read(getCentersAroundProvider),
      initialFilter: widget.initialFilter,
    );
    _load();
  }

  @override
  void dispose() {
    _controller.dispose();
    _field.dispose();
    super.dispose();
  }

  Future<void> _load() =>
      _controller.load(country: _profile.country, city: _profile.city);

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
                              'Aucun centre trouvé à ${_profile.city}. '
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
                              '${_profile.city} · du plus proche au plus loin',
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
    return HospitalCard(
      item: item,
      onOpen: () => context.push(AppRoutes.center, extra: item),
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
