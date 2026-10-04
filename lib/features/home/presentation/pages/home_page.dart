import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/utils/external_actions.dart';
import '../../../../core/widgets/responsive_cards.dart';
import '../../../../core/widgets/state_message.dart';
import '../../../auth/presentation/controllers/auth_providers.dart';
import '../../../health_centers/domain/entities/center_filter.dart';
import '../../../health_centers/domain/entities/nearby_center.dart';
import '../../../health_centers/presentation/controllers/centers_around_provider.dart';
import '../../../health_centers/presentation/widgets/hospital_card.dart';
import '../../../user_profile/domain/entities/user_profile_entity.dart';
import '../../../user_profile/presentation/controllers/user_profile_controller.dart';
import '../../data/repositories/home_repo_impl.dart';
import '../../domain/usecases/get_home_overview.dart';
import '../controllers/home_controller.dart';
import '../widgets/emergency_banner.dart';
import '../widgets/home_header.dart';
import '../widgets/home_search_bar.dart';
import '../widgets/quick_services_grid.dart';
import '../widgets/section_title.dart';

/// Écran 03 : accueil et dashboard principal (KABORE).
/// Onglet Accueil : le pays et la ville viennent du profil (DANSOU).
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  late final HomeController _controller;

  /// Profil pour lequel les centres ont été chargés.
  UserProfileEntity? _loadedFor;

  @override
  void initState() {
    super.initState();
    _controller = HomeController(
      GetHomeOverview(HomeRepositoryImpl(ref.read(getCentersAroundProvider))),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _load(UserProfileEntity profile) =>
      _controller.load(country: profile.country, city: profile.city);

  void _openSearch([CenterFilter filter = CenterFilter.all]) =>
      context.push(AppRoutes.searchWith(filter));

  void _openDetail(NearbyCenter item) =>
      context.push(AppRoutes.center, extra: item);

  void _call(NearbyCenter item) => callPhoneNumber(context, item.center.phone!);

  void _directions(NearbyCenter item) => openDirections(
    context,
    latitude: item.center.latitude,
    longitude: item.center.longitude,
    label: item.center.name,
  );

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(userProfileControllerProvider);
    final user = ref.watch(authSessionProvider);

    final profile = profileState.value;
    if (profile == null) {
      return Scaffold(
        body: profileState.hasError
            ? const StateMessage(
                icon: Icons.error_outline,
                message: 'Impossible de lire votre pays et votre ville.',
              )
            : const Center(child: CircularProgressIndicator()),
      );
    }
    // Premier affichage ou changement de pays depuis le profil.
    if (profile != _loadedFor) {
      _loadedFor = profile;
      WidgetsBinding.instance.addPostFrameCallback((_) => _load(profile));
    }

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final padding = constraints.maxWidth >= 600 ? 24.0 : 16.0;
            return RefreshIndicator(
              onRefresh: () => _load(profile),
              child: ListenableBuilder(
                listenable: _controller,
                builder: (context, _) => ListView(
                  padding: EdgeInsets.fromLTRB(padding, 12, padding, 48),
                  children: [
                    MaxWidth(
                      child: _buildContent(context, profile, user?.firstName),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    UserProfileEntity profile,
    String? firstName,
  ) {
    final text = Theme.of(context).textTheme;
    final greeting = firstName == null
        ? 'Bonjour 👋'
        : 'Bonjour, $firstName 👋';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        HomeHeader(
          city: profile.city,
          country: profile.country,
          isSignedIn: firstName != null,
          onProfileTap: () => context.go(AppRoutes.profile),
          onSignInTap: () => context.push(AppRoutes.auth),
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
        EmergencyBanner(onTap: () => context.push(AppRoutes.emergency)),
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
        ..._buildDataSections(profile),
        const SizedBox(height: 24),
        _AdviceCard(onTap: () => context.push(AppRoutes.emergency)),
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
      onTap: () => context.go(AppRoutes.maternity),
    ),
    QuickService(
      icon: Icons.map_outlined,
      label: 'Carte',
      caption: 'Autour de moi',
      onTap: () => context.go(AppRoutes.map),
    ),
  ];

  List<Widget> _buildDataSections(UserProfileEntity profile) {
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
            onAction: () => _load(profile),
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
            onAction: () => context.go(AppRoutes.map),
          ),
          const SizedBox(height: 8),
          _cardsOrEmpty(
            overview.nearbyCenters,
            empty: 'Aucun centre de santé connu à ${overview.city}.',
            builder: (item) => HospitalCard(
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
