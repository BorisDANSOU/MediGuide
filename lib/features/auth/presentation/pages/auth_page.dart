import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/widgets/responsive_cards.dart';
import '../../../user_profile/presentation/controllers/user_profile_controller.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/usecases/sign_in.dart';
import '../../domain/usecases/sign_up.dart';
import '../controllers/auth_controller.dart';
import '../controllers/auth_providers.dart';
import '../widgets/login_form.dart';
import '../widgets/signup_form.dart';

enum AuthMode { login, signup }

/// Écran 02 : connexion et inscription (KABORE).
class AuthPage extends ConsumerStatefulWidget {
  const AuthPage({super.key, this.initialMode = AuthMode.login});

  final AuthMode initialMode;

  @override
  ConsumerState<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends ConsumerState<AuthPage> {
  late final AuthController _controller;
  late AuthMode _mode = widget.initialMode;

  @override
  void initState() {
    super.initState();
    final repository = ref.read(authRepositoryProvider);
    _controller = AuthController(SignIn(repository), SignUp(repository));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Ouvre la session, aligne le profil sur le pays du compte, puis l'accueil.
  Future<void> _onSignedIn(AppUser user) async {
    ref.read(authSessionProvider.notifier).signIn(user);
    await ref
        .read(userProfileControllerProvider.notifier)
        .selectCountry(user.country);
    if (mounted) context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final padding = constraints.maxWidth >= 600 ? 32.0 : 20.0;
            return ListView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.symmetric(horizontal: padding, vertical: 24),
              children: [
                MaxWidth(
                  maxWidth: 480,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: scheme.primary,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            Icons.local_hospital,
                            size: 40,
                            color: scheme.onPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'MediGuide',
                        textAlign: TextAlign.center,
                        style: text.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        'Accédez aux soins de santé, en ligne et hors ligne.',
                        textAlign: TextAlign.center,
                        style: text.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _EmergencyAccessCard(
                        onTap: () => context.push(AppRoutes.emergency),
                      ),
                      const SizedBox(height: 20),
                      SegmentedButton<AuthMode>(
                        segments: const [
                          ButtonSegment(
                            value: AuthMode.login,
                            icon: Icon(Icons.login),
                            label: Text('Connexion'),
                          ),
                          ButtonSegment(
                            value: AuthMode.signup,
                            icon: Icon(Icons.person_add_alt),
                            label: Text('Créer un compte'),
                          ),
                        ],
                        selected: {_mode},
                        onSelectionChanged: (s) {
                          _controller.clearError();
                          setState(() => _mode = s.first);
                        },
                      ),
                      const SizedBox(height: 20),
                      _mode == AuthMode.login
                          ? LoginForm(
                              controller: _controller,
                              onSuccess: _onSignedIn,
                            )
                          : SignupForm(
                              controller: _controller,
                              onSuccess: _onSignedIn,
                            ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () => context.go(AppRoutes.home),
                        child: const Text('Continuer sans compte'),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Les urgences restent accessibles sans compte (maquette « Accès Urgence
/// Express »).
class _EmergencyAccessCard extends StatelessWidget {
  const _EmergencyAccessCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Urgence médicale ?',
            style: text.titleMedium?.copyWith(
              color: scheme.onErrorContainer,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Pas besoin de compte pour appeler les secours.',
            style: text.bodySmall?.copyWith(color: scheme.onErrorContainer),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: onTap,
            style: FilledButton.styleFrom(
              backgroundColor: scheme.error,
              foregroundColor: scheme.onError,
            ),
            icon: const Icon(Icons.flash_on),
            label: const Text('Accès urgence express'),
          ),
        ],
      ),
    );
  }
}
