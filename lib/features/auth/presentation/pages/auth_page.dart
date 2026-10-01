import 'package:flutter/material.dart';

import '../../../../core/widgets/responsive_cards.dart';
import '../../../emergency/presentation/pages/emergency_modal_page.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../../../user_profile/domain/entities/user_profile_entity.dart';
import '../../data/repositories/demo_auth_repository.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/usecases/sign_in.dart';
import '../../domain/usecases/sign_up.dart';
import '../controllers/auth_controller.dart';
import '../widgets/login_form.dart';
import '../widgets/signup_form.dart';

/// Une seule instance pour la session : les comptes créés restent valables
/// après une déconnexion, jusqu'au redémarrage de l'application.
final _demoRepository = DemoAuthRepository();

enum AuthMode { login, signup }

/// Écran 02 : connexion et inscription (KABORE).
class AuthPage extends StatefulWidget {
  const AuthPage({
    super.key,
    this.initialMode = AuthMode.login,
    this.controller,
  });

  final AuthMode initialMode;

  /// Injectable pour les tests.
  final AuthController? controller;

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  late final AuthController _controller =
      widget.controller ??
      AuthController(SignIn(_demoRepository), SignUp(_demoRepository));
  late AuthMode _mode = widget.initialMode;

  @override
  void dispose() {
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  void _goHome({AppUser? user}) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => user == null
            ? const HomePage()
            : HomePage(
                userName: user.firstName,
                profile: UserProfileEntity(
                  country: user.country,
                  city: user.city,
                ),
              ),
      ),
    );
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
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const EmergencyModalPage(),
                          ),
                        ),
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
                              onSuccess: (u) => _goHome(user: u),
                            )
                          : SignupForm(
                              controller: _controller,
                              onSuccess: (u) => _goHome(user: u),
                            ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: _goHome,
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
