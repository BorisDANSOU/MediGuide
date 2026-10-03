import 'package:flutter/material.dart';

import '../../../../core/utils/validators.dart';
import '../../data/repositories/demo_auth_repository.dart';
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
  bool _stayConnected = true;

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

  void _fillDemo() {
    _email.text = DemoAuthRepository.demoEmail;
    _password.text = DemoAuthRepository.demoPassword;
    widget.controller.clearError();
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
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Réinitialisation du mot de passe : disponible avec Firebase Auth.',
                    ),
                  ),
                ),
                child: const Text('Mot de passe oublié ?'),
              ),
            ),
            CheckboxListTile(
              value: _stayConnected,
              onChanged: (v) => setState(() => _stayConnected = v ?? true),
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              title: const Text('Rester connecté, même hors ligne'),
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
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: _fillDemo,
              icon: const Icon(Icons.bolt_outlined),
              label: const Text('Utiliser le compte de démonstration'),
            ),
          ],
        ),
      ),
    );
  }
}
