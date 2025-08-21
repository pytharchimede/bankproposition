import 'package:flutter/material.dart';
import '../widgets/bdu_button.dart';
import '../widgets/bdu_input.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _idCtrl = TextEditingController();
  final _pwdCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() {
    _idCtrl.dispose();
    _pwdCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() => _loading = false);
    Navigator.pushReplacementNamed(context, '/app');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Se connecter')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            Center(
              child: Image.asset(
                'assets/Logo-BDUCI.png',
                width: 160,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 24),
            BduInput(
              label: 'Identifiant',
              hintText: 'ex: john.doe',
              controller: _idCtrl,
              keyboardType: TextInputType.text,
            ),
            const SizedBox(height: 16),
            BduInput(
              label: 'Mot de passe',
              hintText: '••••••••',
              controller: _pwdCtrl,
              obscureText: _obscure,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscure
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Lien mot de passe oublié')),
                ),
                child: const Text('Mot de passe oublié ?'),
              ),
            ),
            const SizedBox(height: 8),
            BduButton(
              label: 'Se connecter',
              onPressed: _login,
              isLoading: _loading,
            ),
          ],
        ),
      ),
    );
  }
}
