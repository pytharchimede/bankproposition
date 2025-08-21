import 'package:flutter/material.dart';
import '../widgets/bdu_button.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo BDU-CI
              Image.asset(
                'assets/Logo-BDUCI.png',
                width: 180,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 32),
              Text(
                'Bienvenue à la BDU-CI',
                style: Theme.of(context).textTheme.displayLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Votre banque, partout, tout le temps.',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              BduButton(
                label: 'Se connecter',
                type: BduButtonType.primary,
                onPressed: () => Navigator.pushNamed(context, '/login'),
              ),
              const SizedBox(height: 16),
              BduButton(
                label: 'Découvrir',
                type: BduButtonType.secondary,
                onPressed: () => Navigator.pushNamed(context, '/dashboard'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
