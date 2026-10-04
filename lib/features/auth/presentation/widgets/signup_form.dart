import 'package:flutter/material.dart';

import '../../../../core/constants/supported_locations.dart';
import '../../../../core/utils/validators.dart';
import '../../domain/entities/app_user.dart';
import '../controllers/auth_controller.dart';
import 'auth_fields.dart';

class SignupForm extends StatefulWidget {
  const SignupForm({
    super.key,
    required this.controller,
    required this.onSuccess,
  });

  final AuthController controller;
  final ValueChanged<AppUser> onSuccess;

  @override
  State<SignupForm> createState() => _SignupFormState();
}

class _SignupFormState extends State<SignupForm> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  String? _country;
  bool _acceptedTerms = false;
  bool _showTermsError = false;

  @override
  void dispose() {
    for (final c in [_name, _email, _password, _confirm]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    final valid = _form.currentState!.validate();
    setState(() => _showTermsError = !_acceptedTerms);
    if (!valid || !_acceptedTerms) return;

    final location = SupportedLocations.forCountry(_country!);
    final user = await widget.controller.signUp(
      fullName: _name.text,
      email: _email.text,
      password: _password.text,
      country: location.country,
      city: location.city,
    );
    if (user != null && mounted) widget.onSuccess(user);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Form(
      key: _form,
      child: AutofillGroup(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _name,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.name],
              validator: Validators.fullName,
              decoration: const InputDecoration(
                labelText: 'Nom complet',
                hintText: 'Ex. Awa Ouédraogo',
                prefixIcon: Icon(Icons.person_outline),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
              validator: Validators.email,
              onChanged: (_) => widget.controller.clearError(),
              decoration: const InputDecoration(
                labelText: 'Adresse e-mail',
                prefixIcon: Icon(Icons.mail_outline),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Pays de résidence',
              style: text.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              'Sert à afficher les centres de santé et les numéros d’urgence de votre pays.',
              style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 8),
            FormField<String>(
              initialValue: _country,
              validator: (_) =>
                  _country == null ? 'Choisissez votre pays.' : null,
              builder: (state) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final loc in SupportedLocations.all)
                        ChoiceChip(
                          label: Text(loc.country),
                          selected: _country == loc.country,
                          onSelected: (_) {
                            setState(() => _country = loc.country);
                            state.didChange(loc.country);
                          },
                        ),
                    ],
                  ),
                  if (state.hasError)
                    Padding(
                      padding: const EdgeInsets.only(top: 6, left: 12),
                      child: Text(
                        state.errorText!,
                        style: text.bodySmall?.copyWith(color: scheme.error),
                      ),
                    ),
                ],
              ),
            ),
            if (_country != null) ...[
              const SizedBox(height: 12),
              InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Ville',
                  prefixIcon: Icon(Icons.location_city_outlined),
                  border: OutlineInputBorder(),
                ),
                child: Text(SupportedLocations.forCountry(_country!).city),
              ),
            ],
            const SizedBox(height: 20),
            PasswordField(
              controller: _password,
              label: 'Mot de passe (8 caractères minimum)',
              validator: Validators.password,
              autofillHints: const [AutofillHints.newPassword],
            ),
            const SizedBox(height: 16),
            PasswordField(
              controller: _confirm,
              label: 'Confirmer le mot de passe',
              validator: Validators.confirmPassword(() => _password.text),
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.newPassword],
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 8),
            CheckboxListTile(
              value: _acceptedTerms,
              onChanged: (v) => setState(() {
                _acceptedTerms = v ?? false;
                if (_acceptedTerms) _showTermsError = false;
              }),
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              title: const Text(
                'J’accepte les conditions d’utilisation. Je comprends que '
                'MediGuide oriente vers les soins mais ne pose pas de diagnostic.',
              ),
              subtitle: _showTermsError
                  ? Text(
                      'Acceptez les conditions pour continuer.',
                      style: TextStyle(color: scheme.error),
                    )
                  : null,
            ),
            const SizedBox(height: 8),
            ListenableBuilder(
              listenable: widget.controller,
              builder: (context, _) => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (widget.controller.error != null) ...[
                    AuthErrorBanner(message: widget.controller.error!),
                    const SizedBox(height: 12),
                  ],
                  SubmitButton(
                    label: 'Créer mon compte',
                    busy: widget.controller.busy,
                    onPressed: _submit,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
