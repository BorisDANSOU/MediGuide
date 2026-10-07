import 'package:flutter/material.dart';

import '../../../../core/utils/validators.dart';
import '../../domain/entities/app_user.dart';
import '../controllers/auth_controller.dart';
import 'auth_fields.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({
    super.key,
    required this.controller,
    required this.onSuccess,
  });

  final AuthController controller;
  final ValueChanged<AppUser> onSuccess;

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_form.currentState!.validate()) return;
    final user = await widget.controller.signIn(
      email: _email.text,
      password: _password.text,
    );
    if (user != null && mounted) widget.onSuccess(user);
  }

  /// Envoie le lien de réinitialisation à l'e-mail saisi.
  Future<void> _resetPassword() async {
    FocusScope.of(context).unfocus();
    // Un message à la fois : on remplace le précédent au lieu d'attendre.
    final messenger = ScaffoldMessenger.of(context)..hideCurrentSnackBar();
    final emailError = Validators.email(_email.text);
    if (emailError != null) {
      messenger.showSnackBar(
        SnackBar(content: Text('Saisissez d’abord votre e-mail. $emailError')),
      );
      return;
    }
    final sent = await widget.controller.sendPasswordReset(email: _email.text);
    if (sent) {
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            'Si un compte existe pour ${_email.text.trim()}, un e-mail de '
            'réinitialisation vient de lui être envoyé.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _form,
      child: AutofillGroup(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
            const SizedBox(height: 16),
            PasswordField(
              controller: _password,
              label: 'Mot de passe',
              validator: Validators.password,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _resetPassword,
                child: const Text('Mot de passe oublié ?'),
              ),
            ),
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
                    label: 'Se connecter',
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
