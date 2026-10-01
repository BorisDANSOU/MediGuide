import 'package:flutter/material.dart';

import '../../../../core/utils/external_actions.dart';
import '../../../../core/widgets/responsive_cards.dart';
import '../../../../core/widgets/state_message.dart';
import '../../../emergency/presentation/pages/emergency_modal_page.dart';
import '../../../health_centers/domain/entities/center_filter.dart';
import '../../../health_centers/domain/entities/nearby_center.dart';
import '../../../health_centers/presentation/pages/health_center_detail_page.dart';
import '../../../health_centers/presentation/pages/map_page.dart';
import '../../../health_centers/presentation/pages/search_page.dart';
import '../../../health_centers/presentation/widgets/center_cards.dart';
import '../../../maternity/presentation/pages/maternity_dashboard_page.dart';
import '../../../user_profile/domain/entities/user_profile_entity.dart';
import '../../../user_profile/presentation/pages/profile_page.dart';
import '../../data/repositories/home_repo_impl.dart';
import '../../domain/usecases/get_home_overview.dart';
import '../controllers/home_controller.dart';
import '../widgets/emergency_banner.dart';
import '../widgets/home_header.dart';
import '../widgets/home_search_bar.dart';
import '../widgets/quick_services_grid.dart';
import '../widgets/section_title.dart';

/// Écran 03 : accueil et dashboard principal (KABORE).
class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    this.profile = const UserProfileEntity(),
    this.userName,
    this.controller,
  });

  final UserProfileEntity profile;

  /// Prénom affiché dans la salutation ; `null` pour un visiteur sans compte.
  final String? userName;

  /// Injectable pour les tests ; sinon branché sur les données de démo.
  final HomeController? controller;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final HomeController _controller =
      widget.controller ??
      HomeController(const GetHomeOverview(HomeRepositoryImpl()));

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(HomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.profile.city != widget.profile.city) _load();
  }

  @override
  void dispose() {
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  Future<void> _load() => _controller.load(
    country: widget.profile.country,
    city: widget.profile.city,
  );

  void _open(Widget page) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));

  void _openSearch([CenterFilter filter = CenterFilter.all]) => _open(
    SearchPage(
      country: widget.profile.country,
      city: widget.profile.city,
      initialFilter: filter,
    ),
  );

  void _openDetail(NearbyCenter item) => _open(
    HealthCenterDetailPage(center: item.center, distanceKm: item.distanceKm),
  );

  void _call(NearbyCenter item) => callPhoneNumber(context, item.center.phone!);

  void _directions(NearbyCenter item) => openDirections(
    context,
    latitude: item.center.latitude,
    longitude: item.center.longitude,
    label: item.center.name,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final padding = constraints.maxWidth >= 600 ? 24.0 : 16.0;
            return RefreshIndicator(
              onRefresh: _load,
              child: ListenableBuilder(
                listenable: _controller,
                builder: (context, _) => ListView(
                  padding: EdgeInsets.symmetric(
                    horizontal: padding,
                    vertical: 12,
                  ),
                  children: [MaxWidth(child: _buildContent(context))],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final profile = widget.profile;
    final greeting = widget.userName == null
        ? 'Bonjour 👋'
        : 'Bonjour, ${widget.userName} 👋';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        HomeHeader(
          city: profile.city,
          country: profile.country,
          onProfileTap: () => _open(const ProfilePage()),
        ),
        const SizedBox(height: 20),
        Text(
          greeting,
          style: text.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        Text(
          'Trouvez le bon centre de santé, même hors connexion.',
          style: text.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        EmergencyBanner(onTap: () => _open(const EmergencyModalPage())),
        const SizedBox(height: 16),
        HomeSearchBar(onTap: _openSearch),
        const SizedBox(height: 24),
        SectionTitle(
          title: 'Services prioritaires',
          actionLabel: 'Tout voir',
          onAction: _openSearch,
        ),
        const SizedBox(height: 8),
        QuickServicesGrid(services: _services()),
        const SizedBox(height: 24),
        ..._buildDataSections(),
        const SizedBox(height: 24),
        _AdviceCard(onTap: () => _open(const EmergencyModalPage())),
        const SizedBox(height: 24),
      ],
    );
  }

  List<QuickService> _services() => [
    QuickService(
      icon: Icons.local_hospital_outlined,
      label: 'Hôpitaux',
      caption: 'CHU et publics',
      onTap: () => _openSearch(CenterFilter.hospital),
    ),
    QuickService(
      icon: Icons.local_pharmacy_outlined,
      label: 'Pharmacies',
      caption: 'De garde',
      onTap: () => _openSearch(CenterFilter.guard),
    ),
    QuickService(
      icon: Icons.medical_services_outlined,
      label: 'Cliniques',
      caption: 'Privées',
      onTap: () => _openSearch(CenterFilter.clinic),
    ),
    QuickService(
      icon: Icons.emergency_outlined,
      label: 'Urgences',
      caption: 'Ouvert 24h/24',
      isEmergency: true,
      onTap: () => _openSearch(CenterFilter.open24h),
    ),
    QuickService(
      icon: Icons.pregnant_woman,
      label: 'Maternité',
      caption: 'Mère et enfant',
      onTap: () => _open(const MaternityDashboardPage()),
    ),
    QuickService(
      icon: Icons.map_outlined,
      label: 'Carte',
      caption: 'Autour de moi',
      onTap: () => _open(const MapPage()),
    ),
  ];

  List<Widget> _buildDataSections() {
    switch (_controller.status) {
      case HomeStatus.loading:
        return const [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(child: CircularProgressIndicator()),
          ),
        ];
      case HomeStatus.error:
        return [
          StateMessage(
            icon: Icons.cloud_off,
            message: 'Impossible de charger les centres de santé.',
            actionLabel: 'Réessayer',
            onAction: _load,
          ),
        ];
      case HomeStatus.ready:
        final overview = _controller.overview!;
        return [
          SectionTitle(
            title: 'Pharmacies de garde (${overview.guardPharmacies.length})',
            actionLabel: 'Toutes',
            onAction: () => _openSearch(CenterFilter.guard),
          ),
          const SizedBox(height: 8),
          _cardsOrEmpty(
            overview.guardPharmacies,
            empty: 'Aucune pharmacie de garde connue à ${overview.city}.',
            builder: (item) => GuardPharmacyCard(
              item: item,
              onCall: () => _call(item),
              onDirections: () => _directions(item),
            ),
          ),
          const SizedBox(height: 24),
          SectionTitle(
            title: 'Centres de soins proches',
            actionLabel: 'Carte',
            onAction: () => _open(const MapPage()),
          ),
          const SizedBox(height: 8),
          _cardsOrEmpty(
            overview.nearbyCenters,
            empty: 'Aucun centre de santé connu à ${overview.city}.',
            builder: (item) => NearbyCenterCard(
              item: item,
              onOpen: () => _openDetail(item),
              onCall: () => _call(item),
              onDirections: () => _directions(item),
            ),
          ),
        ];
    }
  }

  Widget _cardsOrEmpty(
    List<NearbyCenter> items, {
    required String empty,
    required Widget Function(NearbyCenter) builder,
  }) {
    if (items.isEmpty) {
      return StateMessage(icon: Icons.search_off, message: empty);
    }
    return ResponsiveCards(children: [for (final i in items) builder(i)]);
  }
}

class _AdviceCard extends StatelessWidget {
  const _AdviceCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Material(
      color: scheme.secondaryContainer,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                Icons.health_and_safety_outlined,
                size: 36,
                color: scheme.onSecondaryContainer,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Besoin d’un conseil ?',
                      style: text.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: scheme.onSecondaryContainer,
                      ),
                    ),
                    Text(
                      'Premiers gestes et numéros utiles, disponibles hors ligne.',
                      style: text.bodySmall?.copyWith(
                        color: scheme.onSecondaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: scheme.onSecondaryContainer),
            ],
          ),
        ),
      ),
    );
  }
}
